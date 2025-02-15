FOR EACH user-ctl WHERE
         user-ctl.user-or-group-id = "zapprise" 
         EXCLUSIVE-LOCK:
   ASSIGN user-ctl.failed-attempt-count = 0
          user-ctl.reset-psd-next-login = NO.
END.