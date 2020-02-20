#!/bin/bash
################################################################################
# Mail Notification
################################################################################

################################################################################
# notify_begin: Function to notify when the backup process began through e-mail.
# Options:
#    $1 -> Inform the backup's session name;
#    $2 -> Infomr the type of backup is in execution.
################################################################################
function notify_begin()
{
  if [[ "$ENABLE_EMAIL_NOTIFY" == "all" || "$ENABLE_EMAIL_NOTIFY" == "start" ]]; then
    printf "Subject: Zmbackup - Backup routine for $1 start at $(date)" > $MESSAGE
    printf "\nGreetings Administrator," >> $MESSAGE
    printf "\n\nThis is an automatic message to inform you that the process for $2 BACKUP that you scheduled started right now." >> $MESSAGE
    printf " Depending on the amount of accounts and/or data to be backed up, this process can take some hours before conclude." >> $MESSAGE
    printf "\nDon't worry, we will inform you when the process finish." >> $MESSAGE
    printf "\n\nRegards," >> $MESSAGE
    printf "\nSysops Team" >> $MESSAGE
    ERR=$((sendmail -f $EMAIL_SENDER $EMAIL_NOTIFY < $MESSAGE ) 2>&1)
    if [[ $? -eq 0 ]]; then
      logger -i -p local7.info "Zmbackup: Mail sended to $EMAIL_NOTIFY to notify about the backup routine begin."
    else
      logger -i -p local7.info "Zmbackup: Cannot send mail for $EMAIL_NOTIFY - $ERR."
    fi
  fi
}


################################################################################
# notify_finishOK: Function to notify when the backup process finish - SUCCESS.
# Options:
#    $1 -> Inform the backup's session name;
#    $2 -> Inform the type of backup is in execution;
#    $3 -> Inform the status of the bacup. Valid Options:
#        - FAILURE - For some reason Zmbackup can't conclude this session;
#        - SUCCESS - Zmbackup concluded the session with no problem;
#        - CANCELED - The administrator canceled the session for some reason.
################################################################################
function notify_finish()
{
  if [[ "$ENABLE_EMAIL_NOTIFY" == "all" ]] || [[ "$ENABLE_EMAIL_NOTIFY" == "finish" && "$3" == "SUCCESS" ]] || [[ "$ENABLE_EMAIL_NOTIFY" == "error" && "$3" == "FAILURE" ]] ; then

    # Loading the variables
    if [[ "$3" == "SUCCESS" ]]; then
      SIZE=$(du -h $WORKDIR/$1 2> /dev/null | awk {'print $1'}; exit ${PIPESTATUS[0]})
      if [[ $? -eq 0 ]]; then
        if [[ "$1" == "mbox"* ]]; then
          QTDE=$(ls $WORKDIR/$1/*.tgz | wc -l)
        else
          QTDE=$(ls $WORKDIR/$1/*.ldiff | wc -l)
        fi
      else
        SIZE=0
        QTDE=0
      fi
    else
      SIZE=0
      QTDE=0
    fi

    # The message
    printf "Subject: Zmbackup - Backup routine for $1 complete at $(date) - $3" > $MESSAGE
    printf "\nGreetings Administrator," >> $MESSAGE
    printf "\n\nThis is an automatic message to inform you that the process for $2 BACKUP that you scheduled ended right now." >> $MESSAGE
    printf "\nHere some information about this session:" >> $MESSAGE
    printf "\n\nSize: $SIZE" >> $MESSAGE
    printf "\nAccounts: $QTDE" >> $MESSAGE
    printf "\nStatus: $3" >> $MESSAGE
    printf "\n\nRegards," >> $MESSAGE
    printf "\nZmbackup Team" >> $MESSAGE
    printf "\n\nSummary of files:\n" >> $MESSAGE
    cat $TEMPSESSION >> $MESSAGE
    ERR=$((sendmail -f $EMAIL_SENDER $EMAIL_NOTIFY < $MESSAGE ) 2>&1)
    if [[ $? -eq 0 ]]; then
      logger -i -p local7.info "Zmbackup: Mail sended to $EMAIL_NOTIFY to notify about the backup routine conclusion."
    else
      logger -i -p local7.info "Zmbackup: Cannot send mail for $EMAIL_NOTIFY - $ERR."
    fi
  fi
}
