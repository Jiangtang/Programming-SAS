/*display a list of the available styles */

proc template;
   list styles;
run;

proc sql;
select * from dictionary.styles;
quit;
