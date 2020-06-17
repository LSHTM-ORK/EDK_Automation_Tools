#!/usr/bin/env bash

#########################################################################################
## USER DEFINED VARIABLES
#########################################################################################
ODK_STORAGE_PATH="Data"
ODK_EXPORT_PATH="Data/Output"
URL="https://example.server.com/"
ODKUSERNAME="admin"
PEM="keys/KEYNAME.pem"
# THE SYSTEM IS DESIGNED TO WORK WITH ENCRYPTED FORM DATA. PROVIDE A PEM KEY!
¢########################################################################################
#########################################################################################

# GET TODAY'S DATE
PULLTIME=$(date +"%Y-%m-%d")
PULLTIME2=$(date +"%Y-%m-%d_%H_%M_%S")

echo Today is "$PULLTIME"
# GET YESTERDAY'S DATE

echo Today is "$PULLTIME"

## Get the password from file "serverpass.txt". This should have a single line with the password for the ODK server.
## Example file
## ODKPASSWORD=SOMErandomSEcRETcode

source serverpass.txt

declare -a arr=(
#########################################################################################
## ADD ODK FORM IDs BELOW THIS LINE  (FORMID;FORMNAME) replace and . with _
#########################################################################################
"CRF_s001a_01V4_PHASE2;CRF_Consentement Eclairé_PHASE2"
"CRF_sGRO_01_PHASE2;CRF_Grossesse_PHASE2"
"CRF_sEIG_01_PHASE2;CRF_Notifier_un_Evénement_Indésirable_Grave_PHASE2"
"CRF_sMVE_PHASE2;CRF_Notifier_un_MVE_chez_un_participant_PHASE2"
"CRF_rapport_derreur_PHASE2;CRF_Rapport_d_erreur_PHASE2"
"CRF_s021_01_BEBE_PHASE2;CRF_Suivi_21_Jours_BEBE_PHASE2"
"CRF_s021_01_GRO_PHASE2;CRF_Suivi_21_Jours_Grossesse_PHASE2"
"CRF_s002_01_PHASE2;CRF_Suivi_30_minutes_PHASE2"
"CRF_s001b_01_PHASE2;CRF_Vaccination_des_participants_PHASE2"
"CRF_s050_PHASE2;CRF_Visite_Imprevue_PHASE2"
"SAT_001_01_PHASE2;CRF_ajouter_un_satellite_PHASE2"
"CRF_ring_contacts_PHASE2;CRF_ceinture_contacts_PHASE2"
"CRF_HCW_PHASE2;CRF_consentement_personnel_de sante_PHASE2"
"CRF_c001_01_PHASE2;CRF_définition_ceinture_ou_zone_géographique_ciblée_PHASE2"
"CRF_s100_01_PHASE2;CRF_fin_d'étude_PHASE2"
"HHGPS_001_01_PHASE2;CRF_maison_du_participant_PHASE2"
"vax_history_PHASE2;VAX_History_PHASE2"
#########################################################################################
#########################################################################################
                )



#########################################################################################
## Loop through the above array and perform functions on every form ID
#########################################################################################
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
				
			#make folders for archive
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/archive/
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/archive/"$PULLTIME2"

			#pull data using briefcase -sfl option
			echo Pulling since last pull
			java -jar ODK-Briefcase-v1.17.0.jar -sfl -plla -id "$FORM_ID" -sd "$ODK_STORAGE_PATH" -U $URL -u "$ODKUSERNAME" -p "$ODKPASSWORD"
		
			#export data from form using -smart_append (i.e. start at last day when pull was done and end at yesterday)
			echo Exporting data since last export
			java -jar ODK-Briefcase-v1.17.0.jar -e -ed "$ODK_EXPORT_PATH"/ -smart_append -sd "$ODK_STORAGE_PATH" -id "$FORM_ID" -f "$FORM_ID".csv -pf "$PEM"
					
			#make a backup of the CSV file
			echo making backup copy of CSV file
			cp "$ODK_EXPORT_PATH"/"$FORM_ID".csv "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/archive/"$PULLTIME2"/"$PULLTIME2".csv
	done
#########################################################################################
#########################################################################################

date +"%Y_%m_%d_%H_%M" >  "$ODK_EXPORT_PATH"/000_timestamp.txt


 

