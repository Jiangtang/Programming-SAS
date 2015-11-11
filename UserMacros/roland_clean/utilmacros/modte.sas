/*<pre><b>
/ Program   : modte.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return the last modification datetime
/             stamp of a dataset.
/ SubMacros : %attrn
/ Notes     : This is a shell macro that calls %attrn
/ Usage     : %let modte=%modte(dsname);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset name
/ format            (pos) Format to use for output. This will default to nothing
/                   giving you the decimal fraction of the number of thousandths
/                   of a second since 01jan1960 but you can supply the usual
/                   formats if you like.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: modte v1.0;

%macro modte(ds,format);
  %local modte;
  %let modte=%attrn(&ds,modte);
  %if %length(&format) %then %do;
    %if %index(%upcase(&format),DATE) 
    and not %index(%upcase(&format),DATETIME) %then %do;
%sysfunc(putn(%sysfunc(datepart(&modte)),&format))
    %end;
    %else %do;
%sysfunc(putn(&modte,&format))
    %end;
  %end;
  %else %do;
&modte
  %end;
%mend modte;
