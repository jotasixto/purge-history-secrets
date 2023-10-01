# Zsh History Purge Secrets Plugin
This zsh plugin helps ensure that secrets do not persist in your zsh history. It checks the `.zsh_history` file every 60 seconds for potential secrets using `Gitleaks`. If any are found, the respective lines are purged from the history and logged.

## Prerequisites

1. Gitleaks: This tool is used to scan the zsh history for potential secrets.
2. jq: A lightweight and flexible command-line JSON processor.

### Installing Gitleaks

Please follow the official installation guide for **Gitleaks** from [here](https://github.com/gitleaks/gitleaks).

### Installing jq

Please follow the official installation guide for **jq** from [here](https://jqlang.github.io/jq/download/).

### Installation

1. Clone this repository:

```bash
git clone https://github.com/jotasixto/purge-history-secrets.git ~/.oh-my-zsh/custom/plugins/purge-history-secrets
```

2. Add the plugin to the list of plugins in your `~/.zshrc`:

```bash
plugins=(... purge-history-secrets)
```

3. Reload your zsh configuration:

```bash
source ~/.zshrc
```

## How it works

Once the plugin is enabled:

1. Every 60 seconds, the plugin checks the `.zsh_history` file for potential secrets using **Gitleaks**.
2. If potential secrets are detected, the respective lines are deleted from the `.zsh_history` file.
3. A log of all purged lines is maintained in `~/.purge-secrets-zshhistory.log`, with timestamps indicating when each line was purged.
