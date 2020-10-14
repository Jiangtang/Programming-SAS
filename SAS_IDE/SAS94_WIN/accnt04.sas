data work.billing;
set clinic.insure;
run;
proc print data=work.billing keylabel;
label total='Total Balance' balancedue='Balance Due';
run;
