#!/bin/bash

# debug
# set -x

# Who are you?
whoareyou() {
  if [ -n "$1" ]; then
    figlet $1
  else
    figlet $(whoami)
  fi
}

# AWS Login
aws-login() {
  aws sso login
}
alogin() {
  aws sso login
}

#Pulumi login
plogin() {
  pnpm pulumi:login
}

#Delete Pulumi Lock file from S3
pdelete() {
  aws s3 rm $1
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
        docker stop $container
        docker rm $container
      fi
    done
    exited=$(docker ps -a -q -f status=exited)
    for container in "${exited[@]}"; do
      if [ -n "$container" ]; then
        echo "Removing:"
        docker rm $container
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
  # Old Way
  # dockerList=$(docker ps -a -q)
  # if [[ -n $dockerList ]]; then
  #   echo "Stopping:"
  #   docker ps --format '{{.Names}}'
  #   docker stop $dockerList
  # else
  #   echo "No Docker containers are running locally"
  #   echo "${RED}docker ps -a -q${NC} returned nothing"
  # fi
  orb stop
}

dockerCheck() {
  # Old Way
  # if (! docker stats --no-stream &>/dev/null); then
  #   echo "Docker isn't running, so I'll start it now"
  #   open /Applications/Docker.app
  #   echo "Starting... wait about 10 seconds"
  #   sleep 10
  # else
  #   echo "Docker is Running"
  # fi
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
    DB_HOST=$(pulumi --cwd .deploy --stack $environment stack output rdsAddress) DB_PASS=$(pulumi --cwd .deploy --stack $environment stack output --show-secrets rdsMasterPassword) DB_USER=master DB_SECURE=true ./server/scripts/configure-database.sh setup:platform
    pulumi login s3://dabble-pulumi-state/cloud/internal-accounts
    DB_HOST=$(pulumi --cwd .deploy --stack $environment-shared-database stack output rdsAddress) DB_PASS=$(pulumi --cwd .deploy --stack $environment-shared-database stack output --show-secrets rdsMasterPassword) DB_USER=master DB_SECURE=true ./server/scripts/configure-database.sh setup:internal
  elif [[ $environment == 'staging-use2' ]] || [[ $environment == 'production-use2' ]] && [[ "$folder" == "fathom" ]]; then
  echo "${GREEN}Updating FathomDB permissions for $environment${NC}"
    pulumi login s3://dabble-pulumi-state/cloud/dabble-accounts
    DB_HOST=$(pulumi --cwd .deploy --stack $environment stack output rdsAddress) DB_PASS=$(pulumi --cwd .deploy --stack $environment stack output --show-secrets rdsMasterPassword) DB_USER=master DB_SECURE=true ./server/scripts/configure-database-us.sh setup:platform
    pulumi login s3://dabble-pulumi-state/cloud/internal-accounts
    DB_HOST=$(pulumi --cwd .deploy --stack $environment-shared-database stack output rdsAddress) DB_PASS=$(pulumi --cwd .deploy --stack $environment-shared-database stack output --show-secrets rdsMasterPassword) DB_USER=master DB_SECURE=true ./server/scripts/configure-database-us.sh setup:internal
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
  sshuttle -r $(kubectl get pod -l app.kubernetes.io/name=kuttle -o jsonpath="{.items[0].metadata.name}" -n default) -e kuttle 10.0.0.0/8
}

# Airflow pod clean
airflow_pod_clean() {
  kube_action=${1:-"list"}
  kube_env=${2:-"staging"}
  if [ "$kube_action" == "delete" ]; then
    kubectl --context $kube_env-internal/main -n airflow get pods --field-selector 'status.phase=Failed' -o name | xargs kubectl --context $kube_env-internal/main -n airflow delete
  elif [ "$kube_action" == "help" ]; then
    figlet 👌abble
    echo "airflow_pod_clean <action> <env>"
    echo "  action: list | delete"
    echo "  env: staging | production"
  else
    kubectl --context $kube_env-internal/main -n airflow get pods
  fi
}

