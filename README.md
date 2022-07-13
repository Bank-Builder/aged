# QED
> A set of scripts to encrypt, sign and exchange files/messages using github usernames as handles for public ssh keys.
> Convenient for very easy & secure personal exchanges as well as many [CI](#continuous-integration) use cases.

## Installation

Install **qed**: 
1. clone this repo with `git clonegit@github.com:Bank-Builder/qed.git` and `cd qed`.
2. Running `./qed-install.sh` will install the application and any required scripts into `~/.local/bin/qed` and `~/.local/share/qed` respectively.
3. You may remove this clone folder with 
```
cd ..
rm -rf qed/
```

Remove  **qed**: 
2. `./qed-remove`<br> Will completely uninstall qed from your machine.

## Usage
```
Todo:
  create scripts to use github usernames as proxy for mutual authentication using qed

  basic use cases with qed explained
```

* qed allows you to securely send files or messages to any github user by encrypting and signing using your private key and their github public keys.
* qed currently only works on Linux.
* qed is CI friendly and may be used within CI pipelines to encrypt/decrypt extremely sensitive artefacts such as secrets from/to a github repo.

### Installed Files

| Function  | Location | Description |
| ------------------------------ | --------------------------------- |--------------------------------- |
| **qed** | ~/.local/bin/ | the executable program |
| *qed-remove* | ~/.local/share/qed | link to the removal script |
| *.qed.conf* | ~ | the hidden config file in the user home folder |
| | | 



```
| qed keys list | List the keys available for encryption & signing. These are keys where the private key is found in `~/.ssh` and the public key has been uploaded as a github ssh key for your username. |

```


## Continuos Integration

> It may be required to securely deliver encrypted & signed content into or out of a CI pipeline.
> `qed` is a convenient command line tool to achieve just this.

**CI EXAMPLE**

* Push an encrypted artefact from a CI pipeline to a given repository securely

```
steps:
      - checkout
      - run: |
          git clone git@github.com/cyber-mint/qed
          cd qed
          ./install.sh
          cd ..
          rm -rf qed
          # generate a secret key for some pipeline purpose
          ssh-keygen rsa ..... $PWD
          qed init bank-builder bank@builder.beer $PWD
          qed add jake-miller jake@miller.beer 'Beer Man'
          qed esign $PWD/id_rsa.* jake-miller jm.secure
          git push ....
          # now only jake will be able to decrypt jm.secure we added to the /repo using his private key associated with his public key on github.
```

---

References:
* https://lindevs.com/install-age-command-for-encrypting-files-on-ubuntu/
* https://github.com/FiloSottile/age
  

---
Copyright &copy; Bank-Builder, 2022
Licensed under MIT
