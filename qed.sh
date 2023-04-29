#!/bin/bash
#-----------------------------------------------------------------------
# Copyright (c) 2022, Andrew Turpin
# License MIT: https://opensource.org/licenses/MIT
#-----------------------------------------------------------------------

# Globals
_version="0.1"
_configPath="/home/$USER/.local/share/qed"
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

function fetchPublicKeys(){
  #---------------
  # selectPublicKey [github-username]
  #    * fetch the public keys for the github user
  #    * return an array of any ssh-rsa keys
  # Copyright 2022, Cyber-Mint (Pty)Ltd   
  #---------------
  github_id=$1
  delimiter="ssh"
  found=$(curl -s https://github.com/$github_id.keys)
  
  keys=()
  parts=$(echo "$found" | awk -v RS="-$delimiter-" '{print $0}')
  prefix=""
  for part in $parts;do 
    if [[ "$part" == *"ssh"* ]]; then 
      prefix="$part";
    else #add the key only if it is an ssh key
      if [[ $prefix == *"ssh-rsa"* ]]; then keys+=("$prefix $part");fi;
      prefix="";
    fi;  
  done;

  if [ ${#keys[@]} -gt 0 ]; then
    echo ${keys[@]} # RETURN the keys()
    exit 0
  else
    echo "RSA SSH Keys Not Found!"
    exit 1
  fi
}

function selectPublicKey(){
  #---------------
  # selectPublicKey [array-of-rsa-keys]
  #    * returns a random key from an array of RSA keys
  # Copyright 2022, Cyber-Mint (Pty)Ltd   
  #---------------  
  keys=$1
  numKeys=((${#keys[@]}))

  if [[ $numKeys -gt 0 ]];then
    rndPub=${keys[expr 1 + $RANDOM % $numKeys]}
    # we return selected public key in PKCS8 format
    echo $rndPub > tmp.pub
    ssh-keygen -e -f tmp.pub -m pkcs8 > tmp.publicKey
    if [ $? -eq 0 ]; then # no errors generating PKCS8 pubkey format
      rm tmp.pub
      echo $(cat ./tmp.publicKey)
      exit 0
    else
      echo ""
      exit 1  
    fi
  fi
}

function findPrivateKey(){
  # given a tmp.publicKey for OWN repo
  # iterate through avialable private keys
  rm -rf  $_configPath/.ssh/
  mkdir -p $_configPath/.ssh
  while read F; 
  do
    cp ~/.ssh/$F $_configPath/.ssh/$F
    chmod u=rw $_configPath/.ssh/$F

    ssh-keygen -p -m PKCS8 -f $_configPath/.ssh/$F -q -N "" &> /dev/null
    if [ $? -eq 0 ]; then
      openssl dgst -sha256 -sign $_configPath/.ssh/$F -out tmp.signature - < <(echo '12345678asfvasfvXCvXCXCbvXCV') &> /dev/null
      if [ $? -eq 0 ]; then  
        openssl dgst -sha256 -verify tmp.publicKey -signature tmp.signature - < <(echo '12345678asfvasfvXCvXCXCbvXCV') &> /dev/null 
        if [ $? -eq 0 ]; then
          echo "$F"
          exit 0
        fi
      fi
    else
      # do nothing
      sleep 1  
    fi
  done < <(find ~/.ssh/id_*  -maxdepth 1 -type f -printf "%f\n" | grep -v .pub)

  # sign known_random_string 
  # verify with publicKey
  # if verified then we have found the associated privateKey
  # return name of associated private key or ""
  exit 1
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
    
    if [ "$publicKey" == "Not Found" ]; then
      echo "[ ] no valid RSA public key(s) found for $_userName."

      rm tmp.* && exit 1
    else  
      echo "[x] valid RSA public key(s) found at github.com"
      
      privateKey=$(findPrivateKey "tmp.publicKey" )
      if [ "$privateKey" == "" ]; then
        echo "[ ] no valid associated RSA private found locally"
        rm tmp.* && exit 1
      else  
        echo "[x] valid associated RSA private key(s) found locally: $privateKey"
        echo "---"
        rm tmp.* && exit 0
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
    rm tmp.* && exit 1
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