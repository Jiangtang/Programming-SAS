data have;
infile cards truncover;
input subject  $     cause $90.;
cards;
1001         I am not smart, that's why you need help
1002         There must be a reason why you need help
1003         I tried but failed
;
run;

data want;

set have;
length cause1 $30;
if length(cause)>30 then do;
  if substr(cause,31,1)=' ' then do;
     cause2=substr(cause,31);
 cause1=cause;
   end;

   else do;
     cause1=prxchange('s/ (\w+|\w+\W)$//io',-1,substr(cause,1,30));
     cause2=substr(cause,length(cause1)+1);
   end;
end;
else cause1=cause;

run;
