# Setting Up GitHub Secrets

To complete the CI/CD setup, you need to add the following secret to your GitHub repository:

## Codecov Token

1. Go to your GitHub repository: https://github.com/PhoenixTiger007/SoloAdventurer_app
2. Click on "Settings" (tab near the top of the page)
3. In the left sidebar, click on "Secrets and variables" → "Actions"
4. Click the "New repository secret" button
5. Enter the following:
   - Name: `CODECOV_TOKEN`
   - Secret: `6e514653-4332-4e65-aa3f-6a6dec3af331`
6. Click "Add secret"

This token will allow the GitHub Actions workflow to upload code coverage reports to Codecov.

## Verifying the Setup

After adding the secret:

1. Go to the "Actions" tab in your repository
2. You should see your workflows running on the next push
3. The "Code Coverage" workflow should successfully upload reports to Codecov

## Security Note

- Keep this token secure and don't share it publicly
- If you need to rotate the token, you can generate a new one from Codecov and update the secret in GitHub
