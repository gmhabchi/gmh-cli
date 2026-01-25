#!/bin/bash

# debug
# set -x

# Source shared.sh from the same directory as this script
# Use BASH_SOURCE for bash, ${(%):-%x} for zsh
if [ -n "$ZSH_VERSION" ]; then
  script_dir=$(dirname "${(%):-%x}")
else
  script_dir=$(dirname "${BASH_SOURCE[0]}")
fi
source "$script_dir/shared.sh"

# Who are you?
whoareyou() {
  if [ -n "$1" ]; then
    figlet "$1"
  else
    figlet "$(whoami)"
  fi
}

# AWS Login
aws-login() {
  aws sso login
}
alogin() {
  aws sso login
}

# AWS Login for ghabchi
glogin() {
  aws sso login --profile personal && export AWS_PROFILE=personal
}

#Pulumi login
plogin() {
  pnpm pulumi:login
}

#Delete Pulumi Lock file from S3
pdelete() {
  local s3_path="$1"

  # Validate input
  if [ -z "$s3_path" ]; then
    error "Missing S3 path"
    echo "${PURPLE}Usage${GREEN}: pdelete <S3_PATH>${NC}"
    return 1
  fi

  # Check that path starts with s3:// and ends with .json
  if [[ ! "$s3_path" =~ ^s3:// ]]; then
    error "S3 path must start with s3://"
    return 1
  fi

  if [[ ! "$s3_path" =~ \.json$ ]]; then
    error "S3 path must end with .json"
    return 1
  fi

  # Show what will be deleted and confirm
  echo "${PURPLE}About to delete:${NC} $s3_path"
  read -p "Are you sure? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    aws s3 rm "$s3_path"
  else
    echo "${GREEN}Cancelled${NC}"
  fi
}

#List things on the Network
lnetwork() {
  arp -a
}

# Stop and remove Docker containers or kill Docker/OrbStack
dockerKill() {
  local args=$1
  if [[ $args == 'main' ]]; then
    echo "Killing Docker/Orb"
    # killall Docker
    killall OrbStack
  elif [[ $args == 'all' ]]; then
    echo "Running containers:"
    docker ps --format '{{.Names}}'

    # Stop and remove running containers
    local running
    running=$(docker ps -q)
    if [[ -n "$running" ]]; then
      echo "Stopping and Removing:"
      echo "$running" | xargs -r docker stop
      echo "$running" | xargs -r docker rm
    fi

    # Remove exited containers
    local exited
    exited=$(docker ps -a -q -f status=exited)
    if [[ -n "$exited" ]]; then
      echo "Removing exited containers:"
      echo "$exited" | xargs -r docker rm
    fi

    echo "Killing Docker"
    killall Docker
  else
    echo "${RED}ERROR - No Argument"
    echo "${PURPLE}Please try:"
    echo "${GREEN}    dockerKill all|main${NC}"
  fi
}

# Stop OrbStack
dockerStop() {
  orb stop
}

# Check if OrbStack is running, start if not
dockerCheck() {
  if ! orb status &>/dev/null; then
    echo "Starting Orb"
    orb start
  fi
  orb &>/dev/null
}

# Update FathomDB permissions for a given environment
fathomDB() {
  export PULUMI_SKIP_UPDATE_CHECK="true"
  environment=$1
  folder=$(basename "$PWD")
  dockerCheck
  if [[ -n $environment ]] && [[ "$folder" == "fathom" ]]; then
    echo "${GREEN}Updating FathomDB permissions for $environment${NC}"
    pulumi login s3://dabble-pulumi-state/cloud/dabble-accounts
    DB_HOST=$(pulumi --cwd .deploy --stack "$environment" stack output rdsAddress) DB_PASS=$(pulumi --cwd .deploy --stack "$environment" stack output --show-secrets rdsMasterPassword) ENV="$environment" DB_USER=master DB_SECURE=true ./server/scripts/configure-database.sh setup:platform
    pulumi login s3://dabble-pulumi-state/cloud/internal-accounts
    DB_HOST=$(pulumi --cwd .deploy --stack "$environment-shared-database" stack output rdsAddress) DB_PASS=$(pulumi --cwd .deploy --stack "$environment-shared-database" stack output --show-secrets rdsMasterPassword) ENV="$environment" DB_USER=master DB_SECURE=true ./server/scripts/configure-database.sh setup:internal
  else
    echo "Either Environment not set or you're not in the right directory:"
    echo "${RED}Environment:${NC} $environment"
    echo "${RED}Directory:${NC} $folder"
  fi
}

# SSHUTTLE - KUTTLE'
kuttle_init() {
  kuttle_env=${1:-"production-internal"}
  kubectl config use-context "${kuttle_env}/main"
  kubectl config set-context --current --namespace=default
  sshuttle -r "$(kubectl get pod -l app.kubernetes.io/name=kuttle -o jsonpath="{.items[0].metadata.name}" -n default)" -e kuttle 10.0.0.0/8
}

# Airflow pod clean (legacy - consider using: podClean <env>-internal airflow)
airflow_pod_clean() {
  local kube_action=${1:-"list"}
  local kube_env=${2:-"staging"}
  if [[ "$kube_action" == "delete" ]]; then
    kubectl --context "$kube_env-internal/main" -n airflow get pods --field-selector 'status.phase=Failed' -o name | xargs -r kubectl --context "$kube_env-internal/main" -n airflow delete
  elif [[ "$kube_action" == "help" ]]; then
    figlet 👌abble
    echo "airflow_pod_clean <action> <env>"
    echo "  action: list | delete"
    echo "  env: staging | production"
  else
    kubectl --context "$kube_env-internal/main" -n airflow get pods
  fi
}

# Generate a secure password and copy to clipboard
unalias PWgen 2>/dev/null || true
PWgen() {
  local length="${1:-20}"
  local mode="${2:-complex}"
  local show_password=false

  # Check for --show flag in any position
  for arg in "$@"; do
    if [[ "$arg" == "--show" ]]; then
      show_password=true
    fi
  done

  if [[ "$1" == "simple" ]]; then
    mode="simple"
    length=20
  elif [[ "$2" == "simple" ]]; then
    mode="simple"
  fi

  local password

  if [[ "$mode" == "simple" ]]; then
    # Simple mode: only letters and digits
    password=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$length")
    echo "${GREEN}Generated simple password (letters + digits)${NC}"
  else
    # Complex mode: letters, digits, and symbols (default)
    password=$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*()_+-=[]{}|;:,.<>?' < /dev/urandom | head -c "$length")
    echo "${GREEN}Generated complex password (letters + digits + symbols)${NC}"
  fi

  echo "$password" | pbcopy

  if [[ "$show_password" == true ]]; then
    echo "${PURPLE}$password${NC}"
  fi

  echo "${GREEN}✓ Password copied to clipboard!${NC}"
}

# Pull latest master for all git repos in a directory
git_update_dir() {
  directory=${1:-"."}
  for subdir in "$directory"/*/; do
    if [ -d "$subdir.git" ]; then
      echo "Processing repository: $subdir"
      (
        cd "$subdir" || exit
        git checkout HEAD
        git checkout -f master
        git pull origin master
      )
    fi
  done
}

# Search AWS Cognito for users by phone number
cognito_search() {
  PHONE_NUMBER="$1"

  if [ -z "$PHONE_NUMBER" ]; then
    error "Missing Phone Number"
    return
  fi

  ENVIRONMENT="${2:-production}"

  case "$ENVIRONMENT" in
  production | staging)
    COUNTRY_CODE="+61"
    ;;
  production-us | staging-us)
    COUNTRY_CODE="+1"
    ;;
  production-uk | staging-uk)
    COUNTRY_CODE="+44"
    ;;
  count)
    ENVIRONMENT="production"
    COUNTRY_CODE="+61"
    ;;
  *)
    echo "Invalid environment. Defaulting to production."
    ENVIRONMENT="production"
    COUNTRY_CODE="+61"
    ;;
  esac

  CLEAN_ENVIRONMENT=$(awk -v env="$ENVIRONMENT" 'BEGIN {
  split(env, parts, "-");
  if (index(env, "-us")) {
    print toupper(parts[1]) "-US";
  } else if (index(env, "-uk")) {
    print toupper(parts[1]) "-UK";
  } else {
    print toupper(parts[1]) "-AU";
  }
}')

  if [[ "${PHONE_NUMBER:0:1}" != "+" ]]; then
    PHONE_NUMBER="${PHONE_NUMBER/#0/}"
    PHONE_NUMBER="${COUNTRY_CODE}${PHONE_NUMBER}"
  fi

  echo "${GREEN}Searching for Phone Number: ${PURPLE}$PHONE_NUMBER${NC} in ${GREEN}$CLEAN_ENVIRONMENT${NC}"

  USER_POOL=$(aws cognito-idp list-user-pools --max-results 2 --profile "$ENVIRONMENT" | jq -r '.UserPools[].Id')
  query=(aws cognito-idp list-users --user-pool-id "$USER_POOL" --profile "$ENVIRONMENT" --limit 20 --filter "phone_number=\"$PHONE_NUMBER\"")

  if [[ "$3" == "count" || "$2" == "count" ]]; then
    "${query[@]}" | jq '.Users | length'
  else
    "${query[@]}" | jq '.Users'
  fi
}

# Get and decrypt Kubernetes secrets
kubectl_secrets() {
  NAME=$1
  ENVIRONMENT=$2
  NAMESPACE=$3

  # Security warning
  echo "${RED}⚠️  WARNING: This will display sensitive secrets in the terminal!${NC}"
  read -p "Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "${GREEN}Cancelled${NC}"
    return 0
  fi

  if [ -n "$NAME" ] && [ -n "$ENVIRONMENT" ] && [ -n "$NAMESPACE" ]; then
    kubectl get secret "$NAME" -o jsonpath='{.data}' --context "$ENVIRONMENT/main" -n "$NAMESPACE" | jq 'to_entries | map("\(.key): \(.value | @base64d)") | .[]'
  elif [ -n "$NAME" ]; then
    kubectl get secret "$NAME" -o jsonpath='{.data}' | jq 'to_entries | map("\(.key): \(.value | @base64d)") | .[]'
  else
    error "Missing NAME"
    echo "${GREEN}NAME:${NC} ${NAME}"
  fi
}

# Change Pulumi stack based on current directory
pstack () {
  ENVIRONMENT=$1
  NAME=$(basename "$PWD") 
  export PULUMI_SKIP_UPDATE_CHECK="true" 
  if [[ "$NAME" =~ ^(dabble-accounts|internal-accounts|root-account)$ ]]
  # Main Stacks in the Cloud Repo
  then
          NAME=""
  elif [[ "$NAME" = ".deploy" ]]
  # Stacks using the .deploy folder
  then
          NAME="$(basename "$(dirname "$PWD")")" 
          NAME="-$NAME"
  elif [[ "$NAME" == "deploy" ]]
  # Stacks using the package/deploy folder
  then
          NAME="$(basename "$(dirname "$(dirname "$PWD")")")" 
          NAME="-$NAME"
  elif [[ "$NAME" == *_* ]]
  then
  # Data stacks with suffixes
          SUFFIX="-${NAME#*_}"
          NAME="-$(basename "$(dirname "$PWD")")$SUFFIX"
  else
          NAME="-$NAME" 
  fi
  if [ -n "$ENVIRONMENT" ]
  then
          echo "Changing to the following pulumi stack - ${GREEN}$ENVIRONMENT$NAME${NC}"
          pulumi stack select "$ENVIRONMENT$NAME"
  else
          echo "${RED}Missing ENVIRONMENT${NC}"
          echo "${GREEN}  ENVIRONMENT:${NC} ${ENVIRONMENT}"
  fi
}

# Change Pulumi login environment (dabble, internal, root)
penv() {
  ENVIRONMENT=$1
  export PULUMI_SKIP_UPDATE_CHECK="true"
  ENVIRONMENTS=(dabble internal root)
  if [ -n "$ENVIRONMENT" ] && [[ "${ENVIRONMENTS[*]}" =~ ${ENVIRONMENT} ]]; then
    if [ "$ENVIRONMENT" = "root" ]; then
      SUFFIX="-account"
    else
      SUFFIX='-accounts'
    fi
    pulumi login s3://dabble-pulumi-state/cloud/"$ENVIRONMENT$SUFFIX"
  else
    echo "${RED}ENVIRONMENT Error${NC}"
    echo "${GREEN}  ENVIRONMENT: ${RED}${ENVIRONMENT}"
    echo "${GREEN}Allowed Environments:"
    for ENV in "${ENVIRONMENTS[@]}"; do
      echo "${PURPLE}$ENV${NC}"
    done
  fi
}

# Show and decrypt Pulumi secrets for current or specified stack
psecrets() {
  ENVIRONMENT=$1
  if [ -n "$ENVIRONMENT" ]; then
    pstack "$ENVIRONMENT"
  fi
  export PULUMI_SKIP_UPDATE_CHECK="true"
  name=$(pulumi stack --show-name)
  echo "${GREEN}Showing Secrets for Stack: ${PURPLE}$name${NC}"
  pulumi config --show-secrets
}

# Count nodes in a Kubernetes cluster by purpose
nodeCount() {
  local environment=$1
  if [ -n "$environment" ]; then
    local nodes
    nodes=$(kubectl get nodes --context "$environment/main" -o json)
    local count
    count=$(echo "$nodes" | jq -r '.items | length')
    echo "${GREEN}$environment:${NC} $count"
    echo "$nodes" | jq -r '.items[] | .metadata.labels.purpose' | sort | uniq -c | sort -nr
  else
    local nodes
    nodes=$(kubectl get nodes -o json)
    local count
    count=$(echo "$nodes" | jq -r '.items | length')
    local current_context
    current_context=$(kubectl config current-context 2>/dev/null || echo "unknown")
    echo "${PURPLE}Current Context - ${GREEN} ${current_context}:${NC} $count"
    echo "$nodes" | jq -r '.items[] | .metadata.labels.purpose' | sort | uniq -c | sort -nr
  fi
}

# Check for non-running/non-completed pods across environments
# Usage: podCheck [environment...]
podCheck() {
  environments=($(envCheck "$@"))
  for environment in "${environments[@]}"; do
    echo "${PURPLE}Checking pods in $environment...${NC}"
    local result=$(kubectl get pods --context "$environment/main" --no-headers -A 2>/dev/null | grep -v "Running\|Completed")
    if [[ -z "$result" ]]; then
      echo "${GREEN}No problem pods found${NC}"
    else
      echo "$result"
    fi
    echo ""
  done
}

# Check for failed jobs across environments
# Usage: jobCheck [environment...]
jobCheck() {
  environments=($(envCheck "$@"))
  for environment in "${environments[@]}"; do
    echo "${PURPLE}Checking jobs in $environment...${NC}"
    local result=$(kubectl get jobs --context "$environment/main" --no-headers -A 2>/dev/null | grep -v "1/1")
    if [[ -z "$result" ]]; then
      echo "${GREEN}No failed jobs found${NC}"
    else
      echo "$result"
    fi
    echo ""
  done
}

# Delete failed/errored pods across environments
# Usage: podClean [environment...] or podClean <environment> <namespace>
podClean() {
  local namespace=""
  # Check if second arg looks like a namespace (not an environment shortcut)
  if [[ -n "$2" && ! "$2" =~ ^(stg|prod|stg-us|stg-uk|prod-us|prod-uk)$ ]]; then
    namespace="$2"
    environments=("$1")
  else
    environments=($(envCheck "$@"))
  fi

  for environment in "${environments[@]}"; do
    echo "${PURPLE}Cleaning failed pods in $environment...${NC}"

    if [[ -n "$namespace" ]]; then
      # With namespace: filter by phase or init container errors, output just name
      local jqFilter='.items[] | select(
        .status.phase == "Failed" or
        .status.phase == "Error" or
        (.status.initContainerStatuses[]? | .state.waiting.reason == "Error" or .state.terminated.reason == "Error")
      ) | .metadata.name'
      local pods=$(kubectl get pods -o json -n "$namespace" --context "$environment/main" 2>/dev/null | jq -r "$jqFilter")
      if [[ -z "$pods" ]]; then
        echo "${GREEN}No failed pods to clean${NC}"
      else
        echo "$pods" | xargs -r kubectl delete pod -n "$namespace" --context "$environment/main"
      fi
    else
      # Without namespace: need namespace/name for deletion across all namespaces
      local jqFilter='.items[] | select(
        .status.phase == "Failed" or
        .status.phase == "Error" or
        (.status.initContainerStatuses[]? | .state.waiting.reason == "Error" or .state.terminated.reason == "Error")
      ) | "\(.metadata.namespace)/\(.metadata.name)"'
      local pods=$(kubectl get pods -o json -A --context "$environment/main" 2>/dev/null | jq -r "$jqFilter")
      if [[ -z "$pods" ]]; then
        echo "${GREEN}No failed pods to clean${NC}"
      else
        echo "$pods" | while IFS='/' read -r ns name; do
          kubectl delete pod "$name" -n "$ns" --context "$environment/main"
        done
      fi
    fi
    echo ""
  done
}

# Delete failed jobs across environments
# Usage: jobClean [environment...] or jobClean <environment> <namespace>
jobClean() {
  local namespace=""
  # Check if second arg looks like a namespace (not an environment shortcut)
  if [[ -n "$2" && ! "$2" =~ ^(stg|prod|stg-us|stg-uk|prod-us|prod-uk)$ ]]; then
    namespace="$2"
    environments=("$1")
  else
    environments=($(envCheck "$@"))
  fi

  for environment in "${environments[@]}"; do
    echo "${PURPLE}Cleaning failed jobs in $environment...${NC}"

    if [[ -n "$namespace" ]]; then
      local jqFilter='.items[] | select(.status.conditions and (.status.conditions[]?.type | test("Fail"))) | .metadata.name'
      local jobs=$(kubectl get jobs -o json -n "$namespace" --context "$environment/main" 2>/dev/null | jq -r "$jqFilter")
      if [[ -z "$jobs" ]]; then
        echo "${GREEN}No failed jobs to clean${NC}"
      else
        echo "$jobs" | xargs -r kubectl delete job -n "$namespace" --context "$environment/main"
      fi
    else
      local jqFilter='.items[] | select(.status.conditions and (.status.conditions[]?.type | test("Fail"))) | "\(.metadata.namespace)/\(.metadata.name)"'
      local jobs=$(kubectl get jobs -o json -A --context "$environment/main" 2>/dev/null | jq -r "$jqFilter")
      if [[ -z "$jobs" ]]; then
        echo "${GREEN}No failed jobs to clean${NC}"
      else
        echo "$jobs" | while IFS='/' read -r ns name; do
          kubectl delete job "$name" -n "$ns" --context "$environment/main"
        done
      fi
    fi
    echo ""
  done
}

# Get VictoriaMetrics agent logs
vmLogs() {
  local follow=$1
  if [[ "$follow" == "follow" || "$follow" == "f" ]]; then
    kubectl logs deployments/vmagent-vm -c vmagent -n monitoring -f
  else
    kubectl logs deployments/vmagent-vm -c vmagent -n monitoring
  fi
}

# Create a one-off job from a CronJob for testing
logsCronjob() {
  local job=$1
  if [ -n "$job" ]; then
    kubectl create job --from=cronjob/"$job" test-"$job"
  else
    echo "${RED}Missing Argument${NC}"
    echo "${GREEN}  JOB:${NC} $job"
  fi
}

# Check VictoriaMetrics targets for failed scrapes
vmCheck() {
  local urls=("$@")
  for url in "${urls[@]}"; do
    url=${url%,}

    # Validate URL format (hostname:port)
    if [[ ! "$url" =~ ^[a-zA-Z0-9.-]+:[0-9]+$ ]]; then
      error "Invalid URL format: $url (expected format: hostname:port)"
      continue
    fi

    full_url="http://${url}/targets?show_only_unhealthy=true"
    echo "Checking $full_url"

    errors=$(curl -s --proto '=http,https' "$full_url" | grep "scrapes_failed=[1-9]" | sed -E -n '/error=[^,]+/ s/.*endpoint=([^,]+),.*error=([^,]+).*/\1/p')

    if [[ -n "$errors" ]]; then
      while IFS= read -r endpoint; do
        # Only open http/https URLs, not file:// or other protocols
        if [[ "$endpoint" =~ ^https?:// ]]; then
          echo "Opening $endpoint"
          open "$endpoint" 2>/dev/null
        else
          echo "${RED}Skipping invalid endpoint:${NC} $endpoint"
        fi
      done <<<"$errors"
    else
      echo "No errors found for $url"
    fi
  done
}

# List NAT Gateways with public IPs across AWS profiles
natGateways() {
  local PROFILES=("$@")
  if [ ${#PROFILES[@]} -eq 0 ]; then
    PROFILES=("${AWS_ENVIRONMENTS[@]}")
  fi

  {
    printf "Profile\tName\tPublic IP\n"

    for PROFILE in "${PROFILES[@]}"; do
    aws ec2 describe-nat-gateways --profile "$PROFILE" --output json \
      | jq -r --arg profile "$PROFILE" '
          (.NatGateways // [])[] as $ng
          | ($ng.NatGatewayAddresses // [])[]?
          | select(.PublicIp)
          | [
              $profile,
              (($ng.Tags // []) | map(select(.Key=="Name")) | (.[0].Value // "-")),
              .PublicIp
            ]
          | @tsv
        '
    done
  } | column -t -s $'\t' \
    | awk -v green="${GREEN:-}" -v nc="${NC:-}" '
        NR==1 {
          # Color header if GREEN/NC provided
          print green $0 nc
          # Underline header with dashes matching its width
          for (i=1;i<=length($0);i++) printf "-"; printf "\n"
          next
        }
        { print }
      '
}

# Start a local HTTP server for serving HTML files
html-live() {
  local port="${1:-8080}"
  local directory="${2:-.}"
  python3 -m http.server "$port" --directory "$directory"
}

# Download video from URL using yt-dlp
downloadVideo() {
  local url="$1"
  if ! command -v yt-dlp &>/dev/null; then
    echo "yt-dlp is not installed. Please install it using 'brew install yt-dlp'"
    return 1
  fi
  if [[ -z "$url" ]]; then
    echo "Usage: downloadVideo <URL>"
    return 1
  fi

  yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 "$url"
}

# Check AWS SSO session time remaining
aws_sso_session() {
  local f exp exp_s now_s left hours mins

  f=$(ls -t "$HOME"/.aws/sso/cache/*.json 2>/dev/null | head -1)
  if [[ -z "$f" ]]; then
    aws sso login || sleep 60
    return 1
  fi

  exp=$(jq -r '.expiresAt' "$f" 2>/dev/null)
  
  # macOS/BSD date parsing - handle both formats AWS might use
  if [[ "$exp" == *"Z" ]]; then
    exp_s=$(date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$exp" +%s 2>/dev/null)
  else
    exp_s=$(date -u -j -f "%Y-%m-%dT%H:%M:%S%Z" "$exp" +%s 2>/dev/null)
  fi

  now_s=$(date -u +%s)
  left=$(( exp_s - now_s ))
  (( left < 0 )) && left=0

  # Convert to hours and minutes
  hours=$(( left / 3600 ))
  mins=$(( (left % 3600) / 60 ))

  if (( hours > 0 )); then
    echo "${hours} hours ${mins} mins"
  elif (( mins > 0 )); then
    echo "${mins} mins"
  else
    echo "expired"
  fi
}

# Show shell history from N days ago
ghistory() {
  DAYS=${1:-1}
  DATE=$(date -v -"${DAYS}"d +'%Y-%m-%d')

  start_date=$(date -j -f "%Y-%m-%d" "$DATE" "+%s")
  end_date=$(date -j -f "%Y-%m-%d %H:%M:%S" "$DATE 23:59:59" "+%s")

  awk -F: -v start="$start_date" -v end="$end_date" '{
    if ($2 >= start && $2 <= end) {
      command = "date -r " $2 " +%d-%m-%Y\\ %H:%M:%S"
      command | getline timestamp
      close(command)
      # Extract and clean up the command part
      split($0, parts, ";")
      # Print readable timestamp and command
      print timestamp " : " parts[length(parts)]
    }
  }' ~/.zsh_history
}

# Lock the Mac screen
glock() {
  host=$(hostname)
  echo "Locking this Mac - ${host}"
  sleep 0.5
  osascript -e 'tell application "System Events" to keystroke "q" using {control down, command down}'
}

# Set screen brightness to 100%
gbright() {
  info "Setting brightness to 100%"
  for i in {1..23}; do
    osascript <<EOD
        tell application "System Events"
            key code 144 -- increase brightness
        end tell
EOD
  done
}

# Check and install dependencies
ginstall() {
  echo "${GREEN}GMH-CLI Dependency Installer${NC}"
  echo ""

  # Check if Homebrew is installed
  if ! command -v brew &> /dev/null; then
    echo "${RED}Homebrew is not installed.${NC}"
    echo "Homebrew is required to install dependencies."
    echo "Install it from: https://brew.sh"
    return 1
  fi

  # Required dependencies
  local required_deps=(
    "jq:jq"
    "aws:awscli"
    "pulumi:pulumi"
    "docker:docker"
    "kubectl:kubectl"
    "pnpm:pnpm"
  )

  # Optional dependencies
  local optional_deps=(
    "kubectx:kubectx"
    "figlet:figlet"
    "yt-dlp:yt-dlp"
  )

  echo "${PURPLE}=== Checking Required Dependencies ===${NC}"
  local missing_required=()

  for dep in "${required_deps[@]}"; do
    local cmd="${dep%%:*}"
    local pkg="${dep##*:}"

    if command -v "$cmd" &> /dev/null; then
      echo "${GREEN}✓${NC} $cmd is installed"
    else
      echo "${RED}✗${NC} $cmd is missing"
      missing_required+=("$pkg")
    fi
  done

  echo ""
  echo "${PURPLE}=== Checking Optional Dependencies ===${NC}"
  local missing_optional=()

  for dep in "${optional_deps[@]}"; do
    local cmd="${dep%%:*}"
    local pkg="${dep##*:}"

    if command -v "$cmd" &> /dev/null; then
      echo "${GREEN}✓${NC} $cmd is installed"
    else
      echo "${RED}✗${NC} $cmd is missing (optional)"
      missing_optional+=("$pkg")
    fi
  done

  echo ""

  # Install missing required dependencies
  if [ ${#missing_required[@]} -gt 0 ]; then
    echo "${PURPLE}=== Installing Required Dependencies ===${NC}"
    for pkg in "${missing_required[@]}"; do
      echo "${GREEN}Installing $pkg...${NC}"
      brew install "$pkg"
    done
  else
    echo "${GREEN}All required dependencies are installed!${NC}"
  fi

  echo ""

  # Prompt for optional dependencies
  if [ ${#missing_optional[@]} -gt 0 ]; then
    echo "${PURPLE}=== Optional Dependencies ===${NC}"
    echo "The following optional dependencies are missing:"
    for pkg in "${missing_optional[@]}"; do
      echo "  - $pkg"
    done
    echo ""
    read -p "Would you like to install optional dependencies? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      for pkg in "${missing_optional[@]}"; do
        echo "${GREEN}Installing $pkg...${NC}"
        brew install "$pkg"
      done
    else
      echo "Skipping optional dependencies."
    fi
  else
    echo "${GREEN}All optional dependencies are installed!${NC}"
  fi

  echo ""
  echo "${GREEN}Installation complete!${NC}"
}
