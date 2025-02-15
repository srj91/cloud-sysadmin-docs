DEFINE VARIABLE ip-archive AS LOGICAL INIT YES NO-UNDO.
DEFINE VARIABLE ip-archive-char AS CHAR INIT "YES" NO-UNDO.
DEFINE VARIABLE ip-archive-file AS CHAR INIT "C:\temp\" NO-UNDO.
DEFINE VARIABLE ip-prior-date AS DATE NO-UNDO.
DEFINE VARIABLE ip-prior-date-char AS CHARACTER NO-UNDO.
DEFINE VARIABLE out-file-name AS CHAR NO-UNDO.

DEFINE BUFFER sas-task-01 FOR sas-task.
DEFINE BUFFER sas-task-schedule-01 FOR sas-task-schedule.
DEFINE BUFFER sas-task-param-01 FOR sas-task-param.
DEFINE BUFFER sas-task-run-01 FOR sas-task-run.        
DEFINE TEMP-TABLE temp-sas-task-schedule LIKE sas-task-schedule.
DEFINE TEMP-TABLE temp-sas-task-param LIKE sas-task-param.
DEFINE TEMP-TABLE temp-sas-task-run LIKE sas-task-run.
DEFINE TEMP-TABLE temp-sas-task LIKE sas-task.
DEFINE VARIABLE tmpSATask AS SATask NO-UNDO.
DEFINE VARIABLE utcConv AS UtcDateTimeConverter NO-UNDO.
DEFINE VARIABLE cont AS LOGICAL INIT YES NO-UNDO.
DEFINE VARIABLE cnt AS INT NO-UNDO.
DEFINE VARIABLE cont-hdr AS LOGICAL INIT YES NO-UNDO.
DEFINE VARIABLE cnt-hdr AS INT NO-UNDO.
DEFINE STREAM arc-stream.

MESSAGE "Keep an Archive File? (YES/NO)" UPDATE ip-archive-char FORMAT "X(3)". 
ASSIGN ip-archive = LOGICAL(ip-archive-char) NO-ERROR.
IF ip-archive THEN
DO:
   MESSAGE "Please input Archive File Directory:" UPDATE ip-archive-file FORMAT "X(60)".
END.
MESSAGE "Purge Records Prior to (format: 99/99/9999):" UPDATE ip-prior-date-char FORMAT "X(10)".
ASSIGN ip-prior-date = DATE(ip-prior-date-char) NO-ERROR.
IF ip-prior-date + 91 > TODAY THEN
DO:
   MESSAGE "Prior-to date must be earlier than " STRING(TODAY - 90, "99/99/9999") VIEW-AS ALERT-BOX.
   MESSAGE "Re-Enter Purge Records Prior to (format: 99/99/9999):" UPDATE ip-prior-date-char FORMAT "X(10)".
   ASSIGN ip-prior-date = DATE(ip-prior-date-char) NO-ERROR.
END.

IF ip-prior-date + 91 > TODAY THEN
DO:
   MESSAGE "Prior-to date must be earlier than " STRING(TODAY - 90, "99/99/9999") VIEW-AS ALERT-BOX.
   RETURN. 
END.

IF ip-prior-date = ? THEN
DO:
   MESSAGE "Prior-to date does not match the format: 99/99/9999" VIEW-AS ALERT-BOX.
   RETURN.
END.

