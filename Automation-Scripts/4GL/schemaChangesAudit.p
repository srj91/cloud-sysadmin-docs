/* This script is used to track schema changes during period like 1st OCT 2023 and 1st OCT 2024. */
/*
Input File: The file you store output content like C:\localrepo\working\schemaChanges.txt
Start Date (mm/dd/yy): We track changes start from this date .
End Date (mm/dd/yy): We track changes end to this date.
*/
DEFINE VARIABLE ip-file AS CHARACTER NO-UNDO FORMAT "X(60)" LABEL "Input File" VIEW-AS FILL-IN.
DEFINE VARIABLE fromDate AS Date NO-UNDO FORMAT "99/99/9999" LABEL "Start Date" .  
DEFINE VARIABLE endDate AS Date NO-UNDO FORMAT "99/99/9999" LABEL "End Date". 
DEFINE BUTTON btn-audit LABEL "Audit".

FUNCTION track-schema-changes RETURNS CHARACTER (INPUT ip-file AS CHARACTER, INPUT fromDate AS DATE, INPUT endDate AS DATE):
    DEFINE BUFFER tt-loaded FOR ac-del-loaded.
    DEFINE BUFFER tt-manual-df FOR ac-delivery-extra.

    OUTPUT TO VALUE(ip-file) UNBUFFERED.

    FOR EACH tt-loaded WHERE 
            tt-loaded.loaded-date >= fromDate AND 
            tt-loaded.loaded-date <= endDate
        NO-LOCK,
        EACH tt-manual-df WHERE 
            tt-manual-df.delivery-key = tt-loaded.delivery-key AND 
            tt-manual-df.type-df = YES
        NO-LOCK:
            PUT UNFORMATTED "DF name: " + tt-manual-df.file-name + " Loaded Date: " + STRING(tt-loaded.loaded-date) SKIP.
    END.
    RETURN "DONE.".
END FUNCTION.

ASSIGN fromDate = TODAY
       endDate = TODAY.
    

DEFINE FRAME main-frame
 ip-file fromDate endDate btn-audit
 WITH 3 COLUMNS  TITLE "Schema Changes Audit"
 WIDTH 80.
 
 DISPLAY fromDate WITH FRAME main-frame.
 DISPLAY endDate WITH FRAME main-frame.

 ON CHOOSE OF btn-audit DO:

    MESSAGE track-schema-changes(INPUT ip-file:SCREEN-VALUE,
                                 INPUT Date(fromDate:SCREEN-VALUE),
                                 INPUT Date(endDate:SCREEN-VALUE)).
END.
ENABLE ALL WITH FRAME main-frame.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

RETURN "0".


