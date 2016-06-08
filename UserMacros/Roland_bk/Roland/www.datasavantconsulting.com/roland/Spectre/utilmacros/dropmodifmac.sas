/*<pre><b>
/ Program   : dropmodifmac.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 14-Jun-2013
/ Purpose   : Function-style macro to return a string with dataset modifiers
/             removed from a macro variable string containing single or multiple
/             dataset names with possible modifiers.
/ SubMacros : none
/ Notes     : Use this to strip out modifiers so you can find out how many
/             datasets there are in the string and what the datasets are called.
/
/             !!!! IMPORTANT !!!!   Always pass the string to this macro using
/             %SUPERQ() as shown in the usage notes otherwise right round
/             brackets that are part of the modifiers might get dropped duing
/             processing when they should not be.
/
/ Usage     : %let str=ds1(where=(a=:")" and b=:')')) lib.ds2(drop = v1 v2);
/             %put >>> %dropmodifmac(%superq(str));
/             >>> ds1 lib.ds2
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) string containing dataset names with modifiers
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  14Jun13         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: dropmodifmac v1.0;

%macro dropmodifmac(str);
  %local tempstr;
  %*- non-greedy replace stuff in double quotes with "§" -;
  %let tempstr=%sysfunc(prxchange(s!%str(%").*?%str(%")!"§"!,-1,
    %superq(str)));
  %*- non-greedy replace stuff in single quotes with '§' -;
  %let tempstr=%sysfunc(prxchange(s!%str(%').*?%str(%')!'§'!,-1,
    %superq(tempstr)));
  %*- repeat until we have no more left round brackets   -;
  %do %while( %index(%superq(tempstr),%str(%()) );
    %*- Non-greedy replace stuff inside "( )" that does  -;
    %*- not include a left round bracket with null.      -;
    %let tempstr=%sysfunc(prxchange(s!\%str(%()[^\%str(%()]*?\%str(%))!!,-1,
      %superq(tempstr)));
  %end;
&tempstr
%mend dropmodifmac;

