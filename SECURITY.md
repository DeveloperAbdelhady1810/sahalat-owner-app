# Security policy

## Reporting a problem
Send security reports to the Sahalat technical owner (Quadro Techs) by e-mail, privately. Do not open a public issue with details, and never
paste passwords, tokens, API keys or customer data into an issue, chat or screenshot.

## Rules for contributors
* **No secret in the repository.** API keys, tokens, passwords, keystores and `.env` files stay out of git. Use `.env` (backend),
  `--dart-define-from-file` + `android/local.properties` + `ios/Flutter/Secrets.xcconfig` (apps), `.env.local` (websites). Examples live in
  the `*.example` files.
* The pre-commit hook (`.githooks/pre-commit`, gitleaks or the built-in check) and the `secret-scan` GitHub Action refuse commits that
  contain a key. Enable the hook once per clone: `git config core.hooksPath .githooks`.
* A key that was ever committed is **compromised**: rotate it (see `SECRETS_INVENTORY.md` in the backend folder), then clean the history.
* Archives (`*.zip`), videos and build output are not committed.

## What the apps promise
Tokens are kept in the platform secure storage, traffic is HTTPS only, nothing is backed up to the cloud, and identity documents are
visible only to IT through an audited endpoint.
