# ODK Archiver User Guide

This document provides instructions on how to set up an instance of the ODK Archiver system. The system can pull and then decrypt and export user defined forms using the ODK Briefcase CLI. ODK Archiver can be used as a standalone controller for the ODK Briefcase CLI, or can be automated using cron as explained [here](../03_crontabs/README.md).

The system is simple and requires very little setup. 


### Requirements

* An [ODK Aggregate](https://github.com/getodk/aggregate) or [ODK Central](https://github.com/getodk/central) server with some data on it are required for this set of functions to work.
* You should create a new folder in which the project specific archiving will take place, for instance `/user/hilary/Documents/Archiver_project_01`
* A copy of the [most recent ODK Briefcase jar file](https://github.com/getodk/briefcase/releases/latest). This should be saved in the `/user/hilary/Documents/Archiver_project_01` folder. In this example we use `ODK-Briefcase-v1.17.4.jar`
* You will also require a pair of self-supplied [ODK encryption keys](https://docs.getodk.org/encrypted-forms/#id1). In this example we will keep the decryption key in a folder called `keys/` but be aware that your system is only as secure as the folder you keep your decryption keys on. Using a USB keychain to provide your key is one option for extra security, for instance because you could keep the keychain in a safe when not in use. In this example we provide a pair of encryption keys, but these should not be used for real work.

	* The example encryption key is `keys/ODK.PUBLIC.KEY.11111.pem`   
	* The example decryption key is `keys/ODK.PRIVATE.KEY.11111.pem` 

* You also need to provide the system with the password to your ODK server. As with the decryption key, this should be kept safe. The password can be stored in a file such as `keys/serverpass.txt`

	* The `keys/serverpass.txt` file should contain a single line providing the password in the format

		`ODKPASSWORD=THISpassword-exampleISgud` followed by a newline.


### The ODK Archiver script

You will need to make some changes to the script in order for it to communicate with your ODK server. Server settings are defined in the first few lines.

```
#!/usr/bin/env bash

#########################################################################################
## USER DEFINED VARIABLES
#########################################################################################
ODK_STORAGE_PATH="Data"
ODK_EXPORT_PATH="Data/Output"
URL="https://example.server.com/"
ODKUSERNAME="admin"
PEM="keys/ODK.PRIVATE.KEY.pem"
# THE SYSTEM IS DESIGNED TO WORK WITH ENCRYPTED FORM DATA. PROVIDE A PEM KEY!
########################################################################################
#########################################################################################
```
* The `ODK_STORAGE_PATH` variable defines where the pulled data will be stored. Usually you should leave this as `"Data"` and ODK Briefcase.
* The `ODK_EXPORT_PATH` variable defines where exported CSV files will be stored. Usually you should leave this as `"Data/Output"`, particularly if automating the system as this is where the ODK Analyser will look for the files.
* The `URL` should be changed to the URL of your ODK server. The script works with both ODK Aggregate and ODK Central servers.
* The `ODKUSERNAME` should be set to that of an account name for the server which has privileges to pull data.
* The `PEM` variable provides the path to the decryption key.



The next modifiable part of the script requires you to enter both the `Form ID` and `Form Name` of the various forms that you want to pull and export. A quirk of ODK Briefcase is that is inconsistently uses the `Form ID` and `Form Name` variables for pulls and exports, so the script is designed to use both. Put each form on a separate line, using double quotes and separating the Form ID from the Form Name using a semicolon.

i.e. if you have a forms with the syling of `Form ID` = **FORM_01** and `Form Name` = **FORM_01__TASK_01** then you'd do this...

```
#########################################################################################
## ADD ODK FORM IDs BELOW THIS LINE  (FORMID;FORMNAME) replace and . with _
#########################################################################################
"FORM_01;FORM_01__TASK_01"
"FORM_02;FORM_01__TASK_02"
#########################################################################################
#########################################################################################
```
There is no limit to the number or combination of forms that you pull, though a minimum of one form is required. 


You need to check that the script will run your current release of ODK Briefcase, so change these lines appropriately

```
java -jar **ODK-Briefcase-v1.17.0.jar** -sfl -plla -id "$FORM_ID" -sd "$ODK_STORAGE_PATH" -U $URL -u "$ODKUSERNAME" -p "$ODKPASSWORD"
```

and 

```
java -jar **ODK-Briefcase-v1.17.0.jar** -e -ed "$ODK_EXPORT_PATH"/ -smart_append -sd "$ODK_STORAGE_PATH" -id "$FORM_ID" -f "$FORM_ID".csv -pf "$PEM"
```
					
Please note that in this example, the **-sfl** flag will start the ODK Briefcase pull from the last pulled form. During exports, Briefcase will similarly export forms from the last exported position because of the **-smart_append** flag. See the [ODK Briefcase documentation](https://docs.getodk.org/aggregate-data-access/?highlight=command%20line%20interface) for more information on this. 


* In order for you to be able to run the **ODK_Archiver.sh** script you need to first make it executable. 
	* Open a terminal
	* Type the following

```
cd /user/hilary/Documents/Archiver_project_01
chmod +x ODK_Archiver.sh
```

To test that everything is working, type the following

```
./ODK_Archiver.sh
```
which should run the archiver, pull data from the server and build your first set of CSV files

On each run, the archiver creates a backup copy of the CSV data in a folder called `archive`



 



