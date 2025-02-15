DEFINE VARIABLE cUsername AS CHARACTER NO-UNDO INITIAL 'zapprise'.
DEFINE VARIABLE cNewPassword AS CHARACTER NO-UNDO INITIAL 'Zapprise123!'.

DEFINE TEMP-TABLE tempUser NO-UNDO LIKE _User.

FIND FIRST _User WHERE _User._UserId = cUsername EXCLUSIVE-LOCK NO-ERROR.
IF AVAILABLE (_User) THEN DO:
     BUFFER-COPY _User EXCEPT _User._Password TO tempUser ASSIGN tempUser._Password = encode(cNewPassword).
     DELETE _User.
     CREATE _User.
     BUFFER-COPY tempUser EXCEPT _TenantId TO _User.
END.
ELSE
     MESSAGE "This Userid does not exist"
          VIEW-AS ALERT-BOX INFO BUTTONS OK.
