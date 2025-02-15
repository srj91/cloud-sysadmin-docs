DEF VAR ii AS INT NO-UNDO.
FOR EACH sas-worker WHERE
         NO-LOCK:
   ASSIGN ii = ii + 1.
   DISP ii sas-worker.NAME sas-worker.state.
END.

*** Check SA queues and their dedicated workers ***

FOR EACH sa-queue WHERE
         NO-LOCK:
   DISP sa-queue.queue-name  sa-queue.ACTIVE sa-queue.dedicated-workers.
END.

