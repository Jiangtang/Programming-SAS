/*<pre><b>
/ Program   : scandlm.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 22-Mar-2013
/ Purpose   : Function-style macro to return a scan of a string with its
/             delimiter shown in front.
/ SubMacros : none
/ Notes     : none
/ Usage     : %put %scandlm(&str,2,*#);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) String
/ num               (pos) Position
/ dlm               (pos) Delimiters (not quoted)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  22Mar13         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: scandlm v1.0;

%macro scandlm(str,num,dlm);
  %local pos len;
  %let pos=0;
  %let len=0;
  %let bit=%qscan(%nrbquote(&str),&num,&dlm);
  %syscall scan(str,num,pos,len,dlm);
  %let pos=%eval(&pos-1);
  %if &pos GT 0 %then %qsubstr(%nrbquote(&str),&pos,1)%nrbquote(&bit);
  %else %nrbquote(&bit);
%mend scandlm;
