-- ============================================================================
-- Move PostGIS out of `public` into `extensions`
--
-- Security Advisor: rls_disabled_in_public on public.spatial_ref_sys (plus
-- geometry_columns / geography_columns). PostGIS was installed into `public`,
-- so supabase_admin owns those objects and they picked up the public default
-- grants: anon/authenticated held INSERT/UPDATE/DELETE/TRUNCATE on
-- spatial_ref_sys. postgres can neither enable RLS (not owner) nor revoke
-- (not grantor). Supabase Support's prescribed fix (2026-10-20): drop PostGIS
-- and re-create it in `extensions`, which the Data API does not expose.
-- https://supabase.com/docs/guides/database/extensions/postgis#troubleshooting
--
-- PostGIS is not relocatable, so DROP ... CASCADE takes its dependents with
-- it. On prod (surveyed 2026-10-20) that is exactly:
--   * 8 geography columns — ALL EMPTY (0 non-null rows each)
--   * 6 spatial indexes on them
--   * 4 functions with geography in their signature
-- No policies, views, triggers or constraints depend on PostGIS.
--
-- This migration does not hard-code that list. It captures whatever the drop
-- would take, recreates it in place, and FAILS CLOSED (aborting the whole
-- transaction) if the cascade would reach anything it cannot faithfully
-- recreate, or if any geography column holds data. Recreated objects:
--   columns   same name/type/typmod/NOT NULL/default/comment (appended last)
--   indexes   pg_get_indexdef, verbatim
--   functions pg_get_functiondef, verbatim, then owner + ACL replayed
--
-- Afterwards every public function that uses PostGIS is pinned to
-- `search_path = public, extensions`. Without that, functions pinned to
-- `public` (get_entries_near_location, trigger_sos, get_destination_posts)
-- would stop resolving ST_* / geography once they leave `public`.
--
-- Idempotent: a no-op once PostGIS already lives in `extensions`.
-- ============================================================================

do $migration$
declare
  v_ext_oid    oid;
  v_bad        text;
  v_has_data   text;
  r            record;
  a            record;
