/*<pre><b>
/ Program   : eqsuff.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to suffix a list of words (usually variables)
/             with an equals sign.
/ SubMacros : %words %quotelst
/ Notes     : Use this when you want to "put" the values of a list of variables
/             out to the log.
/ Usage     : put %eqsuff(&varlist);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ list              (pos) List of items to end with an equals sign
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

%put MACRO CALLED: eqsuff v1.0;

%macro eqsuff(list);
  %if %words(&list) %then %quotelst(&list,quote=,delim=%str(= ))=;
%mend eqsuff;
