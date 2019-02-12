########################################################
## CONSTANTS
########################################################
INVOKEFROMMENU="true"
NEEDKILL="" ##Gun function

###############################
## FUNCTIONS
###############################

##Function to determinate if manual execution and require to exit frmo script. Example, on unexpected exit.
myexitmenufunction(){
 EXIT_CODE=$1
 if [[ “$INVOKEFROMMENU” == “true” ]]; then
  cd ~
  echo -e "\033[33;33m ## Loading menu... \033[0m"
  sleep 2
  menu
 else
  cleanvars ## clean vars function in order to multiple execution.
  exit $EXIT_CODE
 fi
}


##Exit function, used for trap functions and cancel.
exitfunction(){
 if [[ "$NEEDKILL" == "yes" ]]; then
  USERTOKILL="$(who am i | awk '{print $1}')"
  TTYTOKILL="$(who am i | awk '{print $2}')"
  PROCESSTOKILL=$(sudo ps aux | grep $USERTOKILL | grep $TTYTOKILL | grep sshd | grep -v grep | awk '{print $2}')
  echo -e "\e[1m Goodbye $USERTOKILL . Thanks for staying"
  echo -e "\e[100m"
  #fortune linux -n 8 ##Some random fortune to say godbye
  echo -e "\033[0m"
  #exit 0
  sudo kill "$PROCESSTOKILL"
  #echo "i should kill $PROCESSTOKILL"
 else
  menu
 fi
}

authorized_admin(){
MYUSER=$(who am i | awk '{print $1}')
#IAMADMIN=$(id "$MYUSER" | grep nagiosxi_admin | grep -v grep |wc -l)
IAMADMIN=$(getent group nagiosxi_admin | grep $MYUSER | wc -l)
if [ $IAMADMIN -ge 1 ]; then
    exit 0
else
    echo "You're not authorized to do this"
    NEEDKILL="yes"
    exitfunction
fi
}

trap exitfunction SIGINT
trap exitfunction SIGTERM

