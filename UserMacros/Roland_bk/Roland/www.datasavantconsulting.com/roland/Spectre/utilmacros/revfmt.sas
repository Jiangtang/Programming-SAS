/*<pre><b>
/ Program   : revfmt.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 14-Nov-2014
/ Purpose   : To take a list of formats and to create new formats that are the 
/             reverse of the original formats.
/ SubMacros : none
/ Notes     : You must ensure that whatever formats you are reversing can be
/             legitimately reversed with regard to the start value having a
/             one-to-one relationship with the label.
/
/             A prefix is added to the original format name when creating the
/             reverse format and an assumption is made that doing so will not
/             exceed the 32 character limit for a format name.
/
/             Both character and numeric formats will become character formats
/             when reversed. Therefore, when you use any of the created reversed
/             formats, you should start them all with a dollar sign.
/
/             Only set the "other" parameters if you are sure that none of the
/             original formats had "other" values assigned.
/
/             Options exist to uppercase the start value or label value. You
/             might use upcasestart=yes, for example, where you are trying to
/             map free case string decode values to their code values, in which
/             case you would apply the reversed format to the uppercased free
/             case string values such as newvar=put(upcase(oldvar),$_rvfmta.);
/
/ Usage     : %revfmt($fmta $fmtb);
/             %revfmt($fmta $fmtb,otherc=' ',upcasestart=yes);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ fmtlist           (pos) List of formats separated by spaces to reverse. 
/                   Character format names should start with a dollar sign.
/                   Format names should not use a period (see usage notes).
/ newpref=_RV       Characters to prefix the new format names with.
/ otherc            Optional mapping of "other" character values to a value.
/ othern            Optional mapping of "other" numeric values to a value.
/ upcasestart=no    By default, do not uppercase the start values in creating
/                   the new format (note that this is referring to the label of
/                   the original format that is now the start value of the new
/                   format).
/ upcaselabel=no    By default, do not uppercase the label values in creating
/                   the new format (note that this is referring to the start of
/                   the original format that is now the label value of the new
/                   format).
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  14Nov14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: revfmt v1.0;

%macro revfmt(fmtlist,
              newpref=_RV,
              otherc=,
              othern=,
              upcasestart=no,
              upcaselabel=no,
              debug=no);

  %local savopts;

  %if not %length(&debug) %then %let debug=no;
  %let debug=%upcase(%substr(&debug,1,1));

  %if &debug NE Y %then %do;
    %let savopts=%sysfunc(getoption(notes));
    options nonotes;
  %end;

  %if not %length(&newpref) %then %let newpref=_RV;

  %if not %length(&upcasestart) %then %let upcasestart=no;
  %let upcasestart=%upcase(%substr(&upcasestart,1,1));

  %if not %length(&upcaselabel) %then %let upcaselabel=no;
  %let upcaselabel=%upcase(%substr(&upcaselabel,1,1));



  proc format cntlout=_revfmt(keep=fmtname start label type hlo
                            rename=(start=label label=start));
    select &fmtlist;
  run;


  data _revfmt;
    length holdtype $ 1;
    set _revfmt;
    %if %length(&othern) or %length(&otherc) %then %do;
      by fmtname notsorted;
    %end;
    holdtype=type;
    type='C';
    fmtname="%sysfunc(dequote(&newpref))"||fmtname;
    %if &upcasestart EQ Y %then %do;
      start=upcase(start);
    %end;
    %if &upcaselabel EQ Y %then %do;
      label=upcase(label);
    %end;
    %if %length(&othern) or %length(&otherc) %then %do;
      output;
      if last.fmtname then do;
        start=' ';
        hlo="O";
        %if %length(&othern) %then %do;
          if holdtype="N" then label="%sysfunc(dequote(&othern))";
        %end;
        %if %length(&otherc) %then %do;
          if holdtype="C" then label="%sysfunc(dequote(&otherc))";
        %end;
        output;
      end;
    %end;
    DROP holdtype;
    LABEL start="Starting value for format"
          label="Format value label"
          ;
  run;


  proc format cntlin=_revfmt;
  run;


  %if &debug NE Y %then %do;
    proc datasets nolist;
      delete _revfmt;
    quit;
  %end;


  %if &debug NE Y %then %do;
    options &savopts;
  %end;

%mend revfmt;
