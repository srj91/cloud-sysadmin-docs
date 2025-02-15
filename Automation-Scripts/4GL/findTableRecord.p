DEFINE VARIABLE iRecordCount AS INTEGER NO-UNDO.

/* Connect to the Progress Database */

/* Assuming you have already established a database connection */

/* Replace 'your-table-name' with the name of your table */
FOR EACH trans-log NO-LOCK:
    iRecordCount = iRecordCount + 1.
END.

/* Display the number of records */
DISPLAY iRecordCount.
