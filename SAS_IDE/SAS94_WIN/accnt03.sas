data work.reliable;
set clini.insure;
where company='FRED SMYTHE;
run;
proc print data=work.reliable
var id name company total balancedue;
run;
