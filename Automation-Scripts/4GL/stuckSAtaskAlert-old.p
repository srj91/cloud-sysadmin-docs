DEFINE VARIABLE v-task-id         AS INTEGER NO-UNDO.
DEFINE VARIABLE v-task-name       AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-task-desc       AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-task-owner      AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-task-state      AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-task-created    AS DATETIME NO-UNDO.
DEFINE VARIABLE v-current-time    AS DATETIME NO-UNDO.
DEFINE VARIABLE v-duration        AS DECIMAL NO-UNDO.
DEFINE VARIABLE v-email-subject   AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-email-body      AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-long-tasks      AS LOGICAL   NO-UNDO.

ASSIGN v-current-time = NOW.

FOR EACH sas-task WHERE sas-task.state = "In Progress":
    ASSIGN
        v-task-id      = sas-task.id
        v-task-name    = sas-task.name
        v-task-desc    = sas-task.description
        v-task-owner   = sas-task.created-by
        v-task-state   = sas-task.state
        v-task-created = sas-task.status. /* Assuming 'status' holds the last started time */
    
    /* Calculate the duration in minutes */
    ASSIGN v-duration = (v-current-time - v-task-created) / 60.

    IF v-duration > 60 THEN DO:
        ASSIGN v-long-tasks = TRUE.
        
        /* Create the email subject and body */
        ASSIGN
            v-email-subject = "Alert: Stuck Task Detected (Task ID: " + STRING(v-task-id) + ")"
            v-email-body    = "The following task has been running for more than 60 minutes on server Servername:" + "~n" +
                              "Task Name: " + v-task-name + "~n" +
                              "Task Description: " + v-task-desc + "~n" +
                              "Task Owner: " + v-task-owner + "~n" +
                              "Task ID: " + STRING(v-task-id) + "~n" +
                              "Task State: " + v-task-state + "~n" +
                              "Scheduled Date: " + STRING(v-task-created, "99/99/9999 HH:MM") + "~n" +
                              "Duration: " + STRING(v-duration) + " minutes." + "~n".

        /* Send the email */
        RUN send-email.
    END.
END.

IF NOT v-long-tasks THEN
    RETURN.

/* This is the procedure for sending the email with hardcoded parameters */
PROCEDURE send-email:
    /* SMTP Setup - Hardcoded values */
    DEFINE VARIABLE v-mail-server    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-from-address   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-recipient-email AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-smtp-port      AS INTEGER   NO-UNDO.
    DEFINE VARIABLE v-username       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-password       AS CHARACTER NO-UNDO.

    ASSIGN 
        v-mail-server    = "smtp.office365.com"         /* Replace with your SMTP server */
        v-from-address   = "noreply-apprise@aptean.com"    /* Replace with the sender's email */
        v-recipient-email = "suraj.chopade@aptean.com" /* Replace with the recipient email */
        v-smtp-port      = 587                         /* Standard SMTP port */
        v-username       = "noreply-apprise@aptean.com"  /* Replace with your SMTP username */
        v-password       = "Winter@123".            /* Replace with your SMTP password */

    /* Sending the email */
    RUN mail-send 
        (v-mail-server,               /* Mail server address */
         v-smtp-port,                 /* SMTP port */
         v-from-address,              /* Sender email address */
         v-recipient-email,           /* Recipient email address */
         v-email-subject,             /* Email subject */
         v-email-body,                /* Email body */
         v-username,                  /* SMTP Username */
         v-password).                 /* SMTP Password */

END PROCEDURE.
