/*<pre><b>
/ Program   : remove.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to remove all occurrences of the target
/             string(s) from another string.
/ SubMacros : none
/ Notes     : none
/ Usage     : %let string2=%remove(&string1,XXX,yyy,YYY);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ string            (pos - unquoted) String to remove target from
/ target1-30        (pos - unquoted) Target string(s) to remove
/ casesens=no       Whether the search for the target(s) is case sensitive
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: remove v1.0;

%macro remove(string,
              target1,
              target2,
              target3,
              target4,
              target5,
              target6,
              target7,
              target8,
              target9,
              target10,
              target11,
              target12,
              target13,
              target14,
              target15,
              target16,
              target17,
              target18,
              target19,
              target20,
              target21,
              target22,
              target23,
              target24,
              target25,
              target26,
              target27,
              target28,
              target29,
              target30,
           casesens=no
              );

  %local i result index targlen beyond newstr;

  %if not %length(&casesens) %then %let casesens=no;
  %let casesens=%upcase(%substr(&casesens,1,1));

  %let result=&string;

  %do i=1 %to 30;
    %let targlen=%length(&&target&i);
    %if &targlen %then %do;
      %if "&casesens" EQ "Y" %then %let index=%index(&result,&&target&i);
      %else %let index=%index(%qupcase(&result),%qupcase(&&target&i));
      %do %while(&index GT 0);
        %if &index GT 1 %then %let newstr=%qsubstr(&result,1,%eval(&index-1));
        %else %let newstr=;
        %let beyond=%eval(&index+&targlen);
        %if &beyond LE %length(&result) %then %let newstr=&newstr%qsubstr(&result,&beyond);
        %let result=&newstr;
        %if "&casesens" EQ "Y" %then %let index=%index(&result,&&target&i);
        %else %let index=%index(%qupcase(&result),%qupcase(&&target&i));
      %end;
    %end;
  %end;

&result

%mend remove;
