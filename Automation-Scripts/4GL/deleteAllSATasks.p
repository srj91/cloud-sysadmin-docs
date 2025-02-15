FOR EACH sas-task EXCLUSIVE-LOCK:
DELETE sas-task.
END.
FOR EACH sas-task-schedule EXCLUSIVE-LOCK:
DELETE sas-task-schedule.
END.
FOR EACH sas-task-run EXCLUSIVE-LOCK :
DELETE sas-task-run.
END.
FOR EACH sas-task-param EXCLUSIVE-LOCK :
DELETE sas-task-param.
END.
