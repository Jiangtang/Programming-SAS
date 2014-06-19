/*<pre><b>
/ Program   : crdte.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return the creation datetime stamp of a
/             dataset.
/ SubMacros : %attrn
/ Notes     : This is a shell macro that calls %attrn
/ Usage     : %let crdte=%crdte(dsname);
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

%put MACRO CALLED: crdte v1.0;

%macro crdte(ds,format);
  %local crdte;
  %let crdte=%attrn(&ds,crdte);
  %if %length(&format) %then %do;
    %if %index(%upcase(&format),DATE) 
    and not %index(%upcase(&format),DATETIME) %then %do;
%sysfunc(putn(%sysfunc(datepart(&crdte)),&format))
    %end;
    %else %do;
  %sysfunc(putn(&crdte,&format))
    %end;
  %end;
  %else %do;
&crdte
  %end;
%mend crdte;
