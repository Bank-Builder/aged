#!/bin/bash


# test regex on input of github Username

CHECK="bank-builder"
validUsername="$(echo $CHECK | grep -P -i '^[a-z0-9][a-z0-9-]+[a-z0-9]$')"

if [[ ! $validUsername ]]; then
    echo "Invalid Github Username"
else 
    echo "Valid Github Username"
fi


