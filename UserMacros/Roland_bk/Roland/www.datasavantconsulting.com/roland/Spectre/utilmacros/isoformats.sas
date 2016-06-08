/*<pre><b>
/ Program   : isoformats.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 14-Dec-2012
/ Purpose   : Macro to define the ISO 8601 formats used by the %isodttm macro
/             for generating an ISO 8601 datetime string.
/ SubMacros : none
/ Notes     : This macro creates the two formats isodate. and isotime. used in
/             creating a text ISO 8601 datetime string. The main purpose is to
/             represent a missing date as xxxx-xx-xx and a missing time as
/             xx:xx:xx in the ISO 8601 text.
/ Usage     : %isoformats;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ N/A
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  14Dec12         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: isoformats v1.0;

%macro isoformats;

  proc format;
    value isodate
    .="xxxx-xx-xx"
    OTHER=[yymmdd10.]
    ;
    value isotime
    .="xx:xx:xx"
    OTHER=[time8.]
    ;
  run;

%mend isoformats;
