# GitHub Actions Workflows for SoloAdventurer

This directory contains GitHub Actions workflows that automate various aspects of the development process.

## Workflows

### 1. Flutter CI (`flutter-ci.yml`)

This workflow runs on every push to the `main` branch and on pull requests. It:

- Runs Flutter tests
- Performs static code analysis
- Builds the iOS app (without code signing)
- Builds the Android APK
- Uploads the Android APK as an artifact

### 2. Code Coverage (`code-coverage.yml`)

This workflow generates and reports code coverage:

- Runs tests with coverage enabled
- Uploads coverage data to Codecov (requires a CODECOV_TOKEN secret)
- Generates an HTML coverage report
- Uploads the HTML report as an artifact

### 3. Code Quality (`code-quality.yml`)

This workflow focuses on code quality:

- Verifies code formatting
- Runs static analysis
- Checks for outdated dependencies
- Runs custom lint rules (if available)

## Setting Up

### Prerequisites

1. For Codecov integration, you need to:
   - Create an account on [Codecov](https://codecov.io/)
   - Add your repository
   - Get a Codecov token
   - Add the token as a secret in your GitHub repository settings (Settings > Secrets > Actions > New repository secret) with the name `CODECOV_TOKEN`

### Customization

You can customize these workflows by:

- Adjusting the Flutter version
- Adding or removing build targets
- Modifying test parameters
- Adding deployment steps

## Troubleshooting

If you encounter issues with the workflows:

1. Check the workflow run logs in the Actions tab of your GitHub repository
2. Verify that your code passes tests and analysis locally
3. Ensure all required secrets are properly configured
4. Check that your Flutter version matches the one specified in the workflows
