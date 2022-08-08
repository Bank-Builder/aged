#!/bin/bash


# test regex on input of github Username

CHECK="bank-builder"
validUsername="$(echo $CHECK | grep -P -i '^[a-z0-9][a-z0-9-]+[a-z0-9]$')"

if [[ ! $validUsername ]]; then
    echo "Invalid Github Username"
else 
    echo "Valid Github Username"
fi


# get sha256sum of a file
sha256sum README.md | awk '{print $1}'

# wc-c is 65


  curl https://github.com/bank-builder.keys > bb.pub
  nano bb1.key
  nano plaintext.txt

  curl https://github.com/bank-builder.keys > bb.keys

  ssh-keygen -e -f bb.keys -m pem > bb.pem

  cat bb.pem 
 
  ssh-keygen -e -f ~/.ssh/id_bb.pub -m pkcs8 > bb.pkcs8

  cat bb.pkcs8 
  openssl rsautl -encrypt -pubin -inkey bb.pkcs8 -in plaintext.txt | base64 > encrypted.txt
  cat encrypted.txt
 
  
 
 # WARNING - this overwrites your key file!! We make a copy to be safe...
 cp ~/.ssh/id_rsa id_bb
 ssh-keygen -p -m pkcs7 -f ./id_bb
 
 
> NOTE: rsautil only uses .pkcs8 public keys
 
cat encrypted.txt | base64 -d | openssl rsautl -decrypt -inkey id_bb -in - > plaintext.out
 
# list possible private keys
> NOTE: the ssh keys **MUST** be named `id_<keyname>` and `id_<keyname>.pub` respectively and **MUST** be in the `~/.ssh` folder for `qed` to work.

while read F  ; do echo $F; done < <(shopt -s extglob && cd ~/.ssh && ls -d !(*.*) -l -f | grep id_)


# generate some legitimate message with plaintext words
shuf -n 1000 /usr/share/dict/words | fmt -w 72 > message.plaintext
cat message.plaintext

export QED_PASSWORD=$(cat plaintext.txt)

# encrypt using CTR mode (length invariant) into cyphertext message
cat message.plaintext | openssl enc -e -base64 -aes-128-ctr -nopad -nosalt -pbkdf2 -k $QED_PASSWORD > message.cyphertext

# decrypt & display cyphertext message
cat message.cyphertext | openssl enc -d -a -aes-128-ctr -nopad -nosalt -pbkdf2 -k $QED_PASSWORD 

#check the format of the pub key is correct
openssl rsa -RSAPublicKey_in -pubin -in id_bb.pkcs8 -noout &> /dev/null
if [ $? != 0 ] ; then
    echo "this was definitely not a RSA public key in PKCS8 format"
    exit 1
fi


openssl rand 32 -out secret_key

openssl aes-256-cbc -in LoveLetter.txt -out LoveLetter.txt.enc -pass file:secret_key

openssl rsautl -encrypt -pubin -inkey id_rsa.pub.pkcs8 -in secret_key -out secret_key.enc

#sign the plain text message
openssl dgst -sha256 -sign id_bb -out message.signature message.plaintext 
# the signature is saved seperately
cat message.signature 
#verify the plain text message signature
openssl dgst -sha256 -verify id_bb.pkcs8 -signature message.signature message.plaintext 
> `dgst` just works with the `pkcs8` key and rsa private key without further modification


---
### References
* https://security.stackexchange.com/questions/32768/converting-keys-between-openssl-and-openssh
