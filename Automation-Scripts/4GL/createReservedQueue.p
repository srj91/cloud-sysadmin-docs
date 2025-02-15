IF NOT CAN-FIND(FIRST sa-queue WHERE
    sa-queue.queue-name = "Reserved") THEN
DO:
   CREATE sa-queue.
   ASSIGN sa-queue.queue-name = "Reserved"
          sa-queue.dedicated-workers = 5
          sa-queue.all-system-ids = YES
          sa-queue.active = YES
          sa-queue.created-by = "AI1814720"
          sa-queue.created-date = TODAY
          sa-queue.created-time = STRING(TIME,"HH:MM:SS")
          sa-queue.update-by = "AI1814720"
          sa-queue.update-date = TODAY
          sa-queue.update-time = STRING(TIME,"HH:MM:SS").
   RELEASE sa-queue.