alias PWgen="uuidgen | tr '[:upper:]' '[:lower:]' | pbcopy"

git_update_dir() {
  directory=${1:-"."}
  for subdir in $directory/*/; do
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
    USER_POOL=$(aws cognito-idp list-user-pools --max-results 2 --profile $ENVIRONMENT | jq -r '.UserPools[].Id')
    query=(aws cognito-idp list-users --user-pool-id $USER_POOL --profile $ENVIRONMENT --limit 20 --filter phone_number=\"$PHONE_NUMBER\")
    if [ "$2" = "count" ] || [ "$3" = "count" ]; then
      "${query[@]}" | jq '.Users | length'
    # elif [ "$2" = "delete" ] || [ "$3" = "delete" ]; then
    #   echo "Run: aws cognito-idp admin-disable-user --user-pool-id $USER_POOL --username <USERNAME> --profile $ENVIRONMENT"
    #   "${query[@]}" | jq '.Users[].Username'
    else
      "${query[@]}" | jq '.Users'
    fi
  else
    echo "${RED}Missing Phone Number${NC}"
  fi
}

kubectl_secrets(){
  NAME=$1
  ENVIRONMENT=$2
  NAMESPACE=$3
  if [ -n "$NAME" ] && [ -n "$ENVIRONMENT" ] && [ -n "$NAMESPACE" ]; then
    kubectl get secret $NAME -o jsonpath='{.data}' --context $ENVIRONMENT/main -n $NAMESPACE | jq 'to_entries | map("\(.key): \(.value | @base64d)") | .[]'
  elif [ -n "$NAME" ]; then
    kubectl get secret $NAME -o jsonpath='{.data}' | jq 'to_entries | map("\(.key): \(.value | @base64d)") | .[]'
  else
    echo "${RED}Missing NAME${NC}"
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
    NAME="$(basename $(dirname $PWD))"
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
  if [ -n "$ENVIRONMENT" ] && [[ "${ENVIRONMENTS[*]}" =~ "${ENVIRONMENT}" ]]; then
    if [ "$ENVIRONMENT" = "root" ]; then
      SUFFIX="-account"
    else
      SUFFIX='-accounts'
    fi
    pulumi login s3://dabble-pulumi-state/cloud/$ENVIRONMENT$SUFFIX
  else
    echo "${RED}ENVIRONMENT Error${NC}"
    echo "${GREEN}  ENVIRONMENT: ${RED}${ENVIRONMENT}"
    echo "${GREEN}Allowed Environments - ${PURPLE}$ENVIRONMENTS${NC}"
  fi
}

psecrets() {
  ENVIRONMENT=$1
  if [ -n "$ENVIRONMENT" ]; then
    pstack $ENVIRONMENT
  fi
  export PULUMI_SKIP_UPDATE_CHECK="true"
  name=$(pulumi stack --show-name)
  echo "${GREEN}Showing Secrets for Stack: ${PURPLE}$name${NC}"
  pulumi config --show-secrets
}

run_wait() {
  local timeout="$1"
  shift
  local cmd="$@"
  
  if [[ -z "$timeout" || -z "$cmd" ]]; then
    echo "${RED}Missing <TIMEOUT> or <CMD>${NC}"
    echo "${GREEN}  ARGS:${NC} TIMEOUT - ${timeout}"
    echo "COMMAND - ${cmd}"
    return 1
  fi

  while true; do
    echo "Running: $cmd"
    eval "$cmd"

    if [[ $? -ne 0 ]]; then
      echo "Command failed. Exiting..."
      break
    fi

    echo "Waiting for $timeout seconds..."
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

count() {
  if [ -n "$1" ]; then
    echo "${GREEN}"Running Command:"${NC}"
    echo $@
    echo "----------"
    if [[ "$@" == *get* ]] && [[ "$@" == kc* ]]; then
      DATA=$(kubectl get ${@:3} --no-headers)
    elif [[ "$@" == kc* ]]; then
      DATA=$(kubectl ${@:3})
    else
      DATA=$($@)
    fi
    echo $DATA | wc -l
  else
    echo "Missing argument"
  fi
}
