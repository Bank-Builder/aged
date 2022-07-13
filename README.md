# aged
> A set of scripts to install and use the **age** encryption tool.

## Installation

Install : `./age-install.sh`<br>
Remove  : `./age-remove`

## Usage
```
Todo:
  create scripts to use github usernames as proxy for mutual authentication using age

  basic use cases with age explained
```

* Aged allows you to securely send files or messages to any github user by encrypting and signing using your private key and their github public keys.
* Aged currently only works on Linux.
* Aged is CI friendly and may be used within CI pipelines to encrypt/decrypt extremely sensitive artefacts such as secrets from/to a github repo.

### Available functions

| Function  | Description |
| ------------------------------ | --------------------------------- |
| aged init <github-user> | creates a ~/.aged.conf file with your default github username. |
| aged keys list | List the keys available for encryption & signing. These are keys where the private key is found in `~/.ssh` and the public key has been uploaded as a github ssh key for your username. |
| | |



References:
* https://lindevs.com/install-age-command-for-encrypting-files-on-ubuntu/
* https://github.com/FiloSottile/age
  

---
Copyright &copy; Bank-Builder, 2022
Licensed under MIT
