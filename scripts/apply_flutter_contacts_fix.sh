#!/bin/bash
#
# Script to apply flutter_contacts plugin crash fix
#
# This script patches the flutter_contacts plugin to prevent crash during
# plugin registration when the app window is not yet initialized.
#
# Run this script after 'flutter pub get' or 'flutter clean'
#

set -e

PLUGIN_PATH="ios/.symlinks/plugins/flutter_contacts/ios/Classes/SwiftFlutterContactsPlugin.swift"

echo "Applying flutter_contacts crash fix..."

# Check if plugin exists
if [ ! -f "$PLUGIN_PATH" ]; then
    echo "ERROR: flutter_contacts plugin not found at $PLUGIN_PATH"
    echo "Please run 'flutter pub get' first"
    exit 1
fi

# Apply the fix using sed
sed -i '' 's/let rootViewController = UIApplication\.shared\.delegate!\.window!!\.rootViewController!/\/\/ Safely get rootViewController - may be nil during early initialization\
        let rootViewController = UIApplication.shared.delegate?.window??.rootViewController ?? UIViewController()/' "$PLUGIN_PATH"

echo "✓ flutter_contacts crash fix applied successfully"
echo ""
echo "NOTE: This fix prevents the plugin from crashing during initialization"
echo "by using optional chaining instead of force unwrapping the window."
