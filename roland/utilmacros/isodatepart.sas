/*<pre><b>
/ Program   : isodatepart.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 14-Dec-2012
/ Purpose   : In-datastep function-style macro for extracting the date part of a
/             standard ISO 8601 datetime text value.
/ SubMacros : none
/ Notes     : Text to the left of the "T" is assumed to be in yymmdd10. form but
/             if it is not in this valid form then a missing value results.
/ Usage     : data test;
/               set test;
/               date=%isodatepart(isodttmvar);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ isodttmvar        (pos) ISO 8601 text datetime variable           
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  14Dec12         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: isodatepart v1.0;

%macro isodatepart(isodttmvar);
input(scan(&isodttmvar,1,"T"),??yymmdd10.)
%mend isodatepart;
