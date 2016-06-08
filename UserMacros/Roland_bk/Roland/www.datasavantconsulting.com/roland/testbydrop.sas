/*<pre><b>
/ Program   : testbydrop.sas
/ Version   : 1.0
/ Tester    : -------
/ Date      : -- --- 2003
/ Purpose   : Test pack for macro whose identity follows "test" in program name.
/ Notes     : This test pack is for validating the macro whose name follows 
/             "test" in the program name above. Only the user can validate the
/             macros. The user must add to or change the code below to the extent
/             that they are satisfied that the macro being tested is performing
/             correctly. The user must keep this code member and its log and, 
/             if relevent, list output in a secure place to prove they have done
/             this and that the macro is working as intended and fulfil any other
/             mandatory requirements before the macro being tested could be
/             deemed as "validated" and fit to run in a production environment.
/             Also the macros, once validated, must be kept in an area where only
/             those authorised to do so can update the macros and only if they 
/             follow mandatory procedures for initiating change, changing and re-
/             validating the macros and follow any other mandatory procedures for
/             doing so.
/
/             First line contains "endsas;" so this code as supplied will
/             terminate and not run unless the user makes changes. If "endsas;"
/             is present as the first line of code then it means this test pack
/             has not been run against the macro being tested. The tester should
/             fill in the "Tester" and "Date" fields above and any amendments to
/             the test pack should be documented in the "Amendment History"
/             section below.
/================================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description-------------------------
/ 
/===============================================================================*/

endsas;

options nocenter;
data test;
  year=1990;
  x=1;
  output;

  year=1991;
  do x=1 to 10;
    output;
  end;
run;


proc sort data=test;
  by year x;
run;



%*- standard use -;
%bydrop(test,year,test2)
proc print data=test2;
title 'Standard use';
run;

%*- change fraction to very small -;
%bydrop(test,year,test2,fraction=0.05)
proc print data=test2;
title 'Change fraction to very small';
run;

%*- use defaulting "sortedby" first variable -;
%bydrop(test,,test2)
proc print data=test2;
title 'Use defaulting "sortedby" first variable';
run;

%*- all defaults and replace original dataset -;
%bydrop(test)
proc print data=test;
title 'Full defaults in effect and dataset replaced';
run;
