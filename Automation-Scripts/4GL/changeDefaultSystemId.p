FOR EACH user-ctl
         EXCLUSIVE-LOCK:
   PROCESS EVENTS.
   IF user-ctl.default-system-id = "Apprise" THEN
      ASSIGN user-ctl.default-system-id = "BDB".
END.
