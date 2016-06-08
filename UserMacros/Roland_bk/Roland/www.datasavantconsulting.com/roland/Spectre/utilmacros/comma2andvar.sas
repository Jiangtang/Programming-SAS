/*<pre><b>
/ Program   : comma2andvar.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : In-datastep function-style macro to replace the last comma-space
/             in a string with " and ".
/ SubMacros : none
/ Notes     : none
/ Usage     : data test;
/               length str newstr $ 40;
/               str="aa, bb, cc";
/               newstr=%comma2andvar(str);
/               put newstr=;
/             run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) string with commas in to change
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  10Feb12         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: comma2andvar v1.0;

%macro comma2andvar(str);
prxchange('s/^(.*)(, )(.*$)/$1 and $3/',1,&str)
%mend comma2andvar;
