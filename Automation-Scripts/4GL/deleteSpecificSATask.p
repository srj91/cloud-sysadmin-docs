FOR EACH sas-task WHERE
sas-task.id = <task id>  // provide the task ID
EXCLUSIVE-LOCK:
ASSIGN sas-task.pending-action-method = "".
ASSIGN sas-task.pending-action-set = NO.
ASSIGN sas-task.state = "Cancelled".
ASSIGN sas-task.reserved-support = "AIXXXXXXXX".
RELEASE sas-task.
END.
