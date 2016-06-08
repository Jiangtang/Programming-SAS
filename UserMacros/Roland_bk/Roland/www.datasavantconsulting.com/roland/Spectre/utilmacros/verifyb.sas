/*<pre><b>
/ Program   : verifyb.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return the position of the first character
/             in a string that does not match any character in a reference
/             string BUT STARTING FROM THE BACK.
/ SubMacros : none
/ Notes     : This is a "backwards" version of the familiar verify macro.
/ Usage     : %let pos=%verifyb(&text,%str( )); %*- last non-blank character -;
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ text              (pos) Text to verify
/ ref               (pos) String of reference characters
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

%put MACRO CALLED: verifyb v1.0;

%macro verifyb(text,ref);
  %local pos errflag err;
  %let err=ERR%str(OR);
  %let errflag=0;
  %if not %length(&text) %then %do;
    %put &err: (verifyb) No text string supplied for verifyb to act on.;
    %let errflag=1;
  %end;
  %if not %length(&ref) %then %do;
    %put &err: (verifyb) No reference string supplied for verifyb to use.;
    %let errflag=1;
  %end;

  %if &errflag %then %goto exit;

  %do pos=%length(&text) %to 1 %by -1;
    %if NOT %index(&ref,%qsubstr(&text,&pos,1)) %then %goto gotit;
  %end;

  %gotit:
&pos

  %goto skip;
  %exit: %put &err: (verifyb) Leaving macro due to problem(s) listed;
  %skip:
%mend verifyb;
