{nonsdsuper.i}
DEFINE TEMP-TABLE TTDWAndStuckSA NO-UNDO
   FIELD system-id AS CHARACTER
   FIELD task-id AS INT64 
   FIELD queue-name AS CHARACTER 
   FIELD task-name AS CHARACTER 
   FIELD expected-date-time AS CHARACTER 
   FIELD checked-date-time AS CHARACTER. 

DEF VAR ip-duration AS INT INIT 1 NO-UNDO.
DEF VAR email-body AS CHAR NO-UNDO.
DEF VAR stuck-satask-found AS LOG NO-UNDO.
   
RUN stuck-sa-check.

PROCEDURE stuck-sa-check:
   DEFINE BUFFER sas-task-run-01 FOR sas-task-run.
   DEFINE BUFFER sas-task-schedule-01 FOR sas-task-schedule.
   DEFINE BUFFER sas-task-01 FOR sas-task.
   DEFINE BUFFER sas-task-param-01 FOR sas-task-param.
   DEFINE VARIABLE utcConv AS UtcDateTimeConverter NO-UNDO.
   DEFINE VARIABLE started-date AS DATE NO-UNDO.
   DEFINE VARIABLE started-time AS CHARACTER NO-UNDO.
   DEFINE VARIABLE in-progress-duration AS DECIMAL NO-UNDO.
   DEFINE VARIABLE next-scheduled-date AS DATE NO-UNDO.
   DEFINE VARIABLE next-scheduled-time AS CHARACTER NO-UNDO.
   DEFINE VARIABLE next-scheduled-date-time AS DATETIME NO-UNDO.
   DEFINE VARIABLE scheduled-date AS DATE NO-UNDO.
   DEFINE VARIABLE scheduled-time AS CHARACTER NO-UNDO.
   DEFINE VARIABLE scheduled-date-time AS DATETIME NO-UNDO.
   
   ASSIGN ip-duration = ip-duration * 60 * 60.   

   FOR EACH sas-task-run-01 WHERE
            sas-task-run-01.run-state = "In-Progress"
            NO-LOCK,
      FIRST sas-task-schedule-01 WHERE
            sas-task-schedule-01.id = sas-task-run-01.task-schedule-id
            NO-LOCK,
      FIRST sas-task-01 WHERE
            sas-task-01.id = sas-task-schedule-01.task-id
            NO-LOCK:
           
      ASSIGN utcConv = NEW UtcDateTimeConverter(sas-task-schedule-01.started-date-utc, sas-task-schedule-01.started-time-utc, UtcConvertAction:FromUtcToLocal)
             started-date = utcConv:OutDate
             started-time = utcConv:OutTime
             in-progress-duration = SAUtils:CalcDuration(utcConv:OutTime, utcConv:OutDate, DATETIME(TODAY, MTIME)).
      IF in-progress-duration > ip-duration THEN
      DO:
         ASSIGN stuck-satask-found = YES
                email-body = "The following task has been running for more than 60 minutes on server Servername:" + "~n" +
                             "Task Name: " + sas-task-01.name + "~n" +
                             "Task Description: " + sas-task-01.description + "~n" +
                             "Task Owner: " + sas-task-01.created-by + "~n" +
                             "Task ID: " + STRING(sas-task-01.id) + "~n" +
                             "Task State: " + sas-task-01.state + "~n" +
                             "Scheduled Date: " + STRING(scheduled-date-time) + "~n" +
                             "Duration: " + STRING(in-progress-duration) + " minutes." + "~n".
            RUN send-email(INPUT "noreply-apprise@aptean.com",
                           INPUT "suraj.chopade@aptean.com",
                           INPUT "Alert: Stuck Task Detected (Task ID: " + STRING(sas-task-01.id) + ")",
                           INPUT "").
      END.
   END.
     
   IF NOT CAN-FIND(FIRST sas-task-01 WHERE
                         sas-task-01.state = "Starting" 
                          NO-LOCK) AND
      NOT CAN-FIND(FIRST sas-task-01 WHERE
                         sas-task-01.state = "In-Progress"
                          NO-LOCK) THEN
   DO:
      loop:
      FOR EACH sas-task-01 WHERE
               sas-task-01.state = "Pending"
               NO-LOCK,
          EACH sas-task-schedule-01 WHERE
               sas-task-schedule-01.task-id = sas-task-01.id
               NO-LOCK:
         FOR FIRST sas-task-run-01 USE-INDEX idx-schedule-id-run-id WHERE
                   sas-task-run-01.task-schedule-id = sas-task-schedule-01.id AND
                   sas-task-run-01.run-state = "done"
                   NO-LOCK:
            NEXT loop.
         END.
         ASSIGN utcConv = NEW UtcDateTimeConverter(sas-task-schedule-01.schedule-date-utc, sas-task-schedule-01.schedule-time-utc, UtcConvertAction:FromUtcToLocal)
                scheduled-date = utcConv:OutDate
                scheduled-time = utcConv:OutTime
                scheduled-date-time = DATETIME(STRING(scheduled-date) + " " + scheduled-time). 
         IF scheduled-date-time <> ? AND scheduled-date-time < NOW THEN
         DO:
            ASSIGN stuck-satask-found = YES
                   email-body = "The following task has been running for more than 60 minutes on server Servername:" + "~n" +
                                "Task Name: " + sas-task-01.name + "~n" +
                                "Task Description: " + sas-task-01.description + "~n" +
                                "Task Owner: " + sas-task-01.created-by + "~n" +
                                "Task ID: " + STRING(sas-task-01.id) + "~n" +
                                "Task State: " + sas-task-01.state + "~n" +
                                "Scheduled Date: " + STRING(scheduled-date-time) + "~n".
            RUN send-email(INPUT "noreply-apprise@aptean.com",
                           INPUT "suraj.chopade@aptean.com",
                           INPUT "Alert: Stuck Task Detected (Task ID: " + STRING(sas-task-01.id) + ")",
                           INPUT "").
         END.
      END.
   END.
END.

IF stuck-satask-found = NO THEN
DO:
   MESSAGE "No Stuck SA Task Found"
       VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
END.

PROCEDURE send-email:
   DEF INPUT PARAMETER ip-from-addr AS CHAR NO-UNDO.
   DEF INPUT PARAMETER ip-to-addr AS CHAR NO-UNDO.
   DEF INPUT PARAMETER ip-subject AS CHAR NO-UNDO.
   DEF INPUT PARAMETER ip-body AS CHAR NO-UNDO.
   DEF VAR op-valid-send AS LOG NO-UNDO.   
   RUN SMTPEmail.p (INPUT ip-from-addr,
                    INPUT ip-to-addr,
                    INPUT ip-subject,
                    INPUT ip-body,
                    INPUT "",
                    INPUT "",  
                    OUTPUT op-valid-send). 
END.                    
