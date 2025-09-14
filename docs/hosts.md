## _module\.args

Additional arguments passed to each module in addition to ones
like ` lib `, ` config `,
and ` pkgs `, ` modulesPath `\.

This option is also available to all submodules\. Submodules do not
inherit args from their parent module, nor do they provide args to
their parent module or sibling submodules\. The sole exception to
this is the argument ` name ` which is provided by
parent modules to a submodule and contains the attribute name
the submodule is bound to, or a unique generated name if it is
not bound to an attribute\.

Some arguments are already passed by default, of which the
following *cannot* be changed with this option:

 - ` lib `: The nixpkgs library\.

 - ` config `: The results of all options after merging the values from all modules together\.

 - ` options `: The options declared in all modules\.

 - ` specialArgs `: The ` specialArgs ` argument passed to ` evalModules `\.

 - All attributes of ` specialArgs `
   
   Whereas option values can generally depend on other option values
   thanks to laziness, this does not apply to ` imports `, which
   must be computed statically before anything else\.
   
   For this reason, callers of the module system can provide ` specialArgs `
   which are available during import resolution\.
   
   For NixOS, ` specialArgs ` includes
   ` modulesPath `, which allows you to import
   extra modules from the nixpkgs package tree without having to
   somehow make the module aware of the location of the
   ` nixpkgs ` or NixOS directories\.
   
   ```
   { modulesPath, ... }: {
     imports = [
       (modulesPath + "/profiles/minimal.nix")
     ];
   }
   ```

For NixOS, the default value for this option includes at least this argument:

 - ` pkgs `: The nixpkgs package set according to
   the ` nixpkgs.pkgs ` option\.



*Type:*
lazy attribute set of raw value

*Declared by:*
 - [\<nixpkgs/lib/modules\.nix>](https://github.com/NixOS/nixpkgs/blob//lib/modules.nix)



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



## hosts



List of hostnames for which files should be generated



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [../modules/hosts](../modules/hosts)



## path



Path relative to git root



*Type:*
string

*Declared by:*
 - [../modules/main](../modules/main)



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


