#!/bin/bash

# debug
# set -x

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
  orb &>/dev/null
}

fathomDB() {
  export PULUMI_SKIP_UPDATE_CHECK="true"
  environment=$1
  folder=$(basename "$PWD")
  dockerCheck
  if [[ $environment == 'staging' ]] || [[ $environment == 'production' ]] && [[ "$folder" == "fathom" ]]; then
    echo "${GREEN}Updating FathomDB permissions for $environment${NC}"
    pulumi login s3://dabble-pulumi-state/cloud/dabble-accounts
    DB_HOST=$(pulumi --cwd .deploy --stack "$environment" stack output rdsAddress) DB_PASS=$(pulumi --cwd .deploy --stack "$environment" stack output --show-secrets rdsMasterPassword) DB_USER=master DB_SECURE=true ./server/scripts/configure-database.sh setup:platform
    pulumi login s3://dabble-pulumi-state/cloud/internal-accounts
    DB_HOST=$(pulumi --cwd .deploy --stack "$environment-shared-database" stack output rdsAddress) DB_PASS=$(pulumi --cwd .deploy --stack "$environment-shared-database" stack output --show-secrets rdsMasterPassword) DB_USER=master DB_SECURE=true ./server/scripts/configure-database.sh setup:internal
  elif [[ $environment == 'staging-use2' ]] || [[ $environment == 'production-use2' ]] && [[ "$folder" == "fathom" ]]; then
  echo "${GREEN}Updating FathomDB permissions for $environment${NC}"
    pulumi login s3://dabble-pulumi-state/cloud/dabble-accounts
    DB_HOST=$(pulumi --cwd .deploy --stack "$environment" stack output rdsAddress) DB_PASS=$(pulumi --cwd .deploy --stack "$environment" stack output --show-secrets rdsMasterPassword) DB_USER=master DB_SECURE=true ./server/scripts/configure-database-us.sh setup:platform
    pulumi login s3://dabble-pulumi-state/cloud/internal-accounts
    DB_HOST=$(pulumi --cwd .deploy --stack "$environment-shared-database" stack output rdsAddress) DB_PASS=$(pulumi --cwd .deploy --stack "$environment-shared-database" stack output --show-secrets rdsMasterPassword) DB_USER=master DB_SECURE=true ./server/scripts/configure-database-us.sh setup:internal
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
  if [ -n "$PHONE_NUMBER" ]; then
    if [ "$2" = "production" ] || [ "$2" = "staging" ]; then
      ENVIRONMENT="${2}"
    else
      ENVIRONMENT="production"
    fi
    if [[ "${PHONE_NUMBER:0:3}" != "+61" ]]; then
      PHONE_NUMBER="+61${PHONE_NUMBER:1}"
    fi
    USER_POOL=$(aws cognito-idp list-user-pools --max-results 2 --profile "$ENVIRONMENT" | jq -r '.UserPools[].Id')
    query=(aws cognito-idp list-users --user-pool-id "$USER_POOL" --profile "$ENVIRONMENT" --limit 20 --filter phone_number=\"$PHONE_NUMBER\")
    if [ "$2" = "count" ] || [ "$3" = "count" ]; then
      "${query[@]}" | jq '.Users | length'
    else
      "${query[@]}" | jq '.Users'
    fi
  else
    error "Missing Phone Number"
  fi
}

kubectl_secrets(){
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

pstack() {
  ENVIRONMENT=$1
  NAME=$(basename "$PWD")
  export PULUMI_SKIP_UPDATE_CHECK="true"
  if [[ "$NAME" =~ ^(dabble-accounts|internal-accounts|root-account)$ ]]; then
    NAME=""
  elif [[ "$NAME" = ".deploy" ]]; then
    NAME="$(basename "$(dirname "$PWD")")"
    NAME="-$NAME"
  else
    NAME="-$NAME"
  fi
  if [ -n "$ENVIRONMENT" ]; then
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
    COUNT=$(kubectl get nodes --context "$environment/main" --no-headers | wc -l)
    echo "${GREEN}$environment:${NC} $COUNT"
  else
    COUNT=$(kubectl get nodes --no-headers | wc -l)
    CURRENT_CONTEXT=$(cat ~/.kube/config | grep -E "^\s*current-context:" | awk '{print $2}')
    echo "${PURPLE}Current Context - ${GREEN} ${CURRENT_CONTEXT}:${NC} $COUNT"
  fi
}

podCheck() {
  staging=(staging staging-internal)
  staging_us=(staging-us staging-internal-us)
  production=(production production-internal)
  production_us=(production-us production-internal-us)

  local arg=("$@")
  if [ "${#arg[@]}" -eq 0 ]; then
    environments=("${staging[@]}" "${staging_us[@]}" "${production[@]}" "${production_us[@]}")
  elif  [ "${#arg[@]}" -eq 1 ]; then
    if [ "$arg" = "stag" ]; then
      environments=("${staging[@]}")
    elif [ "$arg" = "stag-us" ]; then
      environments=("${staging_us[@]}")
    elif [ "$arg" = "prod" ]; then
      environments=("${production[@]}")
    elif [ "$arg" = "prod-us" ]; then
      environments=("${production_us[@]}")
    else
      environments=("$@")
    fi
  else
    environments=("$@")
  fi

  if [ "${#environments[@]}" -eq 1 ]; then
    environments=("$environments")
  fi
  
  for environment in "${environments[@]}"; do
    echo "${PURPLE}Checking $environment...${NC}"
    kubectl get pods --context "$environment/main" --no-headers -A | grep -v "Running\|Completed"
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

# kubectl get pods | awk '/Error/ {print $1}' | xargs kubectl delete pod
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

run_wait() {
  local timeout="$1"
  local ignore="$2"

  if [[ "$ignore" == "true" ]]; then
    echo "${GREEN}Ignoring errors${NC}"
  fi

  shift
  local cmd="${*}"
  
  if [[ -z "$timeout" || -z "$cmd" ]]; then
    echo "${RED}Missing <TIMEOUT> or <CMD>${NC}"
    echo "${GREEN}  ARGS:${NC} TIMEOUT - ${timeout}"
    echo "COMMAND - ${cmd}"
    return 1
  fi

  while true; do
    echo "${GREEN}Running: ${PURPLE}$cmd${NC}"
    eval "$cmd"

    if [[ $? -ne 0  ]]; then
      error "${RED}ERROR${NC} - ${PURPLE}$cmd${NC}"
      if ! $ignore; then
        break
      fi
    fi

    echo "${PURPLE}Waiting for $timeout seconds...${NC}"
    sleep "$timeout"
  done
}

ghistory() {
  DAYS=$1
  if [ -z "$DATE" ]; then
    DATE=$(date -v -1d +'%d.%-m.%Y')
  else
    DATE=$(date -v -"$DAYS"d +'%d.%-m.%Y')
  fi
  history -E | grep "$DATE"
}

glock() {
  host=$(hostname)
  echo "Locking this Mac - ${host}"
  sleep 0.5
  osascript -e 'tell application "System Events" to keystroke "q" using {control down, command down}'
}

gbright() {
  if which brightness &>/dev/null; then
      brightness 1
      echo "BE BRIGHT!"
  else
    error "ewww install brightness"
    echo "  brew install brightness"
  fi
}
