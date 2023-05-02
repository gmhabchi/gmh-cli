#!/bin/bash

# G Help
ghelp() {
  if [ -z "$1" ]; then
    figlet 👌abble
    echo "${RED}ghelp${NC}: Helpy CLI"
    echo "${PURPLE}Usage${GREEN}: ghelp <command>"
    echo "${PURPLE}Example${GREEN}: ghelp aws-login${NC}"
    echo ""
    echo "${RED}alogin${NC}/${RED}aws-login${NC}: Login to AWS"
    echo "${RED}plogin${NC}: Login to Pulumi Project with pnpm 👌"
    echo "${RED}kuttle_init${NC}: Initialize kuttle"
    echo "${RED}git_update_dir${NC}: Update all repos in a directory"
    echo "${RED}pdelete <S3 PATH>${NC}: Delete Pulumi Lock file from S3"
    echo "${RED}lnetwork${NC}: Find network devices"
    echo "${RED}dockerKill${NC}: Stop and Delete all images created locally or just Stop Docker from running"
    echo "${RED}fathomDB${NC}: Update FathomDB permissions"
    echo "${RED}dockerCheck${NC}: Checks that Docker is running locally and will start if it isn't"
    echo "${RED}cognito_search${NC}: Search Cognito for phone_number"
    echo "${RED}kubectl_secrets <NAME> <ENV>${NC}: Get Kubernetes secrets 🤫"
    echo "${RED}pstack <ENV>${NC}: I change the pulumi stack for you based on the directory you're in"
    echo "${RED}penv <ENV>${NC}: I change the pulumi environment for you"
    echo "${RED}glock${NC}: I lock the screen for you"
    echo "${RED}whoareyou${NC}: I tell you who you are 👍"
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
      echo "${PURPLE}Usage${GREEN}: kubectl_secrets <NAME> <ENVIRONMENT>${NC}"
      echo "Pass through the <SECRET_NAME> if its not the same as the NAMESPACE"
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
