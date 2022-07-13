#!/bin/bash
#-----------------------------------------------------------------------
# Copyright (c) 2022, Andrew Turpin
# License MIT: https://opensource.org/licenses/MIT
#-----------------------------------------------------------------------

# Globals
_version="0.1"
_configFile="/home/$USER/.local/share/qed/qed.conf"
_here=$(pwd)
_currentDate="$(date +%Y%m%d-%H%M)"
_localUsername="$(git config --get user.name)"
_localEmail="$(git config --get user.email)"
_localKeyPath="~/.ssh"
_localKey="id_rsa"
_counterparty=""
_counterpartyEmail=""
_counterpartyUsername=""
_counterpartyKey=""

function displayHelp(){
    echo "Usage: qed [OPTION]";
    echo "   a easy to use tool to encrypt/decrypt data using";
    echo "   github associated private & public ssh keys.";
    echo "";
    echo "  OPTIONS:";
    echo "    -i, --init      initialises qed.conf with a specific github username & key path";
    echo "    -u, --username  specify a non-default sender username";
    echo "        --help      display this help and exit";
    echo "        --version   display version and exit";
    echo "";
    echo "";
    echo "  EXAMPLE(s):";
    echo "   qed --init [your-github-username] [path-to-ssh-keys]";
    echo "          create/update the .qed.conf with your required information";
    echo "          [your-github-username] defaults to git config --get user.name";
    echo "          [path-to-ssh-keys] defaults to ~/.ssh";
    echo "          eg. --init bank-builder ~/.ssh";
    echo "       Note: if a .conf file does not exist then upon first use default values will be configured";
    echo "";
    echo "   qed -e [counterparty-github-username] [plaintext]";
    echo "          encrypt (with counter party public key) and sign (with your private key) plaintext";
    echo "";
    echo "   qed -d [counterparty-github-username] [cyphertext]";
    echo "          decrypt (with your private key) and verify signature (with counterparty public key) of cyphertext";
    echo "";
}


function displayVersion(){
    echo "qed version $_version";
    echo "Copyright (C) 2022, Cyber-Mint (Pty) Ltd";
    echo "License MIT: https://opensource.org/licenses/MIT";
    echo "";
}

function trim(){
    echo $1 | xargs
}


function cleanSchemaCreate(){
  for filename in $1/*.sql; do
    msg "checking $filename"
    sed -i 's/CREATE SCHEMA/-- CREATE SCHEMA/g' $filename
    sed -i 's/DROP SCHEMA/-- DROP SCHEMA/g' $filename
  done
}

function processConfig(){
 conf="$1"
 counterparty="$2"
 IFS=$'\n'  # make newlines the only separator

 #for line in $(cat $conf)
 while read line 
 do
  line=$(trim $line)
  confLabel=$( echo "$line" |cut -d'=' -f1 );
  confValue=$( echo "$line" |cut -d'=' -f2 ); 
  if [[ ${confLabel:0:1} != "#" ]] ; then #not a comment nor a blank line

    tmp=${confLabel#*[}   # remove prefix ending in "["
    section=${tmp%]*}     # remove suffix starting with "]"

    if [ "$confLabel" == "[$section]" ]; then # [section] header
          
      header=$( echo "$section" |cut -d':' -f1 );
      party=$( echo "$section" |cut -d':' -f2 );
    
    else # label=value

      if [ "$header" == "github" ] && [ "$party" == $counterparty]; then
        if [ "$confLabel" == "source" ] && [ "$confValue" != "" ]; then
          _counterpartykey=$("curl -s $confValue | head -n 1")  # just use the first public key found
        fi
        # set all the required values for the encryption/decryption here
      fi    
        
    fi;
  fi;   
 
 done < $conf
 #done
 
}

# __Main__
while [[ "$#" > 0 ]]; do
    case $1 in
        --help) 
            displayHelp; exit 0;;
        --version) 
            displayVersion; exit 0;;
        -i|--init) 
            _localUsername="$2";
            _localKeypath="$3";
            shift;;
        -e|--esign) 
            _counterpartyUsername="$2";
            _plainText="$3";
            shift;;
        -d|--dsign) 
            _counterpartyUsername="$2";
            _cypherText="$3";
            shift;; 
         *) echo "Unknown parameter passed: $1"; exit 1;;
    esac; 
    shift; 
done

if [ -n "$_configFile" ]; then
  processConfig $_configFile
fi  




echo "Try qed --help for help";
echo "";
#FINISH