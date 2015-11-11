/*<pre><b>
/ Program      : combine.sas
/ Version      : 2.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 14-Jun-2013
/ Purpose      : To combine datasets based on merge variables
/ SubMacros    : %dropmodifmac %words
/ Notes        : Datasets to be merged should be separated by commas. Datasets
/                to be "set" together should be separated by spaces. You can
/                combine both setting and merging.
/
/                There is no limit to the number of input datasets but only one
/                value for the merge variables can be used so you have to make
/                sure that all the datasets you are merging can be correctly
/                merged using the specified merge variables. The input datasets
/                do not have to be in the correct sorted order for the merge as
/                sorting will be done automatically.
/
/                You would normally specify a KEEP list of variables. Make sure
/                the keep list includes the merge variables and also variables
/                used in a where clause if there is one. See usage notes. Note
/                that the use of %NRBQUOTE() is required for when a macro
/                parameter value contains commas as will be the case for merging
/                datasets using this macro.
/
/                !!! IMPORTANT !!! The first dataset specified is the driver
/                dataset used for an inner join in the sense that when merging
/                data then if it is not in that first dataset then observations
/                in other datasets will be dropped. If you are merging important
/                variables in with other data then this would normally be the
/                first dataset specified.
/
/                The output dataset is given the name "_combine" by default.
/                Other work datasets of the form "_comb1-_combn" are deleted.
/
/ Usage        : %let mrgvars=study ptno;
/                %let SrcData=
/                sasuser.test(keep=&mrgvars visit vara varc), 
/                sasuser.patd(keep=&mrgvars page scrndt trtstdt where=(page=1)),
/                sasuser.patd(keep=&mrgvars page brthdt where=(page=2)),
/                sasuser.vital(keep=&mrgvars visit bmi where=(visit=1));
/
/                %combine(SourceData=%nrbquote(&SrcData),MergeVars=&mrgvars);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ SourceData=       Source datasets separated by commas for merging or separated
/                   by spaces if just concatenating data (surround argument with
/                   %nrbquote() if there are commas present).
/ MergeVars=        List of Variables separated by spaces to use for merging the
/                   input datasets by.
/ dsout=_combine    Output dataset name (defaults to _combine)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  12Nov12         New (v1.0)
/ rrb  16Dec12         dsout= parameter added (v1.1)
/ rrb  14Jun13         Enhanced to allow mixed "setting" and merging (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: combine v2.0;

%macro combine(SourceData=,MergeVars=,dsout=_combine);
  %local i bit mergecode;
  %if not %length(&dsout) %then %let dsout=_combine;
  %if %length(%qscan(%nrbquote(&SourceData),2,%str(,))) %then %do;
    %let i=2;
    %let bit=%qscan(%nrbquote(&sourcedata),&i,%str(,));
    %do %while(%length(&bit));
      %if %words(%dropmodifmac(%superq(bit))) GT 1 %then %do;
        *- we have more than one dataset so set them together -;
        data _comb&i;
          set &bit;
        run;
        *- now sort the combined datasets -;
        proc sort data=_comb&i;
          by &mergevars;
        run;
      %end;
      %else %do;
        *- we have just one dataset so sort -;
        proc sort data=&bit out=_comb&i;
          by &mergevars;
        run;
      %end;
      %let mergecode=&mergecode _comb&i;
      %let i=%eval(&i+1);
      %let bit=%qscan(%nrbquote(&SourceData),&i,%str(,));
    %end;
    %let bit=%qscan(%nrbquote(&SourceData),1,%str(,));
    %if %words(%dropmodifmac(%superq(bit))) GT 1 %then %do;
      *- we have more than one DRIVER dataset so set them together -;
      data _comb1;
        set &bit;
      run;
      *- now sort the combined DRIVER datasets -;
      proc sort data=_comb1;
        by &mergevars;
      run;
    %end;
    %else %do;
      *- we have just one DRIVER dataset so sort -;
      proc sort data=&bit out=_comb1;
        by &mergevars;
      run;
    %end;
    %let mergecode=_comb1(in=_a) &mergecode;
    data &dsout;
      merge &mergecode;
      by &mergevars;
      if _a;
    run;
    proc datasets nolist;
      delete _comb1-_comb%eval(&i-1);
    quit;
  %end;
  %else %do;
    data &dsout;
      set &SourceData;
    run;
  %end;
%mend combine;
