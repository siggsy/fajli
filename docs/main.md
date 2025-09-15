## allowGitless



Wether to allow generating in gitless folders\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [../modules/main](../modules/main)



## commitChanges



Commit changes if all files successfully generate\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [../modules/main](../modules/main)



## debug



Add set -x to generated script



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [../modules/main](../modules/main)



## folders



Folders to generate



*Type:*
attribute set of (submodule)

*Declared by:*
 - [../modules/main/paths\.nix](../modules/main/paths.nix)
 - [../modules/main](../modules/main)



## folders\.\<name>\.after



Causes the folder to be generated after the specified folders\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## folders\.\<name>\.before



Causes the folder to be generated before the specified folders\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## folders\.\<name>\.files



Files contained in this folder



*Type:*
attribute set of (submodule)

*Declared by:*
 - [../modules/main/paths\.nix](../modules/main/paths.nix)
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## folders\.\<name>\.files\.\<name>\.age\.enable



Whether to enable age\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## folders\.\<name>\.files\.\<name>\.age\.identityFiles



List of paths to identity files



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## folders\.\<name>\.files\.\<name>\.age\.recipients



List of recipients to pass to age (using -r or -R flag)



*Type:*
list of (key)



*Default:*
` [ ] `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## folders\.\<name>\.files\.\<name>\.age\.symmetric



Whether to enable symmetric encryption\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## folders\.\<name>\.files\.\<name>\.name



Name of the file to generate



*Type:*
string



*Default:*
` "‹name›" `

*Declared by:*
 - [../modules/main/file\.nix](../modules/main/file.nix)



## folders\.\<name>\.files\.\<name>\.path



Relative path to file



*Type:*
string *(read only)*



*Default:*
` "‹name›/‹name›" `

*Declared by:*
 - [../modules/main/paths\.nix](../modules/main/paths.nix)



## folders\.\<name>\.name



Folder name (subpath)



*Type:*
string



*Default:*
` "‹name›" `

*Declared by:*
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## folders\.\<name>\.path



Relative path to folder



*Type:*
string *(read only)*



*Default:*
` "‹name›" `

*Declared by:*
 - [../modules/main/paths\.nix](../modules/main/paths.nix)



## folders\.\<name>\.script



A script for generating the files\.



*Type:*
strings concatenated with “\\n”



*Default:*
` "" `

*Declared by:*
 - [../modules/main/folder\.nix](../modules/main/folder.nix)



## path



Path relative to git root



*Type:*
string

*Declared by:*
 - [../modules/main](../modules/main)


