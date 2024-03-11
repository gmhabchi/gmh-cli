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