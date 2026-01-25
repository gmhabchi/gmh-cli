# GMH-CLI

Personal Bash utility functions for AWS, Kubernetes, Docker, and Pulumi workflows.

## Features

- ✅ **Cross-shell support**: Works with both bash and zsh
- ✅ **Smart auto-completion**: Context-aware tab completion for all commands and arguments
- ✅ **Dependency management**: Built-in installer for required and optional dependencies
- ✅ **Password generation**: Secure password generator with simple and complex modes
- ✅ **Environment management**: Easy switching between staging/production environments
- ✅ **Kubernetes tools**: Pod/job management, secrets viewing, namespace completion
- ✅ **AWS integration**: SSO login helpers, Cognito search, NAT gateway listing
- ✅ **Pulumi workflows**: Stack management, secret viewing, environment switching

## Structure

```
gmh-cli/
├── main.sh              # Entry point - source this in your shell profile
├── README.md            # Documentation
└── src/                 # Internal source files
    ├── functions.sh     # Main function implementations
    ├── help.sh          # Help system
    ├── shared.sh        # Shared configuration
    ├── helper.sh        # Helper functions
    ├── alias.sh         # Shell aliases
    ├── completion.bash  # Bash completion
    └── completion.zsh   # Zsh completion
```

## Installation

1. Add to your shell profile (`~/.zshrc` or `~/.bash_profile`):

```bash
source /path/to/gmh-cli/main.sh
```

2. Restart your shell or run `source ~/.zshrc` (or `~/.bash_profile`) to enable auto-completion.

3. Install dependencies by running:

```bash
ginstall
```

This will automatically check for and install required dependencies, and prompt you to install optional ones.

## Usage

Run `ghelp` to see all available commands, or `ghelp <command>` for specific help.

### Auto-completion

Tab completion is automatically enabled for both **bash** and **zsh**. The appropriate completion file is loaded based on your shell. Press `Tab` to see available options:

- **Function names**: Type partial function name and press `Tab`
- **Environments**: Full environment names (no short aliases)
  - External: `staging`, `staging-us`, `staging-uk`, `production`, `production-us`, `production-uk`
  - Internal: `staging-internal`, `staging-internal-us`, `staging-internal-uk`, `production-internal`, `production-internal-us`, `production-internal-uk`
- **Arguments**: Context-aware completion for namespaces, actions, and more

Examples:
```bash
PWgen <Tab>                 # Shows: simple 12 16 20 24 32
PWgen 16 <Tab>              # Shows: simple
podClean <Tab>              # Shows: all environments
podClean production <Tab>   # Shows: namespaces in production/main
dockerKill <Tab>            # Shows: all main
penv <Tab>                  # Shows: dabble internal root
ghelp <Tab>                 # Shows: all available functions
```

## Commands

| Category | Commands |
|----------|----------|
| **Setup** | `ginstall` - Check and install dependencies |
| **AWS** | `alogin`, `glogin`, `aws_sso_session`, `cognito_search`, `natGateways` |
| **Kubernetes** | `nodeCount`, `podCheck`, `podClean`, `jobCheck`, `jobClean`, `kubectl_secrets`, `kuttle_init`, `vmLogs`, `vmCheck` |
| **Pulumi** | `penv`, `pstack`, `psecrets`, `pdelete`, `plogin` |
| **Docker** | `dockerKill`, `dockerStop`, `dockerCheck` |
| **Utilities** | `ghistory`, `glock`, `gbright`, `html-live`, `downloadVideo`, `PWgen`, `whoareyou`, `git_update_dir`, `lnetwork` |

Run `ghelp` for a complete list with descriptions, or `ghelp <command>` for detailed help on a specific command.

## Dependencies

Dependencies are automatically managed by the `ginstall` command (see Installation step 3 above).

### Required Dependencies
The following are automatically installed if missing:
- **jq** - JSON processor
- **aws-cli** - AWS command line interface
- **pulumi** - Infrastructure as code tool
- **docker** - Container platform
- **kubectl** - Kubernetes command line tool
- **pnpm** - Package manager

### Optional Dependencies
You'll be prompted to install these if they're missing:
- **kubectx & kubens** - Kubernetes context/namespace switchers (aliased as `kx` and `kn`)
- **figlet** - ASCII art text generator for banners
- **yt-dlp** - Video downloader for `downloadVideo` command

### Aliases
The following aliases are available:
- `kc` → `kubectl`
- `kx` → `kubectx`
- `kn` → `kubens`

> **Note:** [Homebrew](https://brew.sh) is required to install dependencies. The installer will check for it first.