/* Finds the date errors which exceed the 10 characters value of date field */

output to "L:\outfiles\arcust-10.txt".
for each arcust
         no-lock:
   if length(arcust.licexp) > 10 then
      export delimiter "^" compcust custno arcust.licexp.
end.