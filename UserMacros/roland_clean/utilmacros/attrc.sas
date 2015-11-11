/*<pre><b>
/ Program   : attrc.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ SubMacros : none
/ Purpose   : Function-style macro to return a character attribute of a dataset
/ Notes     : This is a low-level utility macro that other shell macros will
/             call. About all you would use this for is to get the dataset label
/             and the variables a dataset is sorted by.
/
/             This macro will only work correctly for datasets (i.e. not views)
/             and where there are no dataset modifiers.
/
/ Usage     : %let dslabel=%attrc(dsname,label);
/             %let sortseq=%attrc(dsname,sortedby);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                Dataset name (pos) (do not use views or dataset modifiers)
/ attrib            Attribute (pos)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  17Dec07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: attrc v1.0;

%macro attrc(ds,attrib);
  %local dsid rc err;
  %let err=ERR%str(OR);
  %let dsid=%sysfunc(open(&ds,is));
  %if &dsid EQ 0 %then %do;
    %put &err: (attrc) Dataset &ds not opened due to the following reason:;
    %put %sysfunc(sysmsg());
  %end;
  %else %do;
%sysfunc(attrc(&dsid,&attrib))
    %let rc=%sysfunc(close(&dsid));
  %end;
%mend attrc;
