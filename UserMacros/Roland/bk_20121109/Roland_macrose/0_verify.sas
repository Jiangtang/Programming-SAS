/*<pre><b>
/ Program   : verify.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return the position of the first character
/             in a string that does not match any character in a reference
/             string.
/ SubMacros : none
/ Notes     : This is a substitute for the SI-supplied macro of the same name.
/             It works in the same way. This was written in case you want to
/             bypass the SI-supplied macros.
/ Usage     : %let pos=%verify(&text,%str( )); %*- first non-blank character -;
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ text              (pos) Text to verify
/ ref               (pos) String of reference characters
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/ rrb  04Nay11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: verify v1.0;

%macro verify(text,ref);
  %local pos errflag err;
  %let err=ERR%str(OR);
  %let errflag=0;
  %if not %length(&text) %then %do;
    %put &err: (verify) No text string supplied for verify to act on.;
    %let errflag=1;
  %end;
  %if not %length(&ref) %then %do;
    %put &err: (verify) No reference string supplied for verify to use.;
    %let errflag=1;
  %end;

  %if &errflag %then %goto exit;

  %do pos=1 %to %length(&text);
    %if NOT %index(&ref,%qsubstr(&text,&pos,1)) %then %goto gotit;
  %end;

  %gotit: 
  %if &pos GT %length(&text) %then 0;
  %else &pos;

  %goto skip;
  %exit: %put &err: (verify) Leaving macro due to problem(s) listed;
  %skip:
%mend verify;
