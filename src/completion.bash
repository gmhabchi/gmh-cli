#!/bin/bash
# Bash completion script for gmh-cli functions

# Get list of all available functions
_gmh_functions="
whoareyou
aws-login
alogin
glogin
plogin
pdelete
lnetwork
dockerKill
dockerStop
dockerCheck
fathomDB
kuttle_init
airflow_pod_clean
PWgen
git_update_dir
cognito_search
kubectl_secrets
pstack
penv
psecrets
nodeCount
podCheck
jobCheck
podClean
jobClean
vmLogs
logsCronjob
vmCheck
natGateways
html-live
downloadVideo
aws_sso_session
ghistory
glock
gbright
ginstall
ghelp
"

# Environment names
_gmh_envs="
staging
staging-us
staging-uk
production
production-us
production-uk
staging-internal
staging-internal-us
staging-internal-uk
production-internal
production-internal-us
production-internal-uk
"

# Pulumi environments
_gmh_pulumi_envs="dabble internal root"

# dockerKill completion
_dockerKill_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "all main" -- "$cur"))
}

# Environment-aware completions
_env_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "$_gmh_envs" -- "$cur"))
}

# podCheck completion
_podCheck_complete() {
    _env_complete
}

# jobCheck completion
_jobCheck_complete() {
    _env_complete
}

# podClean completion - supports both env and namespace
_podClean_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    # If previous word was a full environment name, suggest namespaces
    if [[ "$prev" =~ ^(staging|staging-internal|staging-us|staging-internal-us|staging-uk|staging-internal-uk|production|production-internal|production-us|production-internal-us|production-uk|production-internal-uk)$ ]]; then
        # Get namespaces from current context (if kubectl is available)
        if command -v kubectl &> /dev/null; then
            local namespaces=$(kubectl get namespaces --context "$prev/main" 2>/dev/null | awk 'NR>1 {print $1}')
            COMPREPLY=($(compgen -W "$namespaces" -- "$cur"))
        fi
    else
        _env_complete
    fi
}

# jobClean completion - same as podClean
_jobClean_complete() {
    _podClean_complete
}

# nodeCount completion
_nodeCount_complete() {
    _env_complete
}

# penv completion (pulumi environments)
_penv_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "$_gmh_pulumi_envs" -- "$cur"))
}

# pstack completion (environments)
_pstack_complete() {
    _env_complete
}

# psecrets completion
_psecrets_complete() {
    _env_complete
}

# cognito_search completion
_cognito_search_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    # If we're on the second argument (after phone number), suggest environments
    if [[ $COMP_CWORD -eq 2 ]]; then
        COMPREPLY=($(compgen -W "$_gmh_full_envs count" -- "$cur"))
    elif [[ $COMP_CWORD -eq 3 ]]; then
        COMPREPLY=($(compgen -W "count" -- "$cur"))
    fi
}

# kubectl_secrets completion
_kubectl_secrets_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ $COMP_CWORD -eq 2 ]]; then
        # Second arg: environment
        _env_complete
    elif [[ $COMP_CWORD -eq 3 ]]; then
        # Third arg: namespace
        if command -v kubectl &> /dev/null; then
            local env="${COMP_WORDS[2]}"
            local namespaces=$(kubectl get namespaces --context "$env/main" 2>/dev/null | awk 'NR>1 {print $1}')
            COMPREPLY=($(compgen -W "$namespaces" -- "$cur"))
        fi
    fi
}

# vmLogs completion
_vmLogs_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "follow f" -- "$cur"))
}

# airflow_pod_clean completion
_airflow_pod_clean_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=($(compgen -W "list delete help" -- "$cur"))
    elif [[ $COMP_CWORD -eq 2 ]]; then
        COMPREPLY=($(compgen -W "staging production" -- "$cur"))
    fi
}

# fathomDB completion
_fathomDB_complete() {
    _env_complete
}

# kuttle_init completion
_kuttle_init_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "production-internal staging-internal" -- "$cur"))
}

# natGateways completion - suggest AWS profiles
_natGateways_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    # Suggest common AWS profile names
    local profiles=$(aws configure list-profiles 2>/dev/null)
    if [[ -n "$profiles" ]]; then
        COMPREPLY=($(compgen -W "$profiles" -- "$cur"))
    fi
}

# ghelp completion - suggest all function names
_ghelp_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "$_gmh_functions" -- "$cur"))
}

# html-live completion - suggest common ports and directories
_html_live_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=($(compgen -W "8080 3000 5000 8000" -- "$cur"))
    elif [[ $COMP_CWORD -eq 2 ]]; then
        # Directory completion
        COMPREPLY=($(compgen -d -- "$cur"))
    fi
}

# PWgen completion
_PWgen_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=($(compgen -W "simple 12 16 20 24 32" -- "$cur"))
    elif [[ $COMP_CWORD -eq 2 ]]; then
        COMPREPLY=($(compgen -W "simple" -- "$cur"))
    fi
}

# Register completions for each function
complete -F _dockerKill_complete dockerKill
complete -F _podCheck_complete podCheck
complete -F _jobCheck_complete jobCheck
complete -F _podClean_complete podClean
complete -F _jobClean_complete jobClean
complete -F _nodeCount_complete nodeCount
complete -F _penv_complete penv
complete -F _pstack_complete pstack
complete -F _psecrets_complete psecrets
complete -F _cognito_search_complete cognito_search
complete -F _kubectl_secrets_complete kubectl_secrets
complete -F _vmLogs_complete vmLogs
complete -F _airflow_pod_clean_complete airflow_pod_clean
complete -F _fathomDB_complete fathomDB
complete -F _kuttle_init_complete kuttle_init
complete -F _natGateways_complete natGateways
complete -F _ghelp_complete ghelp
complete -F _html_live_complete html-live
complete -F _PWgen_complete PWgen

# Basic completions for functions that don't need custom logic
complete -W "$_gmh_envs" aws-login alogin glogin
