/*<pre><b>
/ Program   : isodttm.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 14-Dec-2012
/ Purpose   : In-datastep function-style macro for generating a standard ISO
/             8601 datetime value from a numeric date and time value.
/ SubMacros : none but assumes %isoformats has been run
/ Notes     : This macro uses the two formats isodate. and isotime. created by
/             the %isoformats macro (which you should have already called).
/ Usage     : data test;
/               length dtc $ 20;
/               set test;
/               dtc=%isodttm(datevar,timevar);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ datevar           (pos) sas numeric date variable
/ timevar           (pos) sas numeric time variable
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  14Dec12         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: isodttm v1.0;

%macro isodttm(datevar,timevar);
put(&datevar,isodate.)||"T"||put(&timevar,isotime.)
%mend isodttm;
