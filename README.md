# GMH-CLI

Personal Bash utility functions for AWS, Kubernetes, Docker, and Pulumi workflows.

## Installation

Add to your shell profile (`~/.zshrc` or `~/.bash_profile`):

```bash
source /path/to/gmh-cli/main.sh
```

## Usage

Run `ghelp` to see all available commands, or `ghelp <command>` for specific help.

## Commands

| Category | Commands |
|----------|----------|
| **AWS** | `alogin`, `glogin`, `aws_sso_session`, `cognito_search`, `natGateways` |
| **Kubernetes** | `nodeCount`, `podCheck`, `podClean`, `jobCheck`, `jobClean`, `kubectl_secrets` |
| **Pulumi** | `penv`, `pstack`, `psecrets`, `pdelete` |
| **Docker** | `dockerKill`, `dockerStop`, `dockerCheck` |
| **Utilities** | `ghistory`, `glock`, `gbright`, `html-live`, `downloadVideo`, `PWgen` |

## Dependencies

**Required:**
- [jq](https://stedolan.github.io/jq/)
- [aws-cli](https://aws.amazon.com/cli/)
- [pulumi](https://www.pulumi.com/docs/get-started/install/)
- [docker](https://docs.docker.com/get-docker/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [pnpm](https://pnpm.js.org/en/installation)

**Optional:**
- [kubectx & kubens](https://github.com/ahmetb/kubectx) - aliased as `kx`, `kn`, `kc`
- [figlet](http://www.figlet.org/) - for ASCII art banners
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - for `downloadVideo`