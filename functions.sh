#!/bin/bash

# debug
# set -x

location=$(dirname "$0")
source $location/shared.sh

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
  # shellcheck disable=SC2034
  aws sso login --profile personal && export AWS_PROFILE=personal
}

#Pulumi login
plogin() {
  pnpm pulumi:login
}

#Delete Pulumi Lock file from S3
pdelete() {
  aws s3 rm "$1"
}

#List things on the Network
lnetwork() {
  arp -a
}

dockerKill() {
  # Old Way commented out
  args=$1
  if [[ $args == 'main' ]]; then
    echo "Killing Docker/Orb"
    # killall Docker
    killall OrbStack
  elif [[ $args == 'all' ]]; then
    running=$(docker ps -q)
    docker ps --format '{{.Names}}'
    for container in "${running[@]}"; do
      if [ -n "$container" ]; then
        echo "Stopping and Removing:"
        docker stop "$container"
        docker rm "$container"
      fi
    done
    exited=$(docker ps -a -q -f status=exited)
    for container in "${exited[@]}"; do
      if [ -n "$container" ]; then
        echo "Removing:"
        docker rm "$container"
      fi
    done
    echo "Killing Docker"
    killall Docker
  else
    echo "${RED}ERROR - No Argument"
    echo "${PURPLE}Please try:"
    echo "${GREEN}    dockerKill all|main${NC}"
  fi

}

dockerStop() {
  orb stop
}

dockerCheck() {
  if ! orb status &>/dev/null; then
    echo "Starting Orb"
    orb start
  fi
  orb &>/dev/null
}

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

# Airflow pod clean
airflow_pod_clean() {
  kube_action=${1:-"list"}
  kube_env=${2:-"staging"}
  if [ "$kube_action" == "delete" ]; then
    kubectl --context "$kube_env-internal/main" -n airflow get pods --field-selector 'status.phase=Failed' -o name | xargs kubectl --context "$kube_env-internal/main" -n airflow delete
  elif [ "$kube_action" == "help" ]; then
    figlet 👌abble
    echo "airflow_pod_clean <action> <env>"
    echo "  action: list | delete"
    echo "  env: staging | production"
  else
    kubectl --context "$kube_env-internal/main" -n airflow get pods
  fi
}

alias PWgen="uuidgen | tr '[:upper:]' '[:lower:]' | pbcopy"

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

kubectl_secrets() {
  NAME=$1
  ENVIRONMENT=$2
  NAMESPACE=$3
  if [ -n "$NAME" ] && [ -n "$ENVIRONMENT" ] && [ -n "$NAMESPACE" ]; then
    kubectl get secret "$NAME" -o jsonpath='{.data}' --context "$ENVIRONMENT/main" -n "$NAMESPACE" | jq 'to_entries | map("\(.key): \(.value | @base64d)") | .[]'
  elif [ -n "$NAME" ]; then
    kubectl get secret "$NAME" -o jsonpath='{.data}' | jq 'to_entries | map("\(.key): \(.value | @base64d)") | .[]'
  else
    error "Missing NAME=8="
    echo "${GREEN}NAME:${NC} ${NAME}"
  fi
}

pstack () {
  ENVIRONMENT=$1 
  NAME=$(basename "$PWD") 
  export PULUMI_SKIP_UPDATE_CHECK="true" 
  if [[ "$NAME" =~ ^(dabble-accounts|internal-accounts|root-account)$ ]]
  then
          NAME="" 
  elif [[ "$NAME" = ".deploy" ]]
  then
          NAME="$(basename "$(dirname "$PWD")")" 
          NAME="-$NAME"
  elif [[ "$NAME" == *_* ]]
  then
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

nodeCount() {
  local environment=$1
  if [ -n "$environment" ]; then
    NODES=$(kubectl get nodes --context "$environment/main" -o json)
    COUNT=$(echo "$NODES" | jq -r '.items | length')
    echo "${GREEN}$environment:${NC} $COUNT"
    echo $NODES | jq -r '.items[] | .metadata.labels.purpose' | sort | uniq -c | sort -nr
  else
    NODES=$(kubectl get nodes -o json)
    COUNT=$(echo "$NODES" | jq -r '.items | length')
    CURRENT_CONTEXT=$(cat ~/.kube/config | grep -E "^\s*current-context:" | awk '{print $2}')
    echo "${PURPLE}Current Context - ${GREEN} ${CURRENT_CONTEXT}:${NC} $COUNT"
    echo $NODES | jq -r '.items[] | .metadata.labels.purpose' | sort | uniq -c | sort -nr
  fi
}

podCheck() {
  environments=($(envCheck "$@"))
  if [ "${#environments[@]}" -eq 1 ]; then
    environments=("$environments")
  fi

  for environment in "${environments[@]}"; do
    echo "${PURPLE}Checking $environment...${NC}"
    errors=$(kubectl get pods --context "$environment/main" --no-headers -A | grep -v "Running\|Completed")
    if [[ -z $errors ]]; then
      echo "No errors"
    else
      echo "$errors"
    fi
  done
}

jobCheck() {
  environments=($(envCheck "$@"))
  if [ "${#environments[@]}" -eq 1 ]; then
    environments=("$environments")
  fi

  for environment in "${environments[@]}"; do
    echo "${PURPLE}Checking $environment...${NC}"
    jobs=$(kubectl get jobs --context "$environment/main" --no-headers -A | grep -v "1/1" | grep -v "Running")
    if [[ -n "$jobs" && "$jobs" != "No resources found" ]]; then
      echo "$jobs"
    fi
    echo ""
  done
}

vmLogs() {
  local pod=$1
  # shellcheck disable=SC2317
  if [ -n "$pod" ]; then
    kubectl logs "$pod" -n monitoring -c vmagent
  else
    kubectl logs "$(kubectl get pods -n monitoring -o json | jq -r '.items[] | select(.metadata.labels."app.kubernetes.io/name" == "vmagent") | .metadata.name')" -n monitoring -c vmagent
  fi
}

getUnhealthyPods() {
  local environment=$1
  local namespace=$2

}

podClean() {
  local environment=$1
  local namespace=$2
  if [ -n "$environment" ] && [ -n "$namespace" ]; then
    # shellcheck disable=SC2046
    kubectl delete pod $(kubectl get pods -o json -n "$namespace" --context "$environment/main" | jq -r '.items[] | select(.status.phase == "Failed" or .status.phase == "Error") | .metadata.name') -n "$namespace" --context "$environment/main"
  elif [ -n "$environment" ]; then
    # shellcheck disable=SC2046
    kubectl delete pod $(kubectl get pods -o json --context "$environment/main" | jq -r '.items[] | select(.status.phase == "Failed" or .status.phase == "Error") | .metadata.name') --context "$environment/main"
  else
    # shellcheck disable=SC2046
    kubectl delete pod $(kubectl get pods -o json | jq -r '.items[] | select(.status.phase == "Failed" or .status.phase == "Error") | .metadata.name')
  fi
}

jobClean() {
  local environment=$1
  local namespace=$2
  local jqFilter='.items[] | select(.status.conditions and (.status.conditions[]?.type | test("Fail"))) | .metadata.name'
  if [ -n "$environment" ] && [ -n "$namespace" ]; then
    kubectl delete job $(kubectl get jobs -o json -n "$namespace" --context "$environment/main" | jq -r "$jqFilter") -n "$namespace" --context "$environment/main"
  elif [ -n "$environment" ]; then
    kubectl delete job $(kubectl get jobs -o json --context "$environment/main" | jq -r "$jqFilter")
  else
    kubectl delete job $(kubectl get jobs -o json | jq -r "$jqFilter")
  fi
}

vmLogs() {
  local follow=$1
  if [[ "$follow" == "follow" || "$follow" == "f" ]]; then
    kubectl logs deployments/vmagent-vm -c vmagent -n monitoring -f
  else
    kubectl logs deployments/vmagent-vm -c vmagent -n monitoring
  fi
}

logsCronjob() {
  local job=$1
  if [ -n "$job" ]; then
    kubectl create job --from=cronjob/"$job" test-"$job"
  else
    echo "${RED}Missing Argument${NC}"
    echo "${GREEN}  JOB:${NC} $job"
  fi
}

vmCheck() {
  local urls=("$@")
  for url in "${urls[@]}"; do
    url=${url%,}
    full_url="http://${url}/targets?show_only_unhealthy=true"
    echo "Checking $full_url"

    errors=$(curl -s "$full_url" | grep "scrapes_failed=[1-9]" | sed -E -n '/error=[^,]+/ s/.*endpoint=([^,]+),.*error=([^,]+).*/\1/p')

    if [[ -n "$errors" ]]; then
      while IFS= read -r endpoint; do
        echo "Opening $endpoint"
        open "$endpoint" 2>/dev/null
      done <<<"$errors"
    else
      echo "No errors found for $url"
    fi
  done
}

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

html-live() {
  local port="${1:-8080}"
  local directory="${2:-.}"
  python3 -m http.server "$port" --directory "$directory"
}

downloadVideo() {
  local url="$1"
  if ! command -v yt-dlp &>/dev/null; then
    echo "yt-dlp is not installed. Please install it using 'brew install yt-dlp'"
    return 1
  fi
  if [[ -z "$url" ]]; then
    echo "Usage: download_video <URL>"
    return 1
  fi

  yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 "$url"
}

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

glock() {
  host=$(hostname)
  echo "Locking this Mac - ${host}"
  sleep 0.5
  osascript -e 'tell application "System Events" to keystroke "q" using {control down, command down}'
}

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
