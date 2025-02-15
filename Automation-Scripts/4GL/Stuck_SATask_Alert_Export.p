DEF VAR op-file AS CHAR INIT "E:\Temp\stuck_tasks.txt" NO-UNDO. 

DEF VAR ip-duration AS INT INIT 1 NO-UNDO.  /*Default 1 hour*/
DEF VAR stuck-satask-found AS LOG NO-UNDO.

OUTPUT TO VALUE(op-file).
   
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
            sas-task-01.id = sas-task-schedule-01.task-id AND
            sas-task-01.queue-name <> "Reserved"
            NO-LOCK:
           
      ASSIGN utcConv = NEW UtcDateTimeConverter(sas-task-schedule-01.started-date-utc, sas-task-schedule-01.started-time-utc, UtcConvertAction:FromUtcToLocal)
             started-date = utcConv:OutDate
             started-time = utcConv:OutTime
             scheduled-date-time = DATETIME(STRING(started-date) + " " + started-time)
             in-progress-duration = SAUtils:CalcDuration(utcConv:OutTime, utcConv:OutDate, DATETIME(TODAY, MTIME)).
      IF in-progress-duration > ip-duration THEN
      DO:
         ASSIGN stuck-satask-found = YES.
         PUT UNFORMATTED "The following task has been running for more than 60 minutes on server Servername:" SKIP.
         PUT UNFORMATTED "Task Name: " + sas-task-01.name SKIP.
         PUT UNFORMATTED "Task Description: " + sas-task-01.description SKIP.
         PUT UNFORMATTED "Task Owner: " + sas-task-01.created-by SKIP.
         PUT UNFORMATTED "Task ID: " + STRING(sas-task-01.id) SKIP.
         PUT UNFORMATTED "Task State: " + sas-task-01.state SKIP.
         PUT UNFORMATTED "Started Date: " + STRING(scheduled-date-time) SKIP.
         PUT UNFORMATTED "Duration: " + STRING(in-progress-duration / 60 / 60, ">>>>.99") + " hours." SKIP.
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
               sas-task-01.state = "Pending" AND
               sas-task-01.queue-name <> "Reserved"
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
            ASSIGN stuck-satask-found = YES.
            PUT UNFORMATTED "The following task has been running for more than 60 minutes on server Servername:" SKIP.
            PUT UNFORMATTED "Task Name: " + sas-task-01.name SKIP.
            PUT UNFORMATTED "Task Description: " + sas-task-01.description SKIP.
            PUT UNFORMATTED "Task Owner: " + sas-task-01.created-by SKIP.
            PUT UNFORMATTED "Task ID: " + STRING(sas-task-01.id) SKIP.
            PUT UNFORMATTED "Task State: " + sas-task-01.state SKIP.
            PUT UNFORMATTED "Scheduled Date: " + STRING(scheduled-date-time) SKIP.            
         END.
      END.
   END.
END.
IF stuck-satask-found = NO THEN
   PUT UNFORMATTED "No Stuck SA Task Found." SKIP.
   
OUTPUT TO CLOSE.
