#!/bin/bash

# Environments
staging=(staging staging-internal)
staging_us=(staging-us staging-internal-us)
staging_uk=(staging-uk staging-internal-uk)
production=(production production-internal)
production_us=(production-us production-internal-us)

if [ "${#arg[@]}" -eq 0 ]; then
    environments=("${staging[@]}" "${staging_us[@]}" "${staging_uk[@]}" "${production[@]}" "${production_us[@]}")
elif [ "${#arg[@]}" -eq 1 ]; then
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

envCheck() {
    local arg=("$@")
    if [ "${#arg[@]}" -eq 0 ]; then
        environments=("${staging[@]}" "${staging_us[@]}" "${staging_uk[@]}" "${production[@]}" "${production_us[@]}")
    elif [ "${#arg[@]}" -eq 1 ]; then
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

    echo "${environments[@]}"
}
