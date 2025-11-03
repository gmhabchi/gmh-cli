#!/bin/bash

cleanNumber() {
   # Remove the +61
  return "0${number}"
}

error() {
  echo "${RED}ERROR${NC}: $1"
}

info() {
  echo "${GREEN}INFO${NC}: $1"
}

AWS_ENVIRONMENTS=(staging staging-internal staging-us staging-internal-us staging-uk staging-internal-uk production production-internal production-us production-internal-us production-uk production-internal-uk)