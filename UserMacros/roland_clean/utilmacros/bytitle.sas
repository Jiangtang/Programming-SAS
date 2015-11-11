/*<pre><b>
/ Program   : bytitle.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To drop the last title if it is a "by" title and write it to the
/             global macro variable _bytitle_ instead.
/ SubMacros : %maxtitle %casestrvar
/ Notes     : A "by" title, as far as this macro is concerned, is any lastly
/             defined title that contains "#BYVAR" or "#BYVAL" in the uppercased
/             text. These keywords wil be capitalized in the text written to the
/             global macro variable _bytitle_ for convenience.
/ Usage     : %bytitle
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ 
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: bytitle v1.0;

%macro bytitle;

  %global _bytitle_;
  %let _bytitle_=;

  %maxtitle

  data _null_;
    length text $ 200;
    set sashelp.vtitle(where=(type='T' and number=&_maxtitle_));
    if index(upcase(text),'#BYVAR') or index(upcase(text),'#BYVAL') then do;
      %casestrvar(text,'#BYVAR');
      %casestrvar(text,'#BYVAL');
      call symput('_bytitle_',text);
      call execute("title&_maxtitle_;");
    end;
  run;

%mend bytitle;
