#!/usr/bin/env zsh
# Zsh completion for gmh-cli functions

# Skip if not in zsh
[[ -n "$ZSH_VERSION" ]] || return 0

# Ensure compinit is loaded
if ! command -v compdef >/dev/null 2>&1; then
  # Completion system not loaded yet, initialize it
  autoload -Uz compinit
  compinit -u
fi

# Environment names
_gmh_envs=(
  staging staging-us staging-uk
  production production-us production-uk
  staging-internal staging-internal-us staging-internal-uk
  production-internal production-internal-us production-internal-uk
)

# Pulumi environments
_gmh_pulumi_envs=(dabble internal root)

# dockerKill completion
_dockerKill_zsh() {
  _arguments '1:action:(all main)'
}

# Environment completion helper
_gmh_env_zsh() {
  _values 'environment' $_gmh_envs
}

# podCheck completion
_podCheck_zsh() {
  _gmh_env_zsh
}

# jobCheck completion
_jobCheck_zsh() {
  _gmh_env_zsh
}

# podClean completion
_podClean_zsh() {
  case $CURRENT in
    2)
      _gmh_env_zsh
      ;;
    3)
      # If second arg was an environment, suggest namespaces
      if (( ${_gmh_envs[(I)${words[2]}]} )); then
        local namespaces
        namespaces=(${(f)"$(kubectl get namespaces --context "${words[2]}/main" 2>/dev/null | awk 'NR>1 {print $1}')"})
        _values 'namespace' $namespaces
      fi
      ;;
  esac
}

# jobClean completion
_jobClean_zsh() {
  _podClean_zsh
}

# nodeCount completion
_nodeCount_zsh() {
  _gmh_env_zsh
}

# penv completion
_penv_zsh() {
  _values 'environment' $_gmh_pulumi_envs
}

# pstack completion
_pstack_zsh() {
  _gmh_env_zsh
}

# psecrets completion
_psecrets_zsh() {
  _gmh_env_zsh
}

# cognito_search completion
_cognito_search_zsh() {
  case $CURRENT in
    2)
      _message 'phone number'
      ;;
    3)
      _values 'environment or count' $_gmh_envs count
      ;;
    4)
      _values 'count' count
      ;;
  esac
}

# kubectl_secrets completion
_kubectl_secrets_zsh() {
  case $CURRENT in
    2)
      _message 'secret name'
      ;;
    3)
      _gmh_env_zsh
      ;;
    4)
      if (( ${_gmh_envs[(I)${words[3]}]} )); then
        local namespaces
        namespaces=(${(f)"$(kubectl get namespaces --context "${words[3]}/main" 2>/dev/null | awk 'NR>1 {print $1}')"})
        _values 'namespace' $namespaces
      fi
      ;;
  esac
}

# vmLogs completion
_vmLogs_zsh() {
  _arguments '1:follow:(follow f)'
}

# airflow_pod_clean completion
_airflow_pod_clean_zsh() {
  case $CURRENT in
    2)
      _values 'action' list delete help
      ;;
    3)
      _values 'environment' staging production
      ;;
  esac
}

# fathomDB completion
_fathomDB_zsh() {
  _gmh_env_zsh
}

# kuttle_init completion
_kuttle_init_zsh() {
  _values 'environment' production-internal staging-internal
}

# natGateways completion
_natGateways_zsh() {
  local profiles
  profiles=(${(f)"$(aws configure list-profiles 2>/dev/null)"})
  if [ ${#profiles[@]} -gt 0 ]; then
    _values 'AWS profile' $profiles
  fi
}

# ghelp completion
_ghelp_zsh() {
  _values 'function' \
    whoareyou aws-login alogin glogin plogin pdelete lnetwork \
    dockerKill dockerStop dockerCheck fathomDB kuttle_init \
    airflow_pod_clean PWgen git_update_dir cognito_search \
    kubectl_secrets pstack penv psecrets nodeCount podCheck \
    jobCheck podClean jobClean vmLogs logsCronjob vmCheck \
    natGateways html-live downloadVideo aws_sso_session \
    ghistory glock gbright ginstall
}

# html-live completion
_html_live_zsh() {
  case $CURRENT in
    2)
      _values 'port' 8080 3000 5000 8000
      ;;
    3)
      _directories
      ;;
  esac
}

# PWgen completion
_PWgen_zsh() {
  case $CURRENT in
    2)
      _values 'length or mode' simple 12 16 20 24 32
      ;;
    3)
      _values 'mode' simple
      ;;
  esac
}

# downloadVideo completion
_downloadVideo_zsh() {
  _message 'video URL'
}

# ghistory completion
_ghistory_zsh() {
  _message 'days ago (default: 1)'
}

# whoareyou completion
_whoareyou_zsh() {
  _message 'name (optional)'
}

# git_update_dir completion
_git_update_dir_zsh() {
  _directories
}

# Register completions
compdef _dockerKill_zsh dockerKill
compdef _podCheck_zsh podCheck
compdef _jobCheck_zsh jobCheck
compdef _podClean_zsh podClean
compdef _jobClean_zsh jobClean
compdef _nodeCount_zsh nodeCount
compdef _penv_zsh penv
compdef _pstack_zsh pstack
compdef _psecrets_zsh psecrets
compdef _cognito_search_zsh cognito_search
compdef _kubectl_secrets_zsh kubectl_secrets
compdef _vmLogs_zsh vmLogs
compdef _airflow_pod_clean_zsh airflow_pod_clean
compdef _fathomDB_zsh fathomDB
compdef _kuttle_init_zsh kuttle_init
compdef _natGateways_zsh natGateways
compdef _ghelp_zsh ghelp
compdef _html_live_zsh html-live
compdef _PWgen_zsh PWgen
compdef _downloadVideo_zsh downloadVideo
compdef _ghistory_zsh ghistory
compdef _whoareyou_zsh whoareyou
compdef _git_update_dir_zsh git_update_dir

# Simple completions
compdef _gmh_env_zsh alogin aws-login glogin
