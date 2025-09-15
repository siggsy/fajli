## defaultIdentityFiles



A list of paths to identity files, which are used when decrypting (or encrypting when using symmetric encryption)\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [../modules/hosts](../modules/hosts)



## defaultRecipients



A list of recepients which, in addition to hosts, should be used when encrpyting asymmetrically\.



*Type:*
list of (key)



*Default:*
` [ ] `

*Declared by:*
 - [../modules/hosts](../modules/hosts)



## hosts



List of hostnames for which files should be generated



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [../modules/hosts](../modules/hosts)



## perHost



A list of folders generated for each host separately\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [../modules/hosts](../modules/hosts)



## perHost\.\<name>\.after



Causes the folder to be generated after the specified folders\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## perHost\.\<name>\.before



Causes the folder to be generated before the specified folders\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## perHost\.\<name>\.files



Files contained in this folder



*Type:*
attribute set of (submodule)

*Declared by:*
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## perHost\.\<name>\.files\.\<name>\.age\.enable



Whether to enable age\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## perHost\.\<name>\.files\.\<name>\.age\.identityFiles



List of paths to identity files



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## perHost\.\<name>\.files\.\<name>\.age\.recipients



List of recipients to pass to age (using -r or -R flag)



*Type:*
list of (key)



*Default:*
` [ ] `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## perHost\.\<name>\.files\.\<name>\.age\.symmetric



Whether to enable symmetric encryption\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## perHost\.\<name>\.files\.\<name>\.name



Name of the file to generate



*Type:*
string



*Default:*
` "‹name›" `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## perHost\.\<name>\.hosts



A list of hosts for which this folder should be generated (or encrypted when shared)\.
By default, all hosts are used\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [../modules/hosts](../modules/hosts)



## perHost\.\<name>\.name



Folder name (subpath)



*Type:*
string



*Default:*
` "‹name›" `

*Declared by:*
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## perHost\.\<name>\.script



A script for generating the files\.



*Type:*
strings concatenated with “\\n”



*Default:*
` "" `

*Declared by:*
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## shared



A list of folders that the hosts should share



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [../modules/hosts](../modules/hosts)



## shared\.\<name>\.after



Causes the folder to be generated after the specified folders\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## shared\.\<name>\.before



Causes the folder to be generated before the specified folders\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## shared\.\<name>\.files



Files contained in this folder



*Type:*
attribute set of (submodule)

*Declared by:*
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## shared\.\<name>\.files\.\<name>\.age\.enable



Whether to enable age\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## shared\.\<name>\.files\.\<name>\.age\.identityFiles



List of paths to identity files



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## shared\.\<name>\.files\.\<name>\.age\.recipients



List of recipients to pass to age (using -r or -R flag)



*Type:*
list of (key)



*Default:*
` [ ] `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## shared\.\<name>\.files\.\<name>\.age\.symmetric



Whether to enable symmetric encryption\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## shared\.\<name>\.files\.\<name>\.name



Name of the file to generate



*Type:*
string



*Default:*
` "‹name›" `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## shared\.\<name>\.hosts



A list of hosts for which this folder should be generated (or encrypted when shared)\.
By default, all hosts are used\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [../modules/hosts](../modules/hosts)



## shared\.\<name>\.name



Folder name (subpath)



*Type:*
string



*Default:*
` "‹name›" `

*Declared by:*
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## shared\.\<name>\.script



A script for generating the files\.



*Type:*
strings concatenated with “\\n”



*Default:*
` "" `

*Declared by:*
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## symmetricEncryption



Should the files be encrypted symmetrically using host identity files



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [../modules/hosts](../modules/hosts)


