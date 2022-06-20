#!/usr/bin/env bash

#########################################################################################
## USER DEFINED VARIABLES
#########################################################################################
ODK_STORAGE_PATH="Data"
ODK_EXPORT_PATH="Data/Output"
URL="https://SERVER.URL.COM/project/"
ODKUSERNAME="admin"
PEM="keys/ODK.PRIVATE.KEY.pem"

#########################################################################################
#########################################################################################

# GET TODAY'S DATE
PULLTIME=$(date +"%Y-%m-%d")
PULLTIME2=$(date +"%Y-%m-%d_%H_%M_%S")

echo Today is "$PULLTIME"
# GET YESTERDAY'S DATE


####BLANK ONE OF THESE LINES
#ON UNIX
#EXPORTLIMIT=$(date -v -1d +"%Y-%m-%d")
#ON LINUX
# GET YESTERDAY'S DATE
EXPORTLIMIT=$(date -d "-1 days" "+%Y-%m-%d")

echo Today is "$PULLTIME"
echo Export Limit is "$EXPORTLIMIT"

## Get the password from file "pass"
source serverpass.txt

declare -a arr=(
#########################################################################################
## ADD ODK FORM IDs BELOW THIS LINE  (FORMID;FORMNAME) replace and . with _
#########################################################################################
"c19;LSHTM_Coronavirus_and_Health_Survey"

#########################################################################################
#########################################################################################
                )


## now loop through the above array and perform functions on every form ID
for i in "${arr[@]}"
	do
		j="output/$i.csv"
		#until ( test -e "$j"); 
		#do
			echo Working on form "$j" 				
			FORM_ID=$(echo "$i" | cut -d ";" -f1)
			FORM_NAME=$(echo "$i" | cut -d ";" -f2)
			echo Form Name : "$FORM_NAME"
			echo Form ID :  "$FORM_ID"

			#read in the next pull date from nextpull.txt
				
			#make folders for archive
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/archive/
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/archive/"$PULLTIME2"

			#pull data using briefcase -sfl option
			echo Pulling since last pull
			java -jar ODK-Briefcase-v1.17.3.jar -sfl -plla -id "$FORM_ID" -sd "$ODK_STORAGE_PATH" -U $URL -u "$ODKUSERNAME" -p "$ODKPASSWORD"
		
			#export data from form using -smart_append (i.e. start at last day when pull was done and end at yesterday)
			echo removing old export
			rm -rf Data/Output/c19.csv
			echo making new export
			java -jar ODK-Briefcase-v1.17.3.jar -e -ed "$ODK_EXPORT_PATH"/  -ssm -sd "$ODK_STORAGE_PATH" -id "$FORM_ID" -f "$FORM_ID".csv -pf "$PEM"
		
			#make a backup of the CSV file
			echo making backup copy of CSV file
			cp "$ODK_EXPORT_PATH"/"$FORM_ID".csv "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/archive/"$PULLTIME2"/"$PULLTIME2".csv
	done

date +"%Y_%m_%d_%H_%M" >  "$ODK_EXPORT_PATH"/000_timestamp.txt


