import 'dart:io';

/// A simple script to generate GitHub issues from the PROJECT_ROADMAP.md file
///
/// Usage: dart scripts/generate_tasks.dart [sprint_number]
/// If sprint_number is not provided, it will generate tasks for the current sprint.
void main(List<String> args) async {
  // Determine which sprint to generate tasks for
  final sprintNumber = args.isNotEmpty ? int.tryParse(args[0]) : null;
  final sprintLabel =
      sprintNumber != null ? 'Sprint $sprintNumber' : 'Current Sprint';

  print('Generating tasks for $sprintLabel...');

  // Read the roadmap file
  final roadmapFile = File('docs/PROJECT_ROADMAP.md');
  if (!await roadmapFile.exists()) {
    print('Error: PROJECT_ROADMAP.md not found!');
    exit(1);
  }

  final roadmapContent = await roadmapFile.readAsString();

  // Parse the roadmap to find the current sprint
  final sprintRegex = RegExp(
    r'### (Current Sprint|Sprint (\d+)).*?(?=###|\Z)',
    dotAll: true,
  );

  final matches = sprintRegex.allMatches(roadmapContent);

  Sprint? targetSprint;
  for (final match in matches) {
    final sprintTitle = match.group(1)!;
    final sprintContent = match.group(0)!;

    if ((sprintNumber == null && sprintTitle == 'Current Sprint') ||
        (sprintNumber != null && sprintTitle == 'Sprint $sprintNumber')) {
      targetSprint = _parseSprint(sprintTitle, sprintContent);
      break;
    }
  }

  if (targetSprint == null) {
    print('Error: Could not find the specified sprint in the roadmap!');
    exit(1);
  }

  // Generate issue templates for each task
  final issuesDir = Directory('.github/ISSUES');
  if (!await issuesDir.exists()) {
    await issuesDir.create(recursive: true);
  }

  print('Found ${targetSprint.tasks.length} tasks in ${targetSprint.title}:');

  for (final task in targetSprint.tasks) {
    print('- ${task.title}');

    final issueContent = _generateIssueContent(targetSprint, task);
    final filename = task.title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_');
    final issueFile = File('${issuesDir.path}/$filename.md');

    await issueFile.writeAsString(issueContent);
  }

  print('\nTask templates generated in .github/ISSUES/');
  print(
      'You can now create these issues on GitHub manually or use the GitHub CLI:');
  print(
      '\n  gh issue create --template implementation_task --title "[TASK] Task Title"\n');
}

/// Parse a sprint section from the roadmap
Sprint _parseSprint(String title, String content) {
  final focusMatch = RegExp(r'\*\*Primary Focus\*\*: (.+)').firstMatch(content);
  final focus = focusMatch?.group(1) ?? 'Unknown';

  final tasks = <Task>[];

  // Parse implementation checklist
  final checklistRegex = RegExp(
      r'\*\*Implementation Checklist\*\*:\s*\n((?:^\d+\. \[ \] .+\n?)+)',
      multiLine: true);
  final checklistMatch = checklistRegex.firstMatch(content);

  if (checklistMatch != null) {
    final checklistContent = checklistMatch.group(1)!;
    final taskRegex = RegExp(r'^\d+\. \[ \] (.+)$', multiLine: true);
    final taskMatches = taskRegex.allMatches(checklistContent);

    for (final taskMatch in taskMatches) {
      final taskTitle = taskMatch.group(1)!;
      tasks.add(Task(taskTitle));
    }
  }

  // Parse reference documents
  final referencesRegex = RegExp(
      r'\*\*Reference Documents\*\*:\s*\n((?:^- \[.+\n?)+)',
      multiLine: true);
  final referencesMatch = referencesRegex.firstMatch(content);

  final references = <String>[];
  if (referencesMatch != null) {
    final referencesContent = referencesMatch.group(1)!;
    final referenceRegex =
        RegExp(r'^- \[(.+?)\]\((.+?)\)(?: - (.+))?$', multiLine: true);
    final referenceMatches = referenceRegex.allMatches(referencesContent);

    for (final referenceMatch in referenceMatches) {
      final docName = referenceMatch.group(1)!;
      final docPath = referenceMatch.group(2)!;
      final docSection = referenceMatch.group(3);

      final reference = docSection != null ? '$docName - $docSection' : docName;

      references.add(reference);
    }
  }

  return Sprint(title, focus, tasks, references);
}

/// Generate the content for a GitHub issue
String _generateIssueContent(Sprint sprint, Task task) {
  final buffer = StringBuffer();

  buffer.writeln('---');
  buffer.writeln('name: Implementation Task');
  buffer.writeln('about: Task from ${sprint.title}');
  buffer.writeln('title: "[TASK] ${task.title}"');
  buffer.writeln(
      'labels: implementation, ${sprint.title.toLowerCase().replaceAll(' ', '-')}');
  buffer.writeln('assignees: \'\'');
  buffer.writeln('---');
  buffer.writeln();
  buffer.writeln('## Task Description');
  buffer.writeln();
  buffer.writeln('Implement ${task.title} as part of ${sprint.title}.');
  buffer.writeln();
  buffer.writeln('Sprint Focus: ${sprint.focus}');
  buffer.writeln();
  buffer.writeln('## Documentation References');
  buffer.writeln();

  for (final reference in sprint.references) {
    buffer.writeln('- [ ] $reference');
  }

  buffer.writeln();
  buffer.writeln('## Implementation Checklist');
  buffer.writeln();
  buffer.writeln('- [ ] Review relevant documentation');
  buffer.writeln('- [ ] Implement the feature');
  buffer.writeln('- [ ] Write tests');
  buffer.writeln('- [ ] Update documentation');
  buffer.writeln();
  buffer.writeln('## Acceptance Criteria');
  buffer.writeln();
  buffer.writeln('- [ ] Implementation follows clean architecture principles');
  buffer.writeln('- [ ] All tests pass');
  buffer.writeln('- [ ] Code is well-documented');
  buffer.writeln('- [ ] PR has been reviewed and approved');
  buffer.writeln();
  buffer.writeln('## Dependencies');
  buffer.writeln();
  buffer.writeln(
      '<!-- List any tasks that must be completed before this one can start -->');
  buffer.writeln();
  buffer.writeln('## Related Files');
  buffer.writeln();
  buffer.writeln(
      '<!-- List the files that will need to be created or modified -->');
  buffer.writeln();
  buffer.writeln('## Notes');
  buffer.writeln();
  buffer.writeln(
      'This task is part of ${sprint.title}, which focuses on: ${sprint.focus}');
  buffer.writeln();
  buffer.writeln('## Time Estimate');
  buffer.writeln();
  buffer.writeln('- [ ] Small (1-2 hours)');
  buffer.writeln('- [ ] Medium (half day)');
  buffer.writeln('- [ ] Large (full day)');
  buffer.writeln('- [ ] XL (multiple days)');

  return buffer.toString();
}

/// Represents a sprint in the roadmap
class Sprint {
  final String title;
  final String focus;
  final List<Task> tasks;
  final List<String> references;

  Sprint(this.title, this.focus, this.tasks, this.references);
}

/// Represents a task in a sprint
class Task {
  final String title;

  Task(this.title);
}