begin
  select e.oid into v_ext_oid
    from pg_extension e
   where e.extname = 'postgis' and e.extnamespace = 'public'::regnamespace;

  if v_ext_oid is null then
    raise notice 'move_postgis: postgis not in public — nothing to do';
    return;
  end if;

  -- --------------------------------------------------------------------------
  -- 1. Everything DROP EXTENSION postgis CASCADE would take with it.
  --    Column dependents follow only that column (dropping a column does not
  --    drop table-level policies/triggers); other objects follow wholesale.
  -- --------------------------------------------------------------------------
  create temp table _pg_cascade on commit drop as
  with recursive ext as (
    select d.classid, d.objid
      from pg_depend d
     where d.refclassid = 'pg_extension'::regclass
       and d.refobjid = v_ext_oid and d.deptype = 'e'
  ), deps as (
    select d.classid, d.objid, d.objsubid
      from pg_depend d
      join ext on d.refclassid = ext.classid and d.refobjid = ext.objid
     where d.deptype = 'n'
       and (d.classid, d.objid) not in (select classid, objid from ext)
    union
    select d.classid, d.objid, d.objsubid
      from pg_depend d
      join deps p on d.refclassid = p.classid and d.refobjid = p.objid
                 and (p.objsubid = 0 or d.refobjsubid = p.objsubid)
     where d.deptype in ('n', 'a')
       and (d.classid, d.objid) not in (select classid, objid from ext)
  )
  select distinct classid, objid, objsubid from deps;

  -- PostGIS-internal leftovers (opfamily members, its own catalog objects)
  -- go with the extension and need no recreation.
  delete from _pg_cascade c
   where c.classid in ('pg_amop'::regclass, 'pg_amproc'::regclass)
      or (c.classid = 'pg_class'::regclass
          and (select relnamespace from pg_class where oid = c.objid) = 'public'::regnamespace
          and (select relname from pg_class where oid = c.objid)
              in ('spatial_ref_sys', 'geometry_columns', 'geography_columns',
                  'spatial_ref_sys_pkey'))
      or (c.classid = 'pg_rewrite'::regclass
          and (select ev_class from pg_rewrite where oid = c.objid)
              in ('public.geometry_columns'::regclass, 'public.geography_columns'::regclass))
      or (c.classid = 'pg_constraint'::regclass
          and (select conrelid from pg_constraint where oid = c.objid)
              = 'public.spatial_ref_sys'::regclass)
      or (c.classid = 'pg_class'::regclass
          and (select relkind from pg_class where oid = c.objid) = 'c');  -- composite types (geometry_dump, valid_detail)

  -- Fail closed on anything we do not know how to recreate.
  select string_agg(pg_describe_object(classid, objid, objsubid), '; ')
    into v_bad
    from _pg_cascade c
   where not (
         c.classid = 'pg_proc'::regclass
      or (c.classid = 'pg_class'::regclass and c.objsubid <> 0
          and (select relkind from pg_class where oid = c.objid) in ('r', 'p'))
      or (c.classid = 'pg_class'::regclass and c.objsubid = 0
          and (select relkind from pg_class where oid = c.objid) = 'i')
   );
  if v_bad is not null then
    raise exception 'move_postgis: cascade would drop objects this migration cannot recreate: %', v_bad;
  end if;

  -- --------------------------------------------------------------------------
  -- 2. Capture.
  -- --------------------------------------------------------------------------
  create temp table _pg_cols on commit drop as
  select c.objid::regclass                         as tbl,
         att.attname                               as col,
         format_type(att.atttypid, att.atttypmod)  as coltype,
         att.attnotnull                            as notnull,
         pg_get_expr(ad.adbin, ad.adrelid)         as coldefault,
         col_description(c.objid, att.attnum)      as colcomment,
         att.attacl                                as colacl
    from _pg_cascade c
    join pg_attribute att on att.attrelid = c.objid and att.attnum = c.objsubid
    left join pg_attrdef ad on ad.adrelid = att.attrelid and ad.adnum = att.attnum
   where c.classid = 'pg_class'::regclass and c.objsubid <> 0;

  for r in select tbl, col from _pg_cols loop
    execute format('select count(%I)::text from %s where %I is not null', r.col, r.tbl, r.col)
      into v_has_data;
    if v_has_data <> '0' then
      raise exception 'move_postgis: %.% holds % non-null rows — this migration only moves empty geo columns; back them up first',
        r.tbl, r.col, v_has_data;
    end if;
  end loop;

  create temp table _pg_idx on commit drop as
  select pg_get_indexdef(c.objid) as def
    from _pg_cascade c
   where c.classid = 'pg_class'::regclass and c.objsubid = 0;

  create temp table _pg_fns on commit drop as
  select pg_get_functiondef(p.oid)                       as def,
         p.proname                                       as name,
         pg_get_function_identity_arguments(p.oid)       as args,
         p.proowner::regrole                             as owner,
         p.proacl                                        as acl,
         obj_description(p.oid, 'pg_proc')               as fncomment
    from _pg_cascade c
    join pg_proc p on p.oid = c.objid
   where c.classid = 'pg_proc'::regclass;

  raise notice 'move_postgis: recreating % columns, % indexes, % functions',
    (select count(*) from _pg_cols), (select count(*) from _pg_idx), (select count(*) from _pg_fns);

  -- --------------------------------------------------------------------------
  -- 3. Move the extension.
  -- --------------------------------------------------------------------------
  drop extension postgis cascade;
  create extension postgis with schema extensions;

  -- Unqualified `geography` / ST_* in the captured DDL now resolve here.
  perform set_config('search_path', 'public, extensions', true);

  -- --------------------------------------------------------------------------
  -- 4. Recreate.
  -- --------------------------------------------------------------------------
  for r in select * from _pg_cols loop
    execute format('alter table %s add column %I %s%s%s',
      r.tbl, r.col, r.coltype,
      case when r.coldefault is not null then ' default ' || r.coldefault else '' end,
      case when r.notnull then ' not null' else '' end);
    if r.colcomment is not null then
      execute format('comment on column %s.%I is %L', r.tbl, r.col, r.colcomment);
    end if;
    for a in select (aclexplode(r.colacl)).* loop
      execute format('grant %s (%I) on %s to %s', a.privilege_type, r.col, r.tbl,
        case when a.grantee = 0 then 'public' else a.grantee::regrole::text end);
    end loop;
  end loop;

  for r in select def from _pg_idx loop
    execute r.def;
  end loop;

  for r in select * from _pg_fns loop
    execute r.def;
    execute format('alter function public.%I(%s) owner to %s', r.name, r.args, r.owner);
    if r.fncomment is not null then
      execute format('comment on function public.%I(%s) is %L', r.name, r.args, r.fncomment);
    end if;
    -- Replay the ACL exactly: NULL means the built-in default (PUBLIC execute).
    execute format('revoke all on function public.%I(%s) from public, anon, authenticated, service_role',
      r.name, r.args);
    if r.acl is null then
      execute format('grant execute on function public.%I(%s) to public', r.name, r.args);
    else
      for a in select (aclexplode(r.acl)).* loop
        if a.grantee = 0 then
          execute format('grant execute on function public.%I(%s) to public', r.name, r.args);
        elsif a.grantee <> r.owner::oid then
          execute format('grant execute on function public.%I(%s) to %s', r.name, r.args, a.grantee::regrole);
        end if;
      end loop;
    end if;
  end loop;

  -- --------------------------------------------------------------------------
  -- 5. Pin every PostGIS-using public function to a path that can see it.
  -- --------------------------------------------------------------------------
  for r in
    select p.oid::regprocedure as fn
      from pg_proc p
     where p.pronamespace = 'public'::regnamespace
       and p.prokind = 'f'
       and not exists (select 1 from pg_depend d
                        where d.classid = 'pg_proc'::regclass and d.objid = p.oid and d.deptype = 'e')
       and pg_get_functiondef(p.oid) ~* '\m(st_[a-z0-9_]+\s*\(|geography|geometry)'
  loop
    execute format('alter function %s set search_path = public, extensions', r.fn);
  end loop;
end
$migration$;

notify pgrst, 'reload schema';
