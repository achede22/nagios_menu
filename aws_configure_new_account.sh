#!/bin/bash

########################################################
## Validations previous to load settings
########################################################
# Not overwrite global if using from other
if [[ "$INVOKEFROMMENU" != "true" ]]; then
 source ~/scripts/etc/commonfunctions.cfg
fi
#validateproperusername nagsvc #Validate proper username is running
#validatemultipleruns $(echo $0 | sed "s/.\///") #Clean up name previous to filter out

########################################################
## VARIABLES - NOT CHANGE
########################################################
OUTDIR="$LOGPATH/${PWD##*/}/out"
TMPDIR="$LOGPATH/${PWD##*/}/tmp"

########################################################
## CONSTANTS - NOT CHANGE
########################################################
ACCESS_KEY_ID="" ##Keys
SECRET_ACCESS_KEY="" ##Keys
AIPNAME="" ## Client Name. May be repeated by clients with more than 1 aws account.
AIPPROFILENAME="" ##Used to store profile name at aws config. IS completely unique.
NEWACCOUNT="no" ##Used to know if need to store new account info on profiles file.

########################################################
## FUNCTIONS - NOT CHANGE
########################################################

## Used to clean variables on each script, normally set for menu actions
## Must exist on all new scripts that incporporate this
cleanvars(){
 unset ACCESS_KEY_ID
 unset SECRET_ACCESS_KEY
 unset AIPNAME
 unset AIPPROFILENAME
 unset NEWACCOUNT
}

## Ask for account names. Profile is unique for each account, while aipname can be repeated.
getaccountname(){
 dialog --backtitle "$TITLE" --cancel-label Exit --inputbox "Please provide AIP Tag Name. Example: AIP-MYCLIENTNAME" 8 60 2>/tmp/secretnewclient.tmp
  AIPNAME=$(cat /tmp/secretnewclient.tmp)
  [ ! -s /tmp/secretnewclient.tmp ] && myexitmenufunction 0 ##If file empty not proceed
 dialog --backtitle "$TITLE" --cancel-label Exit --inputbox "Please provide AIP Profile Name. Suggested: profile-$AIPNAME" 8 60 2>/tmp/secretnewclient.tmp
  AIPPROFILENAME=$(cat /tmp/secretnewclient.tmp)
  [ ! -s /tmp/secretnewclient.tmp ] && myexitmenufunction 0 ##If file empty not proceed

 if [ $(grep -F "$AIPPROFILENAME $AIPNAME" /home/nagsvc/scripts/etc/aws-client-profiles.cfg | wc -l) -ge 1 ] || [ $(grep -F "[$AIPPROFILENAME]" /home/nagsvc/.aws/config | wc -l) -ge 1 ]; then
  dialog --title "$TITLE" --yesno "Client $AIPPROFILENAME already exist. Are you sure you want to continue, this may overwrite previous client keys. Remember profiles are unique, as accounts are unique." 7 60
   NEWACCOUNT="no"
   response=$?
   case $response in ##like to do cases here, not ifs for once :)
    0) logger -t nagsvc "$(who am i| awk '{print $1}') is trying to overwrite client $AIPNAME"
       getaccountdetails
       ;;
    1) myexitmenufunction 0
   esac
  else ##As account seems completely new proceed to
   NEWACCOUNT="yes" ##Set to store keys if all goes ok
   getaccountdetails
 fi
 }

#Ask for details
getaccountdetails(){

 dialog --backtitle "$TITLE" --cancel-label Exit --inputbox "Please provide AWS Access KEY without spaces" 8 60 2>/tmp/secretnewclient.tmp
  if [ $? -eq 0 ]; then
   ACCESS_KEY_ID=$(cat /tmp/secretnewclient.tmp)
   [ ! -s /tmp/secretnewclient.tmp ] && myexitmenufunction 0 ##If file empty not proceed
    dialog --backtitle "$TITLE" --cancel-label Exit --inputbox "Please provide AWS Secret KEY without spaces" 8 60 2>/tmp/secretnewclient.tmp
    if [ $? -eq 0 ]; then
     SECRET_ACCESS_KEY=$(cat /tmp/secretnewclient.tmp)
     [ ! -s /tmp/secretnewclient.tmp ] && myexitmenufunction 0 ##If file empty not proceed
     check_account_valid
    fi
  fi
}

#Check account keys as valid.
check_account_valid(){
INCORRECTSTATUS=0 ##Set as no error, 0, all is ok, none gets killed yet.
export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID ##Set keys to be used as env arg
export AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY  ##Set keys to be used as env arg

 aws s3api list-buckets --output text >/dev/null 2>&1
  if [ $? -eq 0 ]; then
   echo -e "\033[33;32m ## Succesful List S3 Buckets.\033[0m"
  else
   echo -e "\033[33;33m ## Unable to List S3 buckets.\033[0m"
   INCORRECTSTATUS=1
  fi

 aws ec2 describe-regions --output text --region us-east-1 >/dev/null 2>&1
  if [ $? -eq 0 ]; then
   echo -e "\033[33;32m ## Succesful List AWS Regions.\033[0m"
  else
   echo -e "\033[33;33m ## Unable to List AWS Regions.\033[0m"
   INCORRECTSTATUS=1
  fi

 aws ec2 describe-instances --region us-east-1 >/dev/null 2>&1
  if [ $? -eq 0 ]; then
   echo -e "\033[33;32m ## Succesful List instances.\033[0m"
  else
   echo -e "\033[33;33m ## Unable to List instances.\033[0m"
   INCORRECTSTATUS=1
  fi

 aws iam list-users --query 'Users[*].[UserName, CreateDate, PasswordLastUsed]' --output text >/dev/null 2>&1
  if [ $? -eq 0 ]; then
   echo -e "\033[33;32m ## Succesful List IAM Users.\033[0m"
  else
   echo -e "\033[33;33m ## Unable to List IAM Users.\033[0m"
   INCORRECTSTATUS=1
  fi


 if [ $INCORRECTSTATUS -ne 0 ]; then

  ## If think something is incorrect contact it support.
  echo -e "\033[33;31m ## Unable to PROCEED To add this account. See details above. Please correct and retry.\033[0m"
 else
   saveaccount
 fi
}

#Used to save keys.
saveaccount(){

 if [[ "$NEWACCOUNT" == "no" ]]; then ##If not new account then delete the old one previous to save. Only delete previous one when all were check.
  ## Remove details from credentials
  sed -i "/$AIPPROFILENAME/,+2d" /home/nagsvc/.aws/credentials

  ## Remove details from config
  sed -i "/$AIPPROFILENAME/,+2d" /home/nagsvc/.aws/config
 else ##If new account then save it
  echo "$AIPPROFILENAME $AIPNAME" >> /home/nagsvc/scripts/etc/aws-client-profiles.cfg
 fi

 ## now proceed to check this.
 echo "[$AIPPROFILENAME]
aws_access_key_id = $ACCESS_KEY_ID
aws_secret_access_key = $SECRET_ACCESS_KEY" >> /home/nagsvc/.aws/credentials

 echo "[profile $AIPPROFILENAME]
region = us-east-1
output = text" >> /home/nagsvc/.aws/config

 echo -e "\033[33;32m ## Succesful Save New Account for $AIPNAME - $AIPPROFILENAME. Please remember to upload vault / Keepass if required.\033[0m"

}

########################################################
## BEGIN - CHANGE ME
########################################################

if [[ "$INVOKEFROMMENU" != "true" ]]; then
 getaccountname
 exit 0
else
 getaccountname
 myexitmenufunction
fi
