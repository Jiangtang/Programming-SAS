/*<pre><b>
/ Program   : prxnames.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 01-Feb-2011
/ Purpose   : Function-style macro to convert a space-delimited list of sas
/             names (variable or dataset names) to a Pearl Regular Expression
/             for use in the prxmatch() function that takes into account the
/             ending colon notation.
/ SubMacros : none
/ Notes     : All sas names will be converted to upper case. Names such as "d:"
/             will match strings such as "D", "DABC", "D123". If the string
/             "aaa b:" (no quotes) is supplied then this will be converted
/             to the regular expression "/^AAA *$|^B.* *$/" which signifies a
/             regular expression (enclosed in "//") starting with ("^") "AAA"
/             and ending with ("$") zero or more spaces (" *") OR ("|") starting
/             with "B" followed by zero or more characters (".*") ending with
/             zero or more spaces.
/ Usage     : %let dslist=var1 var2 vx:;
/             ....where prxmatch(%prxnames(&dslist),memname);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) sas variable or dataset names separated by spaces with
/                   the ending colon notation allowed to represent sas names
/                   that start with what precedes the colon (no quotes).
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ 
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: prxnames v1.0;

%macro prxnames(str);
"/^%sysfunc(tranwrd(%sysfunc(tranwrd(%sysfunc(compbl(%upcase(&str))),%str( ),
%str( *$|^))),:,.*)) *$/"
%mend prxnames;
