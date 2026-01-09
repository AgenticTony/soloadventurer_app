/**
 * PostToolUse Hook: Auto-format code after edits
 * Based on Boris Cherny's workflow: "PostToolUse hook to format Claude's code"
 *
 * This hook runs after every tool use to automatically format code.
 */

import { spawn } from 'child_process';

export default async function(config) {
  const { toolName, args } = config;

  // Only run after Write or Edit tools on Dart files
  if (toolName !== 'Write' && toolName !== 'Edit') {
    return { decision: 'allow' };
  }

  const filePath = args?.file_path;
  if (!filePath || !filePath.endsWith('.dart')) {
    return { decision: 'allow' };
  }

  console.log(`🎨 Formatting: ${filePath}`);

  try {
    // Run dart format (safer than exec)
    await runCommand('dart', ['format', filePath]);

    // Run dart fix --apply
    await runCommand('dart', ['fix', '--apply', filePath]);

    console.log(`✅ Formatted: ${filePath}`);
  } catch (error) {
    // Don't fail if formatting has issues
    console.warn(`⚠️  Formatting: ${error.message}`);
  }

  return { decision: 'allow' };
}

function runCommand(command, args) {
  return new Promise((resolve, reject) => {
    const proc = spawn(command, args, {
      stdio: ['ignore', 'pipe', 'pipe']
    });

    let stderr = '';

    proc.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    proc.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(stderr || `Command failed with code ${code}`));
      }
    });

    proc.on('error', reject);
  });
}
