# QED Read the Docs

- [Cryptographic resources readily available in Linux](#cryptographic-resources-readily-available)
- 

---

## Cryptographic resources readily available

There are numerous cryptographic resources readily available in linux, either pre installed or easily installable from the standard repositories.

* **openssl** will be the main cryptographic library we will use in this project.  Confirm you have it installed by checking the version `openssl version`.
* Other `cli` applications we will make use of are:
```
  .... list prog names here
  jp2a <profile.jpg>  Displays user's github profile image as ascii art (eye candy)
```

## Solution design
The `QED` design is based on (a) cli principles of using various discrete cli commands strung together to generate teh desired result, and (b) commonly accepted cryptographic design principles as used by other tools such as GPG etc., and (c) it is an educational exercise as it is built entirely in the `bash` shell and the source code is open to easy inspection.

The assumptions (dependencies) for using `QED` are:
- public keys must be uploaded to `github`.
- sender (*alice*) and receiver (*bob*) have previously exchanged their github usernames/handles.
- both *alice* and *bob* only use linux with a bash shell or have re-written this code to work well their particular non-bash shell.

The steps for building & sending an encrypted `QED` message or file are:
- the recipient's public key `pk(bob)` is retrieved from github's public api.
- the sender's secret key `sk(alice)` associated with their `pk(alice)` as per github may be found by default in the `~/.ssh` folder
- `QED` will generate a random 256 bit symmetric key `ss` and an associated random 256 bit initial vector `iv`.
- the message/file to be encrypted and sent to *bob* will be encrypted with `aes-256-gcm` , and
- the secret key used for the encryption, will itself be encrypted using the sender's public key `pk(alice)` and included in the `cypher text` payload.
- the payload will be `base64` encoded to make it email/transport friendly.
- the structure of the **un-encoded** base64 payload (ie the entire byte array being transferred) will be as follows:

| **Field** | **Length** | **Description** |
| --------- | ---------- | --------------- |
| Header | 4 bytes | Version of `QED` being used |
| Cipher Text | n bytes | Encrypted `plain text` for *bob's* eyes only |
| IV | 32 bytes | 32 byte initial vector |
| Sender | 20 bytes | left align, right space padded containing *alice's* github user name |
| | | |

- the `cipher text` is structured as follows:

| **Field** | **Length** | **Description** |
| --------- | ---------- | --------------- |
| ChkSum | 8 bytes | last 8 bytes of the `sha256-sum` of the `plain text` |
| Cipher Text | n bytes | the `cipher text` of the original message/file |
| SS | 32 bytes | 32 bute `secret key` to be used to decrypt the `cipher text` |




### Add your key(s) detail

`qed -i ~/.ssh/id_rsa -n bank-builder -m andrew@.turpin.co.za -r github`

   -i  path to secret key
   -n  public-key-server(eg. github) username
   -m  email address
   -r  public-key-server (eg. github, gitlab) 
   
   Creates a config file in $HOME folder
   ```
  cat ~/.qed.conf
    
     [github:bank-builder]
     email=andrew.turpin.co.za
     key=~/.ssh/id_rsa
     
  ```

### Encrypt using your public key

`qed -e -a github:cmtill -n bank-builder msg.file`
`echo "Hello cmtill, this is from bank-builder" | qed -e -a cmtill -n bank-builder - `

This will encrypt a file/msg to `cmtill` by:
(a) generating a random symetric AES encryption key and a random AES IV
(b) fetch the addressee ( `cmtill`) public key from github
(c) 
