/*<pre><b>
/ Program   : testfixvars.sas
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

data rol;
  length a $ 1 x 6;
  a='a';
  x=66;
  z=11;
  label a='aaaaa bbbbbbb cccccc dddddddd' z='Label for z';
  format z 2.;
run;

data rol2;
  length a $ 5;
  a='aaaaa';
  x=99;
  z=22;
  attrib a format=$char5. label='Label for variable "a"' 
         x format=3. label='variable x'
         ;
run;

data rol3;
  length a $ 1 x 6;
  a='a';
  x=66;
  z=11;
  label a='aaaaa bbbbbbb cccccc dddddddd' z='Label for z';
  format z 2.;
run;

%*- First run this in "read" mode to create the flat file then   -;
%*- edit the flat file to remove duplicate variable information. -;
%*- After that run in "write" mode with the "proc contents" steps-;
%*- enabled to ensure variables have been updated. Note that an  -;
%*- "F" in front of a numeric format is not a problem and can be -;
%*- ignored. -;

%fixvars(work,read,flatfile='testfixvars.txt')

endsas;

proc contents data=rol;
run;

proc contents data=rol2;
run;

proc contents data=rol3;
run;
