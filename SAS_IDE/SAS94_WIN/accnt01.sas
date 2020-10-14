data work.balnew1;
set clinic.insure;
run;
proc print data=work.balnew1;
var id name total balancedue;
