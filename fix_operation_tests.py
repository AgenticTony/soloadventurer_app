#!/usr/bin/env python3
import re
import sys

def fix_operation_queue_tests(file_path):
    """Fix missing priority parameters in operation tests."""

    with open(file_path, 'r') as f:
        content = f.read()

    # Fix TripPlanningOperation - add priority after changes
    pattern1 = r'(TripPlanningOperation\(\s*id:\s*[\'"][^\'\"]+[\'\"],\s*tripId:\s*[\'"][^\'\"]+[\'\"],\s*planningType:\s*TripPlanningType\.[^,]+,\s*changes:\s*{[^}]*},)\s*\)'
    replacement1 = r'\1\n          priority: 10,\n        )'

    # Fix TravelNoteOperation - replace old fields with new ones
    # Old format had noteId, content as string
    # New format needs noteType, content as map, priority

    # Fix TravelNoteOperation.text() calls
    pattern2 = r'TravelNoteOperation\(\s*id:\s*[\'"][^\'\"]+[\'\"],\s*tripId:\s*[\'"][^\'\"]+[\'\"],\s*noteId:\s*[\'"][^\'\"]+[\'\"],\s*content:\s*[\'"][^\'\"]*[\'\"],'
    replacement2 = r"TravelNoteOperation(\n          id: '\1',\n          tripId: '\2',\n          noteType: NoteType.text,\n          content: {'text': '\3'},\n          priority: 10,"

    # Fix LocationUpdateOperation - remove tripId, add priority
    pattern3 = r'LocationUpdateOperation\((?=[^)]*tripId:)'
    replacement3 = 'LocationUpdateOperation_REPLACEME'

    lines = content.split('\n')
    new_lines = []
    i = 0

    while i < len(lines):
        line = lines[i]

        # Check for TripPlanningOperation without priority
        if 'TripPlanningOperation(' in line and 'priority:' not in line:
            # Find the closing parenthesis
            j = i
            indent = len(line) - len(line.lstrip())
            while j < len(lines):
                if ')' in lines[j]:
                    # Check if priority is already in this operation
                    has_priority = False
                    for k in range(i, j+1):
                        if 'priority:' in lines[k]:
                            has_priority = True
                            break

                    if not has_priority:
                        # Insert priority before the closing paren
                        closing_line = lines[j]
                        closing_idx = closing_line.find(')')
                        if closing_idx != -1:
                            lines[j] = closing_line[:closing_idx] + ',\n' + ' ' * (indent + 10) + 'priority: 10,' + closing_line[closing_idx:]
                    break
                j += 1
            new_lines.append(line)
        # Check for TravelNoteOperation with old fields
        elif 'TravelNoteOperation(' in line:
            # Check if it has noteId (old field)
            if i + 5 < len(lines) and 'noteId:' in lines[i+1]:
                # Replace old format with new format
                new_lines.append(line)
                i += 1
                # Skip noteId line
                # Replace content: 'string' with content: {'text': 'string'}
                if 'content:' in lines[i+1]:
                    content_line = lines[i+1]
                    match = re.search(r"content:\s*'([^']*)'", content_line)
                    if match:
                        text_content = match.group(1)
                        indent = len(content_line) - len(content_line.lstrip())
                        new_lines.append(' ' * indent + f"noteType: NoteType.text,")
                        new_lines.append(' ' * indent + f"content: {{'text': '{text_content}'}},")
                        new_lines.append(' ' * indent + "priority: 10,")
                        i += 2
                        continue
            new_lines.append(line)
        # Check for LocationUpdateOperation with tripId (old field)
        elif 'LocationUpdateOperation(' in line and 'priority:' not in line:
            # Find the closing parenthesis
            j = i
            while j < len(lines):
                if 'tripId:' in lines[j]:
                    # Remove this line
                    i += 1
                    continue
                if ')' in lines[j]:
                    # Add priority before closing
                    indent = len(lines[j]) - len(lines[j].lstrip())
                    closing_idx = lines[j].find(')')
                    if closing_idx != -1 and 'priority:' not in lines[j]:
                        lines[j] = lines[j][:closing_idx] + ',\n' + ' ' * (indent + 10) + 'priority: 1,' + lines[j][closing_idx:]
                    break
                j += 1
            new_lines.append(line)
        else:
            new_lines.append(line)

        i += 1

    with open(file_path, 'w') as f:
        f.write('\n'.join(new_lines))

    print(f"Fixed {file_path}")

if __name__ == '__main__':
    fix_operation_queue_tests(sys.argv[1])