menu(){ ## CORE MENU
 trap exitfunction SIGINT ##Recall?, need if some overwrite of this functions?
 trap exitfunction SIGTERM

 if [ $# != 1 ]; then
  echo "Remember, CTRL C is Signal Interruption. Expect it :)"

  echo -e "\n******************\033[44m Cli Setups \033[0m******************"
  echo -e "\033[1m 1.  \033[33;33m Add new AWS Account \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 2.  \033[33;33m Add new AZURE Account \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 3.  \033[33;33m Add new GCP Account \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 4.  \033[33;32m Change KEY for AWS Account \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 5.  \033[33;32m Change KEY for AZURE Account \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 6.  \033[33;32m Change KEY for GCP Account \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 7.  \033[33;31m Remove AWS Account \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 8.  \033[33;31m Remove AZURE Account \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 9.  \033[33;31m Remove GCP Account \033[0m \e[42m(working)\033[0m"

  echo ""
  echo -e "******************\033[44m Check Connectivity \033[0m******************"
  echo -e "\033[1m 10.  \033[33;33m Check manually availability of Linux Host \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 11.  \033[33;32m Check manually availability of Windows Host \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 12.  \033[33;31m Check manually availability of NAT Host \033[0m \e[42m(working)\033[0m"

  echo ""
  echo -e "******************\033[44m Service Maintenance \033[0m******************"
  echo -e "\033[1m 20.  \033[33;33m Add a defined Service for Linux Hosts \033[0m \e[101m(not yet available)\033[0m"
  echo -e "\033[1m 21.  \033[33;33m Add a defined Service for Windows Hosts \033[0m \e[101m(not yet available)\033[0m"
  echo -e "\033[1m 22.  \033[33;32m Add a not defined Service for Linux Hosts \033[0m \e[101m(not yet available)\033[0m"
  echo -e "\033[1m 23.  \033[33;32m Add a not defined Service for Windows Hosts \033[0m \e[101m(not yet available)\033[0m"
  echo -e "\033[1m 24.  \033[33;31m Add a not defined Process Linux Hosts \033[0m \e[101m(not yet available)\033[0m"
  echo -e "\033[1m 25.  \033[33;31m Add a not defined Process for Windows Hosts \033[0m \e[101m(not yet available)\033[0m"
  echo -e "\033[1m 28.  \033[33;31m Remove an existence service from a host \033[0m \e[42m(working)\033[0m"
  echo ""

  echo -e "******************\033[44m Host Maintenance \033[0m******************"
  echo -e "\033[1m 30.  \033[33;33m Manually addon one host \033[0m \e[101m(not yet available)\033[0m"
  echo -e "\033[1m 31.  \033[33;32m Manually remove one host \033[0m \e[42m(working)\033[0m"
  echo ""

  echo -e "******************\033[44m Disk Service Maintenance \033[0m******************"
  echo -e "\033[1m 42.  \033[33;32m Add a not defined Disk Service for Linux Hosts \033[0m \e[101m(not yet available)\033[0m"
  echo -e "\033[1m 43.  \033[33;32m Add a not defined Disk Service for Windows Hosts \033[0m \e[101m(not yet available)\033[0m"
  echo ""

  echo -e "******************\033[44m Cluster Maintenance \033[0m******************"
  echo -e "\033[1m 50.  \033[33;33m Add a new cluster definition for CLOUDERA \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 51.  \033[33;32m Add a new cluster definition for HORTONWORKS \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 52.  \033[33;31m Add a new cluster definition for CASSANDRA \033[0m \e[100m(not yet supported)\033[0m"
  echo ""

  echo -e "******************\033[44m Database Maintenance \033[0m******************"
  echo -e "\033[1m 60.  \033[33;33m Manually Add one RDS Definition \033[0m \e[101m(not yet available)\033[0m"
  echo ""

  echo -e "******************\033[44m URL & TCP Maintenance \033[0m******************"
  echo -e "\033[1m 70.  \033[33;33m Add a new URL definition \033[0m \e[101m(not yet available)\033[0m"
  echo -e "\033[1m 71.  \033[33;32m Add new TCP check \033[0m \e[101m(not yet available)\033[0m"
  echo ""

  echo -e "******************\033[44m Other Options \033[0m******************"
  echo -e "\033[1m 90. \033[33;33m Autodiscovery of Hosts by Client \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 91. \033[33;32m Exclude Client from Nagios Core Integration Process \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 92. \033[33;31m Delete Excluded Client from Nagios Core Integration Process \033[0m \e[42m(working)\033[0m"
  echo ""

  echo -e "******************\033[44m Exit Options \033[0m******************"
  echo -e "\033[1m 100. \033[33;33m Exit & Logout \033[0m \e[42m(working)\033[0m"
  echo -e "\033[1m 101. \033[33;33m Go To Shell \033[0m \e[42m(working)\033[0m"

  echo -e
  echo -e "\033[42m Enter the value \033[0m"
 read ch
 a=$ch
else
 a=$1
fi

SCRIPTSDIR="/home/nagsvc"
case $a in
 ## Addition of a new key
 1)  source $SCRIPTSDIR/scripts/bin/AWSCLITools/aws_configure_new_account.sh
     ;;
 ## Addition of Azure Account
 2)  source $SCRIPTSDIR/scripts/bin/AZURECLITools/azure_configure_new_account.sh
     ;;
 ## Addition of GCP Account
 3)  dialog --backtitle "$TITLE" --msgbox "This capability needs to be handled by Nagios Administrator because of how it is managed. Please refer to contact Nagios Admin." 8 60
     ;;
 ## Update of an existing key
 4)  dialog --backtitle "$TITLE" --msgbox "Please note that you will need to know the full NAME-TAG saved and profile-name. If Unknown please refer to Management reports and/or contact Nagios Admin." 8 60
     source $SCRIPTSDIR/scripts/bin/AWSCLITools/aws_configure_new_account.sh
     ;;
 ## Change of Azure Account
 5)  dialog --backtitle "$TITLE" --msgbox "Please note that you will need to know the full NAME-TAG saved and Azure domain name. If Unknown please refer to Management reports and/or contact Nagios Admin." 8 60
     source $SCRIPTSDIR/scripts/bin/AZURECLITools/azure_configure_new_account.sh
     ;;
 ## Change of GCP Account
 6)  dialog --backtitle "$TITLE" --msgbox "Please note that you will need to know the full NAME-TAG saved and GCP domain name. If Unknown please refer to Management reports and/or contact Nagios Admin." 8 60
     dialog --backtitle "$TITLE" --msgbox "This capability needs to be handled by Nagios Administrator because of how it is managed. Please refer to contact Nagios Admin." 8 60
     ;;
 ## Removal of AWS Account
 7)  dialog --backtitle "$TITLE" --msgbox "Please note that you will need to know the full NAME-TAG saved and profile-name. If Unknown please refer to Management reports and/or contact Nagios Admin." 8 60
     source $SCRIPTSDIR/scripts/bin/AWSCLITools/aws_delete_account.sh
     ;;
 ## Removal of Azure Account
 8)  dialog --backtitle "$TITLE" --msgbox "Please note that you will need to know the full NAME-TAG saved and Azure Domain Name. If Unknown please refer to Management reports and/or contact Nagios Admin." 8 60
     source $SCRIPTSDIR/scripts/bin/AZURECLITools/azure_delete_account.sh
     ;;
 ## Removal of GCP Account
 9)  dialog --backtitle "$TITLE" --msgbox "Please note that you will need to know the full NAME-TAG saved and GCP domain name. If Unknown please refer to Management reports and/or contact Nagios Admin." 8 60
     dialog --backtitle "$TITLE" --msgbox "This capability needs to be handled by Nagios Administrator because of how it is managed. Please refer to contact Nagios Admin." 8 60
     ;;
 ## Check Availability of Linux Server
 10) source $SCRIPTSDIR/scripts/bin/CommonTools/checkavailability.sh "LINUX"
     ;;
 ## Check Availability of Windows Server
 11) source $SCRIPTSDIR/scripts/bin/CommonTools/checkavailability.sh "WINDOWS"
     ;;
 ## Check Availability of Fortigate
 12) source $SCRIPTSDIR/scripts/bin/CommonTools/checkavailability.sh "FORTIGATE"
     ;;
 ## Removal of a service
 28) source $SCRIPTSDIR/scripts/bin/NagiosRemoveTools/delete_service.sh
     ;;
 ## Removal of a host
 31) source $SCRIPTSDIR/scripts/bin/NagiosRemoveTools/delete_host.sh
     ;;
 ## Adding Cloudera Clusters
 50) source $SCRIPTSDIR/scripts/bin/NagiosAddonTools/addclouderacluster.sh
     ;;
 ## Adding Ambari Clusters
 51) source $SCRIPTSDIR/scripts/bin/NagiosAddonTools/addambaricluster.sh
     ;;
 ## Autodiscovery hosts by Client
 90) cd $SCRIPTSDIR/scripts/bin/CommonTools; source $SCRIPTSDIR/scripts/bin/CommonTools/autodiscover_client_menu.sh
     ;;
 91) cd $SCRIPTSDIR/scripts/bin/NagiosXI_NagiosCore_Replication; source $SCRIPTSDIR/scripts/bin/NagiosXI_NagiosCore_Replication/addnagioscoreexport_excluded_menu.sh
     ;;
 92) cd $SCRIPTSDIR/scripts/bin/NagiosXI_NagiosCore_Replication; source $SCRIPTSDIR/scripts/bin/NagiosXI_NagiosCore_Replication/deletenagioscoreexport_excluded_menu.sh
     ;;
 ## Normal Exist
 100)NEEDKILL="yes"
     exitfunction
     ;; #Kill Session
 ## Go to shell, exit script
 101)authorized_admin
     ;;
 *)  clear
     echo -en '\E[47;31m'"\033[1m Invalid Entry. Please try again in 5 seconds.\033[0m\n"
     #sleep 5
     menu
     ;;
esac
}

###############################
## BEGIN
###############################
menu
