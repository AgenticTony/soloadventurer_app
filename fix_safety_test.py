#!/usr/bin/env python3
"""
Fix integration test errors in safety_flow_test.dart
"""

import re
import sys

def fix_test_file(content):
    """Fix common errors in the integration test file"""

    # Fix 1: Remove .notifier calls - providers return the notifier directly
    content = re.sub(
        r'container\.read\((\w+Provider)\)\.notifier',
        r'container.read(\1)',
        content
    )

    # Fix 2: Access state properties through .state
    # Pattern: provider).contacts -> provider).state.contacts
    content = re.sub(
        r'container\.read\((trustedContactsNotifierProvider|checkInNotifierProvider|locationSharingNotifierProvider|safetyNotifierProvider)\)\.([a-zA-Z]+)',
        r'container.read(\1).state.\2',
        content
    )

    # Fix 3: Fix notifier variable access
    # Pattern: contactsNotifier.contacts -> contactsNotifier.state.contacts
    content = re.sub(
        r'(contactsNotifier|checkInNotifier|locationSharingNotifier|safetyNotifier)\.([a-zA-Z]+)(?=\s*\.|\s*\)|\s*,|\s*;|\s*\n)',
        r'\1.state.\2',
        content
    )

    # Fix 4: Fix SafetyStatus property access (statusType -> status)
    content = re.sub(
        r'\.statusType\b',
        r'.status',
        content
    )

    # Fix 5: Fix SafetyAlertLocation timestamp parameter
    # This is harder to fix with regex, so we'll mark it

    # Fix 6: Fix method signatures for update/remove methods
    # These need to be checked case by case

    return content

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python3 fix_safety_test.py <file>")
        sys.exit(1)

    filename = sys.argv[1]

    with open(filename, 'r') as f:
        content = f.read()

    fixed_content = fix_test_file(content)

    with open(filename, 'w') as f:
        f.write(fixed_content)

    print(f"Fixed {filename}")