ASSIGN ip-archive-file = RIGHT-TRIM(ip-archive-file, "\") + "\".

MESSAGE "Starting to purge Scheduling Assistant Tasks which update date is prior to " ip-prior-date-char.
/* Purge Scheduling Assistant Tasks */
EMPTY TEMP-TABLE temp-sas-task-schedule.
EMPTY TEMP-TABLE temp-sas-task-param.
EMPTY TEMP-TABLE temp-sas-task-run.
EMPTY TEMP-TABLE temp-sas-task.
/*UTC date -- not done*/
ASSIGN utcConv = NEW UtcDateTimeConverter(ip-prior-date, STRING(TIME, "HH:MM:SS"), UtcConvertAction:FromLocalToUtc).
ASSIGN cnt-hdr = 0
       cont-hdr = YES.   
DO WHILE cont-hdr = YES:
   FOR EACH sas-task-01 WHERE
            sas-task-01.update-date-utc < utcConv:OutDate 
            EXCLUSIVE-LOCK:
      PROCESS EVENTS.         
      ASSIGN cnt-hdr = cnt-hdr + 1.         
      IF ip-archive THEN
      DO:
         FOR EACH sas-task-schedule-01 WHERE
                  sas-task-schedule-01.task-id = sas-task-01.id
                  NO-LOCK:
            FOR EACH sas-task-run-01 WHERE
                     sas-task-run-01.task-schedule-id = sas-task-schedule-01.id
                     NO-LOCK:
               CREATE temp-sas-task-run.
               BUFFER-COPY sas-task-run-01 TO temp-sas-task-run.
               RELEASE temp-sas-task-run.           
            END.
            CREATE temp-sas-task-schedule.
            BUFFER-COPY sas-task-schedule-01 TO temp-sas-task-schedule.
            RELEASE temp-sas-task-schedule.             
         END.
         FOR EACH sas-task-param-01 WHERE
                  sas-task-param-01.task-id = sas-task-01.id
                  NO-LOCK:
            CREATE temp-sas-task-param.
            BUFFER-COPY sas-task-param-01 TO temp-sas-task-param.
            RELEASE temp-sas-task-param.
         END. 
         CREATE temp-sas-task.
         BUFFER-COPY sas-task-01 TO temp-sas-task.
         RELEASE temp-sas-task.
         RELEASE sas-task-01.
      END.
      ELSE
      DO:
         ASSIGN tmpSATask = TaskHelper:GetAnyTask(INT64(sas-task-01.id)).
         TaskHelper:DeleteTask(tmpSATask).
         ASSIGN tmpSATask = ?.
      END.
      IF cnt-hdr = 200 THEN
         LEAVE.
   END.      
   IF cnt-hdr < 200 THEN
      ASSIGN cont-hdr = NO.
   ELSE
      ASSIGN cnt-hdr = 0. 
END.
IF ip-archive THEN
DO:         
   ASSIGN cnt = 0
          cont = YES.
   ASSIGN out-file-name = ip-archive-file + " schedule-assist-run.txt".
   OUTPUT STREAM arc-stream TO VALUE(out-file-name) APPEND.
   DO WHILE cont = YES:
      FOR EACH temp-sas-task-run 
               EXCLUSIVE-LOCK:
         PROCESS EVENTS.
         ASSIGN cnt = cnt + 1.
         EXPORT STREAM arc-stream temp-sas-task-run.
         FOR FIRST sas-task-run-01 WHERE
                   sas-task-run-01.id = temp-sas-task-run.id
                   EXCLUSIVE-LOCK:
            DELETE sas-task-run-01.
         END.
         DELETE temp-sas-task-run.
         IF cnt = 200 THEN
            LEAVE.
      END.
      IF cnt < 200 THEN
         ASSIGN cont = NO.
      ELSE
         ASSIGN cnt = 0.
   END.            
   OUTPUT STREAM arc-stream CLOSE.
   
   ASSIGN cnt = 0
          cont = YES.
   ASSIGN out-file-name = ip-archive-file + " schedule-assist-schedule.txt".
   OUTPUT STREAM arc-stream TO VALUE(out-file-name) APPEND.
   DO WHILE cont = YES:
      FOR EACH temp-sas-task-schedule 
               EXCLUSIVE-LOCK:
         PROCESS EVENTS.
         ASSIGN cnt = cnt + 1.
         EXPORT STREAM arc-stream temp-sas-task-schedule.
         FOR FIRST sas-task-schedule-01 WHERE
                   sas-task-schedule-01.id = temp-sas-task-schedule.id
                   EXCLUSIVE-LOCK:
            DELETE sas-task-schedule-01.
         END.
         DELETE temp-sas-task-schedule.
         IF cnt = 200 THEN
            LEAVE.
      END.
      IF cnt < 200 THEN
         ASSIGN cont = NO.
      ELSE
         ASSIGN cnt = 0.
   END.               
   OUTPUT STREAM arc-stream CLOSE.
   
   ASSIGN cnt = 0
          cont = YES.
   ASSIGN out-file-name = ip-archive-file + " schedule-assist-parameter.txt".
   OUTPUT STREAM arc-stream TO VALUE(out-file-name) APPEND.
   DO WHILE cont = YES:
      FOR EACH temp-sas-task-param 
               EXCLUSIVE-LOCK:
         PROCESS EVENTS.
         ASSIGN cnt = cnt + 1.
         EXPORT STREAM arc-stream temp-sas-task-param.
         FOR FIRST sas-task-param-01 WHERE
                   sas-task-param-01.id = temp-sas-task-param.id
                   EXCLUSIVE-LOCK:
            DELETE sas-task-param-01.
         END.
         DELETE temp-sas-task-param.
         IF cnt = 200 THEN
            LEAVE.
      END.
      IF cnt < 200 THEN
         ASSIGN cont = NO.
      ELSE
         ASSIGN cnt = 0.
   END.    
   OUTPUT STREAM arc-stream CLOSE.  
   
   ASSIGN cnt = 0
          cont = YES.   
   ASSIGN out-file-name = ip-archive-file + " scheduling-assistant-tasks.txt".
   OUTPUT STREAM arc-stream TO VALUE(out-file-name) APPEND.
   DO WHILE cont = YES:
      FOR EACH temp-sas-task
               EXCLUSIVE-LOCK:
         PROCESS EVENTS.         
         ASSIGN cnt = cnt + 1.
         EXPORT STREAM arc-stream temp-sas-task.
         FOR FIRST sas-task-01 WHERE
                   sas-task-01.id = temp-sas-task.id
                   EXCLUSIVE-LOCK:
            DELETE sas-task-01.
         END.
         DELETE temp-sas-task.    
         IF cnt = 200 THEN
            LEAVE.
      END.
      IF cnt < 200 THEN
         ASSIGN cont = NO.
      ELSE
         ASSIGN cnt = 0. 
   END.
   OUTPUT STREAM arc-stream CLOSE.     
END.                
MESSAGE "Purge Scheduling Assistant Tasks completed.".


MESSAGE "Starting to purge Scheduling Assistant Recurring Tasks History which completed date is prior to " ip-prior-date-char.
/* Purge Scheduling Assistant Recurring Tasks History */   
EMPTY TEMP-TABLE temp-sas-task-schedule.
EMPTY TEMP-TABLE temp-sas-task-param.
EMPTY TEMP-TABLE temp-sas-task-run.  
/*UTC date -- not done*/
ASSIGN utcConv = NEW UtcDateTimeConverter(ip-prior-date, STRING(TIME, "HH:MM:SS"), UtcConvertAction:FromLocalToUtc).
ASSIGN cnt-hdr = 0
       cont-hdr = YES.   
DO WHILE cont-hdr = YES:
   FOR EACH sas-task-01 WHERE
            sas-task-01.submit-date-utc < utcConv:OutDate 
            NO-LOCK:
      IF NOT SAUtils:IsTaskRecurring(sas-task-01.id) THEN
         NEXT.
      FOR EACH sas-task-schedule-01 WHERE
               sas-task-schedule-01.task-id = sas-task-01.id //AND
               // sas-task-schedule-01.completed = YES AND
               // sas-task-schedule-01.completed-date-utc < utcConv:OutDate
               NO-LOCK:
         PROCESS EVENTS.
         IF sas-task-schedule-01.completed-date-utc <> ? AND 
            sas-task-schedule-01.completed-date-utc < utcConv:OutDate THEN
         DO:
            FOR EACH sas-task-param-01 WHERE
                     sas-task-param-01.task-schedule-id = sas-task-schedule-01.id
                     NO-LOCK:
               CREATE temp-sas-task-param.
               BUFFER-COPY sas-task-param-01 TO temp-sas-task-param.      
               RELEASE temp-sas-task-param.
               RELEASE sas-task-param-01.
            END.   
            FOR EACH sas-task-run-01 WHERE
                     sas-task-run-01.task-schedule-id = sas-task-schedule-01.id
                     NO-LOCK:
               CREATE temp-sas-task-run.
               BUFFER-COPY sas-task-run-01 TO temp-sas-task-run.   
               RELEASE temp-sas-task-run.
               RELEASE sas-task-run-01.
            END.
            CREATE temp-sas-task-schedule.
            BUFFER-COPY sas-task-schedule-01 TO temp-sas-task-schedule.
            RELEASE temp-sas-task-schedule.
                     end.
         RELEASE sas-task-schedule-01.                         
      END. 
      IF cnt-hdr = 200 THEN
         LEAVE.
   END.      
   IF cnt-hdr < 200 THEN
      ASSIGN cont-hdr = NO.
   ELSE
      ASSIGN cnt-hdr = 0.
END.
IF ip-archive THEN
DO:      
   ASSIGN cnt = 0
          cont = YES.
   ASSIGN out-file-name = ip-archive-file + " schedule-assist-run-hist.txt".
   OUTPUT STREAM arc-stream TO VALUE(out-file-name) APPEND.
   DO WHILE cont = YES:
      FOR EACH temp-sas-task-run 
               EXCLUSIVE-LOCK:
         PROCESS EVENTS.
         ASSIGN cnt = cnt + 1.
         EXPORT STREAM arc-stream temp-sas-task-run.
         FOR FIRST sas-task-run-01 WHERE
                   sas-task-run-01.id = temp-sas-task-run.id
                   EXCLUSIVE-LOCK:
            DELETE sas-task-run-01.
         END.
         DELETE temp-sas-task-run.
         IF cnt = 200 THEN
            LEAVE.
      END.
      IF cnt < 200 THEN
         ASSIGN cont = NO.
      ELSE
         ASSIGN cnt = 0.
   END.           
   OUTPUT STREAM arc-stream CLOSE.
   
   ASSIGN cnt = 0
          cont = YES.
   ASSIGN out-file-name = ip-archive-file + " schedule-assist-schedule-hist.txt".
   OUTPUT STREAM arc-stream TO VALUE(out-file-name) APPEND.
   DO WHILE cont = YES:
      FOR EACH temp-sas-task-schedule 
               EXCLUSIVE-LOCK:
         PROCESS EVENTS.
         ASSIGN cnt = cnt + 1.
         EXPORT STREAM arc-stream temp-sas-task-schedule.
         FOR FIRST sas-task-schedule-01 WHERE
                   sas-task-schedule-01.id = temp-sas-task-schedule.id
                   EXCLUSIVE-LOCK:
            DELETE sas-task-schedule-01.
         END.
         DELETE temp-sas-task-schedule.
         IF cnt = 200 THEN
            LEAVE.
      END.
      IF cnt < 200 THEN
         ASSIGN cont = NO.
      ELSE
         ASSIGN cnt = 0.
   END.         
   OUTPUT STREAM arc-stream CLOSE.
   
   ASSIGN cnt = 0
          cont = YES.
   ASSIGN out-file-name = ip-archive-file + " schedule-assist-parameter-hist.txt".
   OUTPUT STREAM arc-stream TO VALUE(out-file-name) APPEND.
   DO WHILE cont = YES:
      FOR EACH temp-sas-task-param 
               EXCLUSIVE-LOCK:
         PROCESS EVENTS.
         ASSIGN cnt = cnt + 1.
         EXPORT STREAM arc-stream temp-sas-task-param.
         FOR FIRST sas-task-param-01 WHERE
                   sas-task-param-01.id = temp-sas-task-param.id
                   EXCLUSIVE-LOCK:
            DELETE sas-task-param-01.
         END.
         DELETE temp-sas-task-param.
         IF cnt = 200 THEN
            LEAVE.
      END.
      IF cnt < 200 THEN
         ASSIGN cont = NO.
      ELSE
         ASSIGN cnt = 0.
   END. 
   OUTPUT STREAM arc-stream CLOSE.
END.
MESSAGE "Purge Scheduling Assistant Recurring Tasks History completed.".
