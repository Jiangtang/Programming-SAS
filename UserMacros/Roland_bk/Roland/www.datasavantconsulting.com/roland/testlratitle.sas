/*<pre><b>
/ Program   : testlratitle.sas
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

*endsas;

options center number nodate ps=30;

data dummy;
dummy='dummy dummy';
run;

title1 'first title centred';

%lratitle(2,'title two left aligned bit', 
"title two right aligned bit")
%lratitle(3,'title 3 left aligned bit only') 
%lratitle(4,,"title 4 right aligned bit only");
%lratitle(5,'title 5 left aligned bit that is very long and will not leave much space Z', "title 5 right aligned bit")
%lratitle(6,'title 6 left aligned bit that is very long and will not leave much space YY', "title 6 right aligned bit")
%lratitle(7,'title 7 left aligned bit that is very long and will not leave much space XXX', "title 7 right aligned bit")

proc print;
run;


  