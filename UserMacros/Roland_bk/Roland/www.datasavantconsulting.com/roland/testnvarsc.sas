/*<pre><b>
/ Program   : testnvarsc.sas
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

data test;
  dummy='dummy';
  num=2;
  dummy2='third var';
run;


%put >>>> number of character variables is %nvarsc(test) >>>>;
  
