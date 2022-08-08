#!/bin/bash
#-----------------------------------------------------------------------
# Copyright (c) 2022, Andrew Turpin
# License MIT: https://opensource.org/licenses/MIT
#-----------------------------------------------------------------------

# Globals
_version="0.1"
_configPath="/home/$USER/.local/share/qed/"
_configFile="/home/$USER/.local/share/qed/qed.conf"
_here=$(pwd)
_currentDate="$(date +%Y%m%d-%H%M)"
_userName="$(git config --get user.name)"
_Email="$(git config --get user.email)"
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
    echo "    -i, --init      initialises ~/.qed.conf with a specific github username & key path";
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
    echo "   qed --config";
    echo "          will display the configuration information";
    echo "";
    echo "   qed -e [counterparty-github-username] [plaintext]";
    echo "          encrypt (with counter party public key) and sign (with your private key) plaintext";
    echo "";
    echo "   qed -d [counterparty-github-username] [cyphertext]";
    echo "          decrypt (with your private key) and verify signature (with counterparty public key) of cyphertext";
    echo "";
    echo "  UNINSTALL:";
    echo "   qed-remove will completely remove all vestiges of qed that were installed with qed-install";
    echo "";
}

function selectPublicKey(){
  github_id=$1
  curl -s https://github.com/$github_id.keys > tmp.pub

  # randomly select one of the RSA keys
  numKeys=$(( $(cat tmp.pub | grep ssh-rsa | wc -l) ))
  if [ $numKeys -gt 0 ]; then
    keyNum=$(expr 1 + $RANDOM % $numKeys)
    rndPub=$(sed "${keyNum}q;d" tmp.pub)
    if [ "$rndPub" == "" ]; then $error="no keys found"; fi;
  else
     error="no keys found"
  fi
  if [ "$error" != "" ]; then  # no RSA keys found
    echo "ERROR: no valid public keys found for $github-id."
    exit 1
  fi
  # else return selected public key in PKCS8 format
  echo $rndPub > tmp.pubkey
  local publicKey=$(ssh-keygen -e -f tmp.pubkey -m pkcs8)
  echo $publicKey;
  rm tmp.*
}

function findPrivateKey(){
  local publicKey="$1"
  # given any publicKey for OWN repo
  # iterate through avialable private keys
  while read F; 
  do 
    echo $F;
    # openssl dgst -sha256 -sign $F -out tmp.signature - < <(echo '12345678asfvasfvXCvXCXCbvXCV') &> /dev/null
    # result=$(openssl dgst -sha256 -verify tmp.pubkey -signature tmp.signature - < <(echo '12345678asfvasfvXCvXCXCbvXCV'))
    # if [ "$result"=="Verified OK" ]; then
    #   echo "$F"
    #   exit 0
    # fi
  done < <(shopt -s extglob && cd ~/.ssh && ls -d !(*.*) -l -f | grep id_)

  # sign known_random_string 
  # verify with publickKey
  # if verified then we have found the associated privateKey
  # return name of associated private key or ""
  echo "";
  exit 1;
}

function createCipherText(){
  # given github username of recipient-id
  # given plaintext message
  # given github username of sender-id
  # selectPublicKey of recipient-id
  # selectPublicKey of sender-id
  # findPrivateKey of sender-id
  # generate 32 byte key
  # generate 32 byte salt
  # generate dgst (plainText |privateKey of sender-id) (fixed length/padded)
  # cipherText = AES encrypt (plainText + dgst | key, salt)
  # encKey = RSA encrypt(key | publicKey of Recipient-id) + pad (2048)
  # cipherText = cipherText + encKey + salt + sender-id + len[sender-id:2 bytes]
  # cipherText=base64(cipherText)
  # return cipherText.b64
  echo "";
}

function createPlainText(){
  # given cipherText.b64
  # given github username of sender-id
  # given the github username of recipient-id
  # cipherText = base64 -d cipherText.b64
  # len-sender-id = len[:2]
  # sender-id = cut (len - len[]:2] bytes)
  # selectPublicKey of sender-id
  # salt = cut (32 bytes from end before sender-id)
  # encKey = cut (2048 bits from end before salt) 
  # key = RSA decrypt (encKey | privateKey of Recipient-id) & figure out padding
  # plainText = AES decrypt (cipherText | key,salt)
  # dgst = cut (32 bytes from end of plaintext) & figure out padding
  # plainText = cut (lhs up to digest)
  # verify dgst(plaintext, publicKey of sender-id)
  # if ?$=0 then return plainText
  # else return "" error msg not to be trusted
  echo "";
}

function displayVersion(){
    echo "qed version $_version";
    echo "Copyright (C) 2022, Cyber-Mint (Pty) Ltd";
    echo "License MIT: https://opensource.org/licenses/MIT";
    echo "";
}

function displayConfig(){
  # get default github username
  # confirm RSA public key exists
  # confirm associated private key can be found
  echo "Validating configuration ..."
  if [ "$_userName" != "" ]; then
    echo "[x] default github username found : $_userName"
    publicKey=$(selectPublicKey ${_userName})
    echo $publicKey > tmp.publicKey

    if [ "publicKey" == "" ]; then
      echo "[ ] no valid RSA public key(s) found for $_userName."
      exit 1
    else  
      echo "[x] valid RSA public key(s) found at github.com"
      
      privateKey=$(findPrivateKey "tmp.publickey" )
      if [ "$privateKey" != "" ]; then
        echo "[x] valid associated RSA private key(s) found locally: $privateKey"
        echo "---"
        exit 0
      else
        echo "[ ] no valid associated RSA private found locally"
        exit 1  
      fi
    fi
  else
    echo "[ ] default github username found :";
    echo "";
    echo "Tip: try the following to configure git.."
    echo "  git config --global user.name <username>";
    echo "  git config --global user.email '<email>' "
    echo "  git config --global color.ui auto"
    echo "  ssh -T git@github.com"
    exit 1;
  fi


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
        --config) 
            displayConfig; exit 0;;
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