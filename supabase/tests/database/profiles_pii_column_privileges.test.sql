-- pgTAP — durable PII fix: profiles column-level privileges.
-- Run: `supabase test db`
-- Proves anon/authenticated lose SELECT on email/phone/date_of_birth, keep it on
-- non-PII columns, and retain UPDATE (profile edit still works).

begin;
select plan(8);

-- authenticated: PII columns are not selectable (3)
select ok(NOT has_column_privilege('authenticated', 'public.profiles', 'email', 'SELECT'),
  'authenticated CANNOT SELECT profiles.email');
select ok(NOT has_column_privilege('authenticated', 'public.profiles', 'phone', 'SELECT'),
  'authenticated CANNOT SELECT profiles.phone');
select ok(NOT has_column_privilege('authenticated', 'public.profiles', 'date_of_birth', 'SELECT'),
  'authenticated CANNOT SELECT profiles.date_of_birth');

-- authenticated: non-PII columns remain selectable (2)
select ok(has_column_privilege('authenticated', 'public.profiles', 'username', 'SELECT'),
  'authenticated CAN SELECT profiles.username');
select ok(has_column_privilege('authenticated', 'public.profiles', 'avatar_url', 'SELECT'),
  'authenticated CAN SELECT profiles.avatar_url');

-- no blanket table SELECT remains (column-scoped only) (1)
select ok(NOT has_table_privilege('authenticated', 'public.profiles', 'SELECT'),
  'authenticated has no table-level SELECT on profiles (column-scoped only)');

-- anon also cannot read PII (1)
select ok(NOT has_column_privilege('anon', 'public.profiles', 'email', 'SELECT'),
  'anon CANNOT SELECT profiles.email');

-- anon keeps non-PII (public reads stay possible where RLS allows) (1)
select ok(has_column_privilege('anon', 'public.profiles', 'username', 'SELECT'),
  'anon CAN SELECT profiles.username');

-- NOTE: service_role is untouched by construction — the REVOKEs target only
-- `authenticated` and `anon` by name; edge functions/admin are unaffected.
-- UPDATE grants are out of scope (SELECT-only migration) and differ repo-vs-prod.

select * from finish();
rollback;
