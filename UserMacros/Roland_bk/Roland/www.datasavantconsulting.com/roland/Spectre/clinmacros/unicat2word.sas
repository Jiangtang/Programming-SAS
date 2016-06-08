/*<pre><b>
/ Program      : unicat2word.sas
/ Version      : 1.1
/ Author       : Roland Rashleigh-Berry
/ Date         : 21-Apr-2013
/ Purpose      : Clinical reporting utility macro to produce a Word-style cell
/                table from the dataset output from the %unistats macro of
/                treatment-transposed categories counts and statistics.
/ SubMacros    : %varnum %words (assumed %popfmt and %unistats already run)
/ Notes        : You can call this macro directly from %unistats by setting the
/                wordtabdest= parameter.
/ Usage        : %unicat2word(dsin=_unitran,dest=print,dlim=';')
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              Input dataset
/ dest              Destination to place the table cells values such as log,
/                   print, fileref or filename.
/ dlim=';'          Delimiter character to use for cells (must be quoted)
/ total=yes         By default, print the total for all treatment groups if it
/                   exists in the input dataset.
/ pvalues=yes       By default, print the pvalues as a treatment column if it
/                   exists in the input dataset.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  12Oct08         _tempstr2 length increased to 256 for v1.1
/ rrb  08May11         Code tidy
/ rrb  21Apr13         Macro status changed to clinical reporting utility macro
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: unicat2word v1.1;

%macro unicat2word(dsin=_unitran,
                   dest=print,
                   dlim=';',
                pvalues=yes,
                  total=yes);

  %local i totvar pvalvar numvars allvars;

  %if not %length(&dsin) %then %let dsin=_unitran;
  %if not %length(&dest) %then %let dest=print;
  %if not %length(&dlim) %then %let dlim=';';
  %if not %length(&pvalues) %then %let pvalues=yes;
  %if not %length(&total) %then %let total=yes;

  %let total=%upcase(%substr(&total,1,1));
  %let pvalues=%upcase(%substr(&pvalues,1,1));

  %let totvar=;
  %if "&total" EQ "Y" %then %do;
    %if %varnum(&dsin,&_trttotvar_) %then %let totvar=&_trttotvar_;
  %end;

  %let pvalvar=;
  %if "&pvalues" EQ "Y" %then %do;
    %if %varnum(&dsin,&_trtpvalvar_) %then %let pvalvar=&_trtpvalvar_;
  %end;

  %let allvars=&_trtvarlist_ &totvar &pvalvar;
  %let numvars=%words(&allvars);

  data _null_;
    length _tempstr $ 30 _tempstr2 $ 256;
    file &dest notitles;
    set &dsin;
    by _page _varord;
    if first._page then do;
      if _page GT 1 then put / / ;
      _tempstr2=vlabel(_varlabel);
      if _tempstr2="_varlabel" then _tempstr2=" ";
      put _tempstr2 @;
      _tempstr2=vlabel(_statlabel);
      if _tempstr2="_statlabel" then _tempstr2=" ";
      put &dlim _tempstr2 @;
      %do i=1 %to &numvars;
        _tempstr2=vlabel(%scan(&allvars,&i,%str( )));
        put &dlim _tempstr2 @;
      %end;
      put;
    end;
    if first._varord then do;
      put " " &dlim " " @;
      %do i=1 %to &numvars;
        put &dlim " " @;
      %end;
      put;
      _tempstr2=translate(_varlabel,' ',"A0"x);
      put _tempstr2 @;
    end;
    else put " " @;
    put &dlim _statlabel @;
    %do i=1 %to &numvars;
      _tempstr=translate(%scan(&allvars,&i,%str( )),' ',"A0"x);
      put &dlim _tempstr @;
    %end;
    put;
  run;

%mend unicat2word;
