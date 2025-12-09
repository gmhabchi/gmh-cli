#!/bin/bash

# G Help
ghelp() {
  if [ -z "$1" ]; then
    figlet GHelp
    echo -e "${RED}ghelp${NC}: Helpy CLI"
    echo -e "${PURPLE}Usage${GREEN}: ghelp <command>"
    echo -e "${PURPLE}Example${GREEN}: ghelp aws-login${NC}"
    echo ""
    echo -e "${RED}alogin${NC}/${RED}aws-login${NC}: Login to AWS CLI"
    echo -e "${RED}glogin${NC}: Login to AWS CLI for personal AWS account"
    echo -e "${RED}plogin${NC}: Login to Pulumi Project with pnpm 👌"
    echo -e "${RED}kuttle_init${NC}: Initialize kuttle"
    echo -e "${RED}git_update_dir${NC}: Update all git repositories in a directory"
    echo -e "${RED}pdelete <S3 PATH>${NC}: Delete Pulumi Lock file from S3 bucket"
    echo -e "${RED}lnetwork${NC}: Find network devices using ARP"
    echo -e "${RED}dockerKill${NC}: Stop and remove all Docker containers, or just stop Docker"
    echo -e "${RED}fathomDB${NC}: Update FathomDB permissions"
    echo -e "${RED}dockerCheck${NC}: Check and start Docker if it's not running"
    echo -e "${RED}cognito_search${NC}: Search AWS Cognito for a user by phone_number"
    echo -e "${RED}kubectl_secrets <NAME> <ENV>${NC}: Fetch Kubernetes secrets"
    echo -e "${RED}pstack <ENV>${NC}: Change the Pulumi stack based on current directory"
    echo -e "${RED}penv <ENV>${NC}: Change the Pulumi environment"
    echo -e "${RED}glock${NC}: Lock the screen"
    echo -e "${RED}whoareyou${NC}: Display the current user's identity"
    echo -e "${RED}psecrets${NC}: Retrieve and decrypt Pulumi secrets"
    echo -e "${RED}run_wait${NC}: Run a command and wait for a specified interval"
    echo -e "${RED}nodeCount${NC}: Count nodes in a Kubernetes cluster"
    echo -e "${RED}podCheck${NC}: Check for non-running or non-completed pods in Kubernetes"
    echo -e "${RED}podClean${NC}: Clean up pods in a Kubernetes cluster"
    echo -e "${RED}vmLogs${NC}: Get logs for a VM"
    echo -e "${RED}natGateways${NC}: List NAT Gateways in AWS"
    echo -e "${RED}aws_sso_session${NC}: Check AWS SSO login session status"
    echo -e "${RED}ghistory${NC}: Get the git commit history"
    echo -e "${RED}html-live${NC}: Start a live server for HTML files"
    echo -e "${RED}downloadVideo${NC}: Download a video from a URL"
    echo -e "${RED}vmCheck${NC}: I help put the URLs together for the VM Status Check"
    echo ""
  else
    case $1 in
    "alogin")
      aws -h
      ;;
    "aws-login")
      aws -h
      ;;
    "plogin")
      pulumi help
      ;;
    "kuttle_init")
      kuttle -h
      ;;
    "git_update_dir")
      git -h
      ;;
    "pdelete")
      echo "aws -h"
      aws -h
      ;;
    "lnetwork")
      echo "arp -h"
      arp -h
      ;;
    "dockerKill")
      echo "I run 'docker stop \$(docker ps -a -q)' && 'docker rm \$(docker ps -a -q)'"
      echo "To stop and remove all containers created locally"
      echo "Or"
      echo "I run 'killall Docker' to stop Docker from running"
      echo "${PURPLE}Usage${GREEN}: dockerKill all" 
      ;;
    "fathomDB")
      echo "I run the things to sort out the Fathom DB Permissions"
      echo "${RED}Please be in the correct directory${NC}"
      ;;
    "dockerCheck")
      echo "I check that Docker is running locally and if not I'll start it"
      ;;
    "cognito_search")
      echo "I search cognito for users"
      echo "Right now only by phone numbers and must include country codes"
      echo "${PURPLE}Usage${GREEN}: cognito_search +61400000000 <ENVIRONMENT>"
      echo "${PURPLE}Usage${GREEN}: cognito_search +61400000000 <ENVIRONMENT> count"
      ;;
    "kubectl_secrets")
      echo "I get and decrypt the secrets in Kubernetes"
      echo "${PURPLE}Usage${GREEN}: kubectl_secrets <NAME>${NC}"
      echo "Pass through the <ENVIRONMENT> & <SECRET_NAME> if needed"
      echo "${PURPLE}Usage${GREEN}: kubectl_secrets <NAME> <ENVIRONMENT> <SECRET_NAME>"
      ;;
    "pstack")
      echo "I change the pulumi stack for you based on the directory you're in"
      echo "${PURPLE}Usage${GREEN}: pstack <ENVIRONMENT>${NC}"
      ;;
    "penv")
      echo "I change the pulumi environment for you"
      echo "${PURPLE}Usage${GREEN}: penv <ENVIRONMENT>${NC}"
      ;;
    "psecrets")
      echo "I get and decrypt the Pulumi secrets"
      echo "${PURPLE}Usage${GREEN}: psecrets${NC}"
      echo "Pass through the <ENVIRONMENT> if needed"
      echo "${PURPLE}Usage${GREEN}: psecrets <ENVIRONMENT>${NC}"
      ;;
    "run_wait")
      echo "I run a command and every <INTERVAL>"
      echo "${PURPLE}Usage${GREEN}: run_wait \"<COMMAND>\" <INTERVAL>${NC}"
      ;;
    "nodeCount")
      echo "I count the number of nodes in a Kubernetes cluster"
      echo "${PURPLE}Usage${GREEN}: nodeCount <ENVIRONMENT>${NC}"
      ;;
    "podCheck")
      echo "I check the pods in a Kubernetes cluster and show the pods that are not running or completed"
      echo "${PURPLE}Usage${GREEN}: podCheck <ENVIRONMENT>${NC}"
      ;;
    "podClean")
      echo "I clean up the pods in a Kubernetes cluster"
      echo "${PURPLE}Usage${GREEN}: podClean${NC}"
      echo "Pass through the <ENVIRONMENT> and <NAMESPACE> if you don't want to use the current context or namespace"
      echo "${PURPLE}Usage${GREEN}: podClean <ENVIRONMENT> <NAMESPACE>${NC}"
      ;;
    "vmLogs")
      echo "I get the logs for a VM"
      echo "${PURPLE}Usage${GREEN}: vmLogs${NC}"
      echo "Pass through the 'follow' or 'f' to follow the logs"
      echo "${PURPLE}Usage${GREEN}: vmLogs f${NC}"
      ;;
    "vmCheck")
      echo "I help put the URLs together for the VM Status Check"
      echo "${PURPLE}Usage${GREEN}: vmCheck${NC}"
      echo "Pass through the <All the IPs> if needed"
      echo "${PURPLE}Usage${GREEN}: vmCheck <IPs>${NC}"
      ;;
    "natGateways")
      echo "I list the NAT Gateways in AWS for all or specified profiles"
      echo "${PURPLE}Usage${GREEN}: natGateways${NC}"
      echo "Pass through the <AWS Profiles> if you don't want to go through all profiles"
      echo "${PURPLE}Usage${GREEN}: natGateways <PROFILE1> <PROFILE2> ...${NC}"
      ;;
    "aws_sso_session")
      echo "I check the AWS SSO login session for current profile"
      echo "${PURPLE}Usage${GREEN}: aws_sso_session${NC}"
      ;;
    "ghistory")
      echo "I get the git history for you"
      echo "${PURPLE}Usage${GREEN}: ghistory${NC}"
      echo "Pass through the the number of days you'd like me to go back"
      echo "${PURPLE}Usage${GREEN}: ghistory 7${NC}"
    ;;
    "html-live")
      echo "I start a live server for HTML files"
      echo "${PURPLE}Usage${GREEN}: html-live${NC}"
      echo "Pass through the <PORT> if you don't want to use the default port"
      echo "${PURPLE}Usage${GREEN}: html-live <PORT>${NC}"
      echo "Pass through the <DIRECTORY> if you don't want to use the current directory"
      echo "${PURPLE}Usage${GREEN}: html-live <PORT> <DIRECTORY>${NC}"
      ;;
    "downloadVideo")
      echo "I download a video from a URL using yt-dlp"
      echo "${PURPLE}Usage${GREEN}: downloadVideo <URL>${NC}"
      ;;
    "glock")
      echo "I lock the screen"
      echo "${PURPLE}Usage${GREEN}: glock${NC}"
      ;;
    "whoareyou")
      echo "Ohh I know 🤔"
      whoareyou
      echo "Otherwise pass me a name"
      echo "whoareyou <NAME>"
      ;;
    "dabble")
      figlet 👌abble
      ;;
    esac
  fi
}
