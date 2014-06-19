/*<pre><b>
/ Program   : splitvar.sas
/ Version   : 4.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 06-Mar-2012
/ Purpose   : In-datastep macro to insert split characters in a string variable
/ SubMacros : none
/ Notes     : A split character will normally be placed in a blank space. If
/             there is no suitable space then it will be inserted after a hyphen
/             or a comma but if there is no suitable space and no hyphen or
/             comma then it will be inserted at the end. Searches for spaces
/             and hyphens or commas are only done for half the column width so
/             that the number of lines used for overflow is kept to a limit.
/
/             The string with the split characters added will normally be
/             assigned to a new variable whose name you choose. If left blank
/             then the new string in reassigned to the input variable.
/
/             Indentation is maintained such that if you had to split a string
/             which was indented two spaces then the next segment of the string
/             will also be indented two spaces. You can add to this indentation
/             to create a "hanging indent" using the hindent= parameter to make
/             it clearer that following line segments are a continuation of the
/             first one.
/
/             This macro is a rewrite of the earlier versions of the same name
/             and there is no backward compatibility possible.
/
/             This macro will only work on Western character sets such that one
/             letter uses one byte. If you want a macro to work with Asian
/             characters then you will have to make a copy of this macro that
/             uses the "k" functions such as klength(), ksubstr() etc. in place
/             of the normal string functions as used in this macro. If somebody
/             wants to do this then please call the macro %ksplitvar and get in
/             contact with me. Do not make changes to the logic, just amend the
/             code in this macro as the logic is very complicated.
/
/             Note that this is not a function-style macro. It must be used in a
/             data step as shown in the usage notes.
/
/ Usage     : data aaa;
/               set aaa;
/               %splitvar(oldvar,newvar,10,split=/,hindent=0);
/             run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ oldvar            (pos) Variable to split.
/ newvar            (pos) New variable created with split characters added.
/ width             (pos) The maximum width of the column as displayed.
/ split=@           Split character. Must be a single character (quoted or
/                   unquoted).
/ spliton=",-"      Characters to split after (quoted)
/ splitat=" "       Preferred character to split at (quoted - the split
/                   character will replace this character).
/ colon=": "        Colon character string for indented splits (quoted)
/ hindent=0         By default, do not show following string segments with a 
/                   hanging indent. Set to a positive integer to indent the
/                   following line segments by that number of spaces.
/ usecolon=yes      By default, if ": " occurs in the string start within 30% of
/                   the defined width then use this to align following line
/                   segments.
/ biglen=8040       Default large working length
/===============================================================================
/ TEST CODE FOLLOWS:
/===============================================================================
options nocenter nonumber nodate;
title;

%let width=30;
%let split=/;
%let hindent=4;

data test;
length term $ 200;
term="SOC short term";
output;
term="  PT short 1";
output;
term="  PT short 2";
output;
term=" ";
output;
term="System Organ Class long term that is going to flow to more lines";
output;
term="  PT short 1";
output;
term="  PT short 2";
output;
term="  Preferred term code that is also long and is going to flow to more lines";
output;
term="  Indented: preferred term code that is also long and is going to flow to more lines";
output;
term="  Indented comma-delimited list of patient numbers 1234,1234,1234,1234,1234,1234,1234";
output;
run;

data test2;
  set test;
  %splitvar(term,term2,&width,split=&split,hindent=&hindent);
run;

proc report nowd data=test2 split="&split" headline headskip;
columns term2;
define term2 / "SOC" "  Preferred Term" display flow width=&width spacing=0;
run;
/===============================================================================
/ TEST OUTPUT FOLLOWS:
/===============================================================================
SOC
  Preferred Term
______________________________

SOC short term
  PT short 1
  PT short 2

System Organ Class long term
    that is going to flow to
    more lines
  PT short 1
  PT short 2
  Preferred term code that is
      also long and is going
      to flow to more lines
  Indented: preferred term
            code that is also
            long and is going
            to flow to more
            lines
  Indented comma-delimited
      list of patient numbers
      1234,1234,1234,1234,
      1234,1234,1234
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  07Sep07         Header tidy
/ rrb  04May11         Code tidy
/ rrb  14Jul11         Rewritten (v2.0)
/ rrb  19Aug11         Added usecolon= parameter and changed indent parameter
/                      to hindent= (v3.0)
/ rrb  25Aug11         Header tidy
/ rrb  19Oct11         Bug with __minw value fixed (v3.1)
/ rrb  28Oct11         Bug with lenvar fixed (v3.2)
/ rrb  26Dec11         Header update to explain that this macro only works on
/                      Western character sets.
/ rrb  13Jan12         Commas as well as hyphens can be a split point (v3.3)
/ rrb  14Jan12         Increased work variable length to 8040 (v3.4)
/ rrb  07Feb12         No longer set the length of the new variable (v3.5)
/ rrb  15Feb12         biglen= added (v3.6)
/ rrb  06Mar12         spliton=, splitat= and colon= parameters added plus minor
/                      code changes to make it more like the %ksplitvar macro
/                      for utf-8 encoding (v4.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: splitvar v4.0;

%macro splitvar(oldvar,
                newvar,
                width,
                split=@,
                hindent=0,
                usecolon=yes,
                biglen=8040,
                spliton=",-",
                splitat=" ",
                colon=": ",
                debug=n);

  %local err errflag lenvar;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&debug) %then %let debug=n;
  %let debug=%upcase(%substr(&debug,1,1));

  %if not %length(&usecolon) %then %let usecolon=yes;
  %let usecolon=%upcase(%substr(&usecolon,1,1));

  %if not %length(&newvar) %then %let newvar=&oldvar;
  %else %let lenvar=&newvar;

  %if not %length(&split) %then %let split=@;
  %else %let split=%sysfunc(dequote(&split));

  %if not %length(&width) %then %do;
    %put &err: (splitvar) No width specified as third parameter;
    %let errflag=1;
  %end;
  %else %do;
    %if %length(%sysfunc(compress(&width,0123456789))) %then %do;
      %put &err: (splitvar) You must supply a positive integer value to width=&width;
      %let errflag=1;
    %end;
  %end;

  %if not %length(&hindent) %then %let hindent=0;
  %if %length(%sysfunc(compress(&hindent,0123456789))) %then %do;
    %put &err: (splitvar) You must supply a positive integer value to hindent=&hindent;
    %let errflag=1;
  %end;

  %if not %length(&biglen) %then %let biglen=8040;

  %if &errflag %then %goto exit;

  length __newstr __rest $ &biglen ;

  if length(&oldvar) LE &width then __newstr=&oldvar;
  else do;
    __hindent=&hindent;
    __newstr=" ";
    __rest=&oldvar;
    %if "&usecolon" NE "N" %then %do;
      if 0 LT index(left(__rest),&colon) LE (&width*0.3) 
       then __hindent=index(left(__rest),&colon)+lengthc(&colon)-1;
    %end;
    __indent=verify(__rest," ")-1;
    do while(__rest NE " ");
      __minw=max(__indent+__hindent+1,floor(&width/2));
      %if &debug EQ Y %then %do;
        put __minw= __indent= __hindent=;
        put __rest=;
      %end;
      do __i=(&width+1) to __minw by -1;
        __break=0;
        if (substr(__rest,__i,1) EQ &splitat) 
         or (index(&spliton,substr(__rest,__i,1)) and __i LE &width) then do;
          __break=1;
          if substr(__rest,__i,1) EQ &splitat then do;
            if __newstr=" " then __newstr=trim(substr(__rest,1,__i-1))||"&split";
            else __newstr=trim(__newstr)||trim(substr(__rest,1,__i-1))||"&split";
            __rest=trim(left(substr(__rest,__i+1)));
          end;
          else do;
            *- we have a split-on character that we need to show and keep -;
            if __newstr=" " then __newstr=trim(substr(__rest,1,__i))||"&split";
            else __newstr=trim(__newstr)||trim(substr(__rest,1,__i))||"&split";
            __rest=trim(left(substr(__rest,__i+1)));
          end;
          __i=1;
        end;
      end;
      if not __break then do;
        %if &debug EQ Y %then %do;
          put "NO BREAK FOUND in __rest last half";
          put __newstr=;
          put __rest=;
        %end;
        if __newstr=" " then __newstr=trim(substr(__rest,1,&width))||"&split";
        else __newstr=trim(__newstr)||trim(substr(__rest,1,&width))||"&split";
        __rest=trim(left(substr(__rest,&width+1)));
      end;
      __repspace=__indent+__hindent-1;
      if __repspace GE 0 then do;
        __rest=repeat(" ",__repspace)||__rest;
      end;
      %if &debug EQ Y %then %do;
        put __newstr=;
        put __rest=;
      %end;
    end;
  end;
  &newvar=__newstr;
  DROP __newstr __rest __i __break __minw __repspace __indent __hindent;

  %goto skip;
  %exit: %put &err: (splitvar) Leaving macro due to problem(s) listed;
  %skip:

%mend splitvar;
