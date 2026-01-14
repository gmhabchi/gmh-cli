#!/bin/bash

# G Help
ghelp() {
  if [ -z "$1" ]; then
    figlet GHelp
    echo -e "${RED}ghelp${NC}: Helpy CLI"
    echo -e "${PURPLE}Usage${GREEN}: ghelp <command>"
    echo -e "${PURPLE}Example${GREEN}: ghelp aws-login${NC}"
    echo ""
    echo -e "${GREEN}AWS${NC}"
    echo -e "  ${RED}alogin${NC}/${RED}aws-login${NC}: Login to AWS CLI"
    echo -e "  ${RED}glogin${NC}: Login to AWS CLI for personal AWS account"
    echo -e "  ${RED}aws_sso_session${NC}: Check AWS SSO login session status"
    echo -e "  ${RED}cognito_search${NC}: Search AWS Cognito for a user by phone_number"
    echo -e "  ${RED}natGateways${NC}: List NAT Gateways in AWS"
    echo ""
    echo -e "${GREEN}Kubernetes${NC}"
    echo -e "  ${RED}nodeCount${NC}: Count nodes in a Kubernetes cluster"
    echo -e "  ${RED}podCheck${NC}: Check for non-running or non-completed pods"
    echo -e "  ${RED}podClean${NC}: Clean up failed/errored pods"
    echo -e "  ${RED}jobCheck${NC}: Check for failed jobs"
    echo -e "  ${RED}jobClean${NC}: Clean up failed jobs"
    echo -e "  ${RED}kubectl_secrets <NAME> <ENV>${NC}: Get and decrypt secrets"
    echo -e "  ${RED}kuttle_init${NC}: Initialize kuttle network tunnel"
    echo -e "  ${RED}vmLogs${NC}: Get VictoriaMetrics agent logs"
    echo -e "  ${RED}vmCheck${NC}: Check VM targets for failed scrapes"
    echo ""
    echo -e "${GREEN}Pulumi${NC}"
    echo -e "  ${RED}plogin${NC}: Login to Pulumi project"
    echo -e "  ${RED}penv <ENV>${NC}: Change Pulumi login environment"
    echo -e "  ${RED}pstack <ENV>${NC}: Change Pulumi stack based on directory"
    echo -e "  ${RED}psecrets${NC}: Show and decrypt Pulumi secrets"
    echo -e "  ${RED}pdelete <S3 PATH>${NC}: Delete Pulumi lock file from S3"
    echo ""
    echo -e "${GREEN}Dabble${NC}"
    echo -e "  ${RED}fathomDB${NC}: Update FathomDB permissions"
    echo -e "  ${RED}airflow_pod_clean${NC}: List or clean Airflow failed pods"
    echo ""
    echo -e "${GREEN}Docker${NC}"
    echo -e "  ${RED}dockerKill${NC}: Stop and remove containers or kill Docker/OrbStack"
    echo -e "  ${RED}dockerStop${NC}: Stop OrbStack"
    echo -e "  ${RED}dockerCheck${NC}: Check and start OrbStack if not running"
    echo ""
    echo -e "${GREEN}Utilities${NC}"
    echo -e "  ${RED}ghistory${NC}: Show shell history from N days ago"
    echo -e "  ${RED}glock${NC}: Lock the Mac screen"
    echo -e "  ${RED}gbright${NC}: Set screen brightness to 100%"
    echo -e "  ${RED}html-live${NC}: Start a local HTTP server"
    echo -e "  ${RED}downloadVideo${NC}: Download video using yt-dlp"
    echo -e "  ${RED}PWgen${NC}: Generate UUID and copy to clipboard"
    echo -e "  ${RED}whoareyou${NC}: Display current user identity"
    echo -e "  ${RED}git_update_dir${NC}: Pull latest master for all repos in directory"
    echo -e "  ${RED}lnetwork${NC}: List network devices using ARP"
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
    "nodeCount")
      echo "I count the number of nodes in a Kubernetes cluster"
      echo "${PURPLE}Usage${GREEN}: nodeCount <ENVIRONMENT>${NC}"
      ;;
    "podCheck")
      echo "I check for non-running/non-completed pods across environments"
      echo "${PURPLE}Usage${GREEN}: podCheck${NC} - Check all environments"
      echo "${PURPLE}Usage${GREEN}: podCheck stg${NC} - Check staging environments"
      echo "${PURPLE}Usage${GREEN}: podCheck <ENVIRONMENT>${NC} - Check specific environment"
      ;;
    "podClean")
      echo "I clean up failed/errored pods across environments"
      echo "${PURPLE}Usage${GREEN}: podClean${NC} - Clean all environments"
      echo "${PURPLE}Usage${GREEN}: podClean stg${NC} - Clean staging environments"
      echo "${PURPLE}Usage${GREEN}: podClean <ENVIRONMENT>${NC} - Clean specific environment"
      echo "${PURPLE}Usage${GREEN}: podClean <ENVIRONMENT> <NAMESPACE>${NC} - Clean specific namespace"
      ;;
    "jobCheck")
      echo "I check for failed jobs across environments"
      echo "${PURPLE}Usage${GREEN}: jobCheck${NC} - Check all environments"
      echo "${PURPLE}Usage${GREEN}: jobCheck stg${NC} - Check staging environments"
      echo "${PURPLE}Usage${GREEN}: jobCheck <ENVIRONMENT>${NC} - Check specific environment"
      ;;
    "jobClean")
      echo "I clean up failed jobs across environments"
      echo "${PURPLE}Usage${GREEN}: jobClean${NC} - Clean all environments"
      echo "${PURPLE}Usage${GREEN}: jobClean stg${NC} - Clean staging environments"
      echo "${PURPLE}Usage${GREEN}: jobClean <ENVIRONMENT>${NC} - Clean specific environment"
      echo "${PURPLE}Usage${GREEN}: jobClean <ENVIRONMENT> <NAMESPACE>${NC} - Clean specific namespace"
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
      echo "I get the shell history for you"
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
    "airflow_pod_clean")
      echo "I list or clean Airflow failed pods (legacy - consider using podClean)"
      echo "${PURPLE}Usage${GREEN}: airflow_pod_clean${NC} - List pods in staging airflow"
      echo "${PURPLE}Usage${GREEN}: airflow_pod_clean list <ENV>${NC} - List pods"
      echo "${PURPLE}Usage${GREEN}: airflow_pod_clean delete <ENV>${NC} - Delete failed pods"
      echo "${PURPLE}Usage${GREEN}: airflow_pod_clean help${NC} - Show help"
      echo ""
      echo "${PURPLE}Recommended alternative${GREEN}: podClean <ENV>-internal airflow${NC}"
      ;;
    esac
  fi
}
