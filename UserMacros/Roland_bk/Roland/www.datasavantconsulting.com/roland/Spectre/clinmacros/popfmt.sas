/*<pre><b>
/ Program      : popfmt.sas
/ Version      : 4.9
/ Author       : Roland Rashleigh-Berry
/ Date         : 14-Sep-2014
/ Purpose      : Clinical reporting utility macro to create a treatment format
/                that is the same as an existing format but with the (N=xxx) at
/                the end.
/ SubMacros    : %varfmt %vartype
/ Notes        : This is a free utility macro that is placed in the clinical macro
/                library because it is the more appropriate place for it. You do
/                not need a licence to use this macro.
/
/                This macro is an important driving macro for the major reporting
/                macros %unicatrep and %npcttab and should be pre-called by any
/                reporting macro where the columns in the report are transposed
/                treatment arm values. You can use the global macro variables set
/                up in this macro to know in advance the number of treatment arm
/                columns and hence write flexible reporting macros where the number
/                of treatment columns are not fixed.
/
/                You must specify an input dataset with a treatment variable in 
/                it that has a format assigned to it. Also you need to specify
/                variable(s) that uniquely identifies a patient. Three formats are
/                created as described in _popfmt_, _poptfmt_ and _popnfmt_ below.
/
/                The dataset _popfmt is retained at macro end and has the treatment
/                variable plus the variable "total" sorted in treatment group order
/                and this can be used for calculating percentages in a later data
/                step.
/
/                global macro variables set
/                --------------------------
/                _popfmt_ gets assigned to the name of the format created by
/                         this macro with the drug name and (N=xxx) at the end.
/                         It will be $popfmt. or popfmt. depending
/                         on whether the treatment variable is character or
/                         numeric. Use this format to give you the treatment
/                         group but with the (N=xxx) at the end. Also use this
/                         format if you transpose the data to create a label for
/                         the variable and use "idlabel label" in your proc
/                         transpose so that your new variable will have the 
/                         correct label to display in your proc report.
/                _rawfmt_ gets assigned to the input format
/                _poptfmt_ gets assigned to a format that includes the "Total"
/                         treatment group. There is no (N=xxx) at the end.
/                         It will be $poptfmt. or popfmt.
/                _popnfmt_ gets assigned to the format that contains just the
/                         value of the population total. This will be the pure
/                         value of "N" as text. The format will be called 
/                         $popnfmt. or popnfmt. depending on whether the treatment
/                         variable is character or numeric.
/                _trtvar_ gets assigned to the treatment variable
/                _trtvarlist_ gets assigned to a list of variables starting with
/                         the string assigned to the prefix= parameter and ending
/                         with the value of the treatment variables. Assuming you
/                         will transpose your data using the same prefix, you can
/                         use this list in your proc report columns statement.
/                _trttotstr_ gets assigned to either what is defined to totalc=
/                         or totaln= depending on whether the treatment group
/                         variable is numeric or character. You can use this
/                         value in your code when you create a "total treatment
/                         group" and you want to assign it a value.
/             _uniqueid_  gets assigned to the variable(s) needed to uniquely
/                         define a subject.
/             _trttotvar_ gets assigned to whatever is assigned to the prefix=
/                         parameter followed by what is assigned to _trttotstr_
/                         and might be TRT99 or TRTY. You can use this in your
/                         proc report in the columns statement and the define
/                         statement.
/          _trttotcwidth_ gets set to the treatment total format column width
/                         statement.
/                _trtnum_ gets assigned to the number of unique treatment values
/                         found (not including that for the overall treatment
/                         value). You can use this in a macro loop to define
/                         your treatment values in proc report such as:
/                  %do i=1 %to &_trtnum_;
/                    define %scan(&_trtvarlist_,&i,%str( )) / display f=&_popfmt_;
/                  %end;
/               _trtpref_ gets assigned to whatever is assigned to prefix= and
/                         can be used as the prefix in a proc transpose. Then 
/                         your variables will match the list in _trtvarlist_.
/            _trtvartype_ Gets set to C or N (Character or Numeric) depending on
/                         the treatment variable type. You can use this to 
/                         complete a put statement like =put&_trtvartype_(etc...
/            _trtcwidths_ Gets set to the treatment column widths as given by the
/                         format &_popfmt_.
/            _trtfwidths_ Gets set to the treatment column widths as given by the
/                         format &_rawfmt_.
/          _trttotcwidth_ Gets set to the "Total" column width as given by the
/                         format &_popfmt_.
/          _trttotfwidth_ Gets set to the "Total" column width as given by the
/                         format &_poptfmt_.
/          _trtvallist_   A list of the values of the treatment arms separated
/                         by spaces (all values will be unquoted).
/          _trtinlist_    A list of the values of the treatment arms separated
/                         by spaces suitable for use in an IN() conditional
/                         (character values will be enclosed in quotes).
/          _trttotals_    Treatment population totals corresponding to each
/                         treatment value shown in _trtinlist_.
/
/ Usage        : %popfmt(stat.acct(where=(xxx=1 and &_pop_.cd=1)),trtgroup)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) Input dataset
/ msglevel=X        Message level to use inside this macro for notes and 
/                   information written to the log. By default, both Notes and
/                   Information are suppressed. Use msglevel=N or I for more
/                   information.
/ msgs=yes          By default, put out messages to the log saying what global
/                   macro variables have been set to what. Set this is no if you
/                   do not want see use or see these.
/ trtvar            (pos) Treatment arm variable which must be a coded numeric
/                   or short coded character variable (typically one or two
/                   bytes with no spaces)
/ dstrt             (pos) Input dataset containing complete set of trtvar values.
/                   If you are sure your input dataset contains all the trtvar
/                   values you need then you need not specify this. If you do
/                   specify this and there is no data in your input dataset
/                   corresponding to a treatment arm then this will have (N=0).
/ trtfmt            (Optional) treatment variable format. If omitted it uses
/                   the currently assigned format for the treatment variable.
/ uniqueid=patno    Variable(s) that uniquely identify a patient. If more
/                   than one variable then separate with spaces.
/ prefix=TRT        Prefix for a list of variables that will end in the unique
/                   values of the treatment variable that will get written to
/                   the global macro variable _trtlist_ . If you transpose your
/                   data with this prefix then the variable list can be used in
/                   your proc report.
/ totaln=99         Number value to represent "total" for all treatment arms.
/ totalc="Z"        Character value (in quotes) to represent "total" for all
/                   treatment arms.
/ pvaluen=9999      Number value to represent the pvalue treatment arm.
/ pvaluec="Z"       Character value to represent the pvalue treatment arm.
/ statvaluen=9998   Number value to represent the stat value treatment arm.
/ pvaluec="Y"       Character value to represent the stat value treatment arm.
/ pvallbl="p-value"   Label text for the pvalue treatment arm.
/ statvallbl="Value"  Label text for the stat value treatment arm.
/ totstr=Total      Text to represent the "total" for all treatments. If you
/                   set this to null then the format created will not contain
/                   an entry for the total treatment groups.
/ split=@           Split character to put before the (N=xxx) ending. If you
/                   want a space instead then set this to %str( ).
/ suffix            (in quotes) suffix to put after the (N=xxx) ending as part
/                   of the created format. Default is nothing.
/ brackets=yes      By default, show () brackets around the N=xxx label.
/ N=N               Allows you to change how "N" is displayed in (N=xxx) (no
/                   quotes - spaces allowed).
/ equals=%str(=)    Allows you to change the way the equals sign in (N=xxx) is
/                   displayed (for example set equals=%str(= ) to force a space
/                   after the equals sign).
/ freesuff          Free text suffix. The numeric value for N will be
/                   substituted where the "#" is and a "#" must only be used
/                   in one place in the string and for this purpose. Add your
/                   own split characters. This text must be UNQUOTED. It 
/                   overrides the suffix=, brackets= and N= parameters. 
/                   Use %str( ) to give you a leading space.
/ underscore=no     Whether you want a leading and trailing underscore for the
/                   output format for use in ascii reports. Note that if you set
/                   this to yes then the split character will be set to a space.
/ indent=0          Number of spaces to indent the format labels by
/ fmtname=popfmt    Output format name (used for main output format only)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  14Oct04         Changed to uniqueid=patno instead of patient
/ rrb  08Aug05         _trtvartype_ global macro variable added and _trtpref_
/                      is the preferred name for _tranpref_ although the old
/                      one is kept for compatibility.
/ rrb  17Jan06         Added column widths plus more explanation written to log
/ rrb  03Feb06         _trtvar_ and _uniqueid_ global macro variables added
/ rrb  04May06         _trttotals_ added
/ rrb  13Feb07         "macro called" message added
/ rrb  20Mar07         All _nX_ variable creation dropped (v2.0)
/ rrb  21Mar07         Header tidy
/ rrb  02May07         Brackets=yes parameter added so that brackets around 
/                      (N=xxx) can be suppressed if required.
/ rrb  30Jul07         Header tidy
/ rrb  22Apr08         N=N parameter added 
/ rrb  23Apr08         Freesuff= parameter added
/ rrb  30Apr08         "total" changed to "_total" for output dataset
/ rrb  01Nov10         statvaluen=, statvaluec= and statvallbl= parameters
/                      added for the statistics value corresponding to the
/                      p-value. This statistics value is a regulatory
/                      requirement for China's SFDA (v3.1)
/ rrb  21Nov10         Statistics value and p-value processing removed (v4.0)
/ rrb  08May11         Code tidy
/ rrb  16May11         Avoid numeric-to-character conversion message (v4.1)
/ rrb  26May11         Check for missing treatment variable format (v4.2)
/ rrb  01Dec11         underscore= processing added (v4.3)
/ rrb  12Dec11         indent= processing added (v4.4)
/ rrb  30Dec11         _trtvallist_ added which is a list of treatment arm
/                      values unquoted (v4.5)
/ rrb  04Jan12         msgs= processing added (v4.6)
/ rrb  15Mar13         Header update to make it clear that this is a free macro
/ rrb  22Mar13         fmtname= parameter added (v4.7)
/ rrb  17Jul13         equals= parameter added (v4.8)
/ rrb  14Sep14         Use of "keyword" dropped for boolean options (v4.9)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: popfmt v4.9;

%macro popfmt(dsin,
            trtvar,
             dstrt,
          msglevel=X,
              msgs=yes,
            trtfmt=,
          uniqueid=patno,
            prefix=TRT,
            totaln=99,
            totalc="Y",
            totstr=Total,
             split=@,
            suffix=,
          brackets=yes,
                 N=N,
            equals=%str(=),
          freesuff=,
        underscore=no,
            indent=0,
            fmtname=popfmt
              );

  %local i varfmt gvar errflag err savopts;
  %global _popfmt_  _poptfmt_ _popnfmt_ _trtvarlist_  _trttotstr_  _trttotvar_  
          _trtnum_  _trtpref_ _tranpref_ _trtvallist_ _trtinlist_ 
          _trtvartype_ _trtcwidths_ _trttotcwidth_ _trtfwidths_ _trttotfwidth_
          _rawfmt_ _uniqueid_ _trtvar_ _trttotals_;
        
  %let errflag=0;
  %let err=ERR%str(OR);

  %if not %length(&fmtname) %then %let fmtname=popfmt;

  %if not %length(&msglevel) %then %let msglevel=X;
  %let msglevel=%upcase(%substr(&msglevel,1,1));
  %if "&msglevel" NE "N" and "&msglevel" NE "I" %then %let msglevel=X;

  %let savopts=%sysfunc(getoption(msglevel,keyword)) %sysfunc(getoption(notes));
  %if "&msglevel" EQ "N" or "&msglevel" EQ "I" %then %do;
    options msglevel=&msglevel;
  %end;
  %else %do;
    options nonotes;
  %end;

  %if not %length(&msgs) %then %let msgs=yes;
  %let msgs=%upcase(%substr(&msgs,1,1));

  %if not %length(&brackets) %then %let brackets=yes;
  %let brackets=%upcase(%substr(&brackets,1,1));

  %let _trttotals_=;
  %let _trtpref_=&prefix;
  %let _tranpref_=&prefix;    %*- old named version kept for compatibility -;

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (popfmt) No input dataset specified to first positional parameter;
  %end;

  %if not %length(&trtvar) %then %do;
    %let errflag=1;
    %put &err: (popfmt) No treatment variable specified to second positional parameter;
  %end;

  %if &errflag %then %goto exit;

  %if not %length(&indent) %then %let indent=0;

  %if not %length(&underscore) %then %let underscore=no;
  %let underscore=%upcase(%substr(&underscore,1,1));
  %if &underscore EQ Y %then %let split=%str( );

  %let _trtvar_=&trtvar;
  %let _uniqueid_=&uniqueid;


  %*- If treatment arm dataset specified -;
  %if %length(&dstrt) %then %do;
    data _poptrt(keep=&trtvar);
      set &dstrt;
    run;
    proc sort nodupkey data=_poptrt;
      by &trtvar;
    run;
    data _poptrt;
      retain _total 0;
      set _poptrt;
    run;
  %end;


  *- get rid of duplicates from input dataset -;
  proc sort nodupkey data=&dsin
                      out=_popfmt(keep=&uniqueid &trtvar);
    by &uniqueid &trtvar;
  run;


  %*- identify treatment variable format -;
  %if %length(&trtfmt) %then %let varfmt=&trtfmt;
  %else %let varfmt=%varfmt(_popfmt,&trtvar);
  %if NOT %length(&varfmt) %then %do;
    %put &err: (popfmt) No format associated with treatment arm variable &trtvar;
    %goto exit;
  %end;

  %let _rawfmt_=&varfmt;

  %let _trtvartype_=%vartype(_popfmt,&trtvar);

  %if "&_trtvartype_" EQ "C" %then %do;
    %let _popfmt_=$&fmtname;
    %let _popnfmt_=$popnfmt;
    %let _poptfmt_=$poptfmt;
    %let _trttotstr_=&totalc;
    %let _trttotvar_=&prefix.%sysfunc(compress(&totalc,%str(%`%")));
  %end;
  %else %do;
    %let _popfmt_=&fmtname;
    %let _popnfmt_=popnfmt;
    %let _poptfmt_=poptfmt;
    %let _trttotstr_=&totaln;
    %let _trttotvar_=&prefix.&totaln;
  %end;


  *- add observations for the "totals" category -;
  data _popfmt;
    set _popfmt;
    output;
    &trtvar=&_trttotstr_;
    output;
    format &trtvar;
  run;


  *- make sure we have no duplicates in the "totals" category -;
  proc sort nodupkey data=_popfmt;
    by &trtvar &uniqueid;
  run;


  *- get counts by treatment group -;
  proc summary nway data=_popfmt;
    class &trtvar;
    output out=_popfmt(drop=_type_ rename=(_freq_=_total));
  run;


  %*- If treatment dataset specified then do a merge -;
  %if %length(&dstrt) %then %do;
    data _popfmt;
      merge _poptrt _popfmt;
      by &trtvar;
    run;
    proc datasets nolist;
      delete _poptrt;
    run;
    quit;
  %end;


  *- set up labels for main format -;
  data _popfmt;
    length label tlabel varlist inlist cwidths fwidths trttotals $ 200
           totalstr $ 6;
    retain fmtname "&_popfmt_"  varlist inlist cwidths fwidths trttotals " ";
    set _popfmt end=last;
    start=&trtvar;
    totalstr=left(put(_total,6.));
    if trttotals=" " then trttotals=totalstr;
    else trttotals=trim(trttotals)||" "||totalstr;
    if &trtvar eq &_trttotstr_ then do;
      %if %length(&totstr) %then %do;
        tlabel="&totstr";
        %if %length(&freesuff) %then %do;
          label=trim(put(&trtvar,&varfmt))||"%qscan(&freesuff,1,#)"||trim(totalstr)||"%qscan(&freesuff,2,#)";
        %end;
        %else %do;
          %if "&brackets" EQ "N" %then %do;
            %if &underscore NE Y %then %do;
              label="&totstr"||"&split"||"&N.&equals"||trim(totalstr);
            %end;
            %else %do;
              label="_&totstr"||"&split"||"&N.&equals"||trim(totalstr)||"_";
            %end;
          %end;
          %else %do;
            %if &underscore NE Y %then %do;
              label="&totstr"||"&split"||"(&N.&equals"||trim(totalstr)||")";
            %end;
            %else %do;
              label="_&totstr"||"&split"||"(&N.&equals"||trim(totalstr)||")_";
            %end;
          %end;
          %if %length(&suffix) %then %do;
            label=trim(label)||&suffix;
          %end;
        %end;
        %if &indent GT 0 %then %do;
          label=repeat(" ",%eval(&indent-1))||label;
        %end;

        *- get column width from label -;
        cwidth=0;
        *- Do not use scan to test for a space as this -;
        *- might be a deliberate part of the label. -;
        do i=1 to 20;
          len=length(scan(label,i,"&split"));
          if len>cwidth then cwidth=len;
        end;
        call symput('_trttotcwidth_',compress(put(cwidth,2.)));

        *- get original width from tlabel -;
        fwidth=0;
        *- Do not use scan to test for a space as this -;
        *- might be a deliberate part of the label. -;
        do i=1 to 20;
          len=length(scan(tlabel,i,"&split"));
          if len>fwidth then fwidth=len;
        end;
        call symput('_trttotfwidth_',compress(put(fwidth,2.)));

      %end;
      %else %do;
        delete;
      %end;
    end;

    else do;
      tlabel=put(&trtvar,&varfmt);

      %if %length(&freesuff) %then %do;
          label=trim(put(&trtvar,&varfmt))||"%qscan(&freesuff,1,#)"||trim(totalstr)||"%qscan(&freesuff,2,#)";
      %end;
      %else %do;
        %if "&brackets" EQ "N" %then %do;
          %if &underscore NE Y %then %do;
            label=trim(put(&trtvar,&varfmt))||"&split"||"&N.&equals"||trim(totalstr);
          %end;
          %else %do;
            label="_"||trim(put(&trtvar,&varfmt))||"&split"||"&N.&equals"||trim(totalstr)||"_";
          %end;
        %end;
        %else %do;
          %if &underscore NE Y %then %do;
            label=trim(put(&trtvar,&varfmt))||"&split"||"(&N.&equals"||trim(totalstr)||")";
          %end;
          %else %do;
            label="_"||trim(put(&trtvar,&varfmt))||"&split"||"(&N.&equals"||trim(totalstr)||")_";
          %end;
        %end;
        %if %length(&suffix) %then %do;
          label=trim(label)||&suffix;
        %end;
      %end;
      %if &indent GT 0 %then %do;
        label=repeat(" ",%eval(&indent-1))||label;
      %end;

      *- get column width from label -;
      cwidth=0;
      *- Do not use scan to test for a space as this -;
      *- might be a deliberate part of the label. -;
      do i=1 to 20;
        len=length(scan(label,i,"&split"));
        if len>cwidth then cwidth=len;
      end;

      if cwidths=" " then cwidths=compress(put(cwidth,2.));
      else cwidths=trim(cwidths)||' '||compress(put(cwidth,2.));

      *- get original width from tlabel -;
      fwidth=0;
      *- Do not use scan to test for a space as this -;
      *- might be a deliberate part of the label. -;
      do i=1 to 20;
        len=length(scan(tlabel,i,"&split"));
        if len>fwidth then fwidth=len;
      end;   
      if fwidths=" " then fwidths=compress(put(fwidth,2.));
      else fwidths=trim(fwidths)||' '||compress(put(fwidth,2.));

      %if "%vartype(_popfmt,&trtvar)" EQ "C" %then %do;
        %PUT NOTE: trtvar=&trtvar is a character variable;
        if inlist=' ' then inlist='"'||trim(left(&trtvar))||'"';
        else inlist=trim(inlist)||' "'||trim(left(&trtvar))||'"';
        if varlist=' ' then varlist="&prefix"||left(&trtvar);
        else varlist=trim(varlist)||" &prefix"||left(&trtvar);
      %end;
      %else %do;
        %PUT NOTE: trtvar=&trtvar is a numeric variable;
        if inlist=' ' then inlist=put(&trtvar,best.-L);
        else inlist=trim(inlist)||" "||put(&trtvar,best.-L);
        if varlist=' ' then varlist="&prefix"||put(&trtvar,best.-L);
        else varlist=trim(varlist)||" &prefix"||put(&trtvar,best.-L);
      %end;
 
    end;

    output;
    if last then do;
      call symput('_trtvarlist_',trim(varlist));
      call symput('_trtvallist_',trim(compress(inlist,'"')));
      call symput('_trtinlist_',trim(inlist));
      call symput('_trtcwidths_',trim(cwidths));
      call symput('_trtfwidths_',trim(fwidths));
      call symput('_trttotals_',trim(trttotals));
    end;
    drop inlist varlist i cwidth len;
  run;


  *- create the main format with (N=xxx) at the end -;
  proc format cntlin=_popfmt;
  run;


  *- set of labels for the original format with "Total" trt group added -;
  data _popfmt;
    retain fmtname "&_poptfmt_";
    set _popfmt(keep=&trtvar start tlabel _total totalstr
              rename=(tlabel=label));
  run;


  *- create the format for the original format with "Total" trt group added -;
  proc format cntlin=_popfmt;
  run;


  *- set of labels for the pure N format -;
  data _popfmt;
    retain fmtname "&_popnfmt_";
    set _popfmt(keep=&trtvar start _total totalstr
              rename=(totalstr=label));
  run;  


  *- create the "N" format -;
  proc format cntlin=_popfmt;
  run;


  *- leave only two variables in for percentage calculations -;
  data _popfmt;
    set _popfmt(keep=&trtvar _total where=(_total ne .));
  run;
  

  %*- Number of treatment values (not including the "totals" category) -;
  data _null_;
    set _popfmt end=_last;
    if _last then call symput('_trtnum_',compress(put(_n_-1,6.)));
  run;



  %*- put the dot at the end of the format names -;
  %let _popfmt_=&_popfmt_..;
  %let _popnfmt_=&_popnfmt_..;
  %let _poptfmt_=&_poptfmt_..;

  %if "&msgs" NE "N" %then %do;
    %put;
    %put MSG: (popfmt) The following global macro variables have been set up;
    %put MSG: (popfmt) and can be resolved in your code.;
    %put _popfmt_=&_popfmt_   (output format with (N=xxx) population totals added);
    %put _rawfmt_=&_rawfmt_   (input format);
    %put _popnfmt_=&_popnfmt_  (format for giving pure population totals);
    %put _poptfmt_=&_poptfmt_  (copy of input format but containing total treatment arm);
    %put _trtvar_=&_trtvar_    (name of treatment variable);
    %put _trtvartype_=&_trtvartype_  (treatment variable type N/C);
    %put _trttotstr_=&_trttotstr_ (treatment total string identifier);
    %put _uniqueid_=&_uniqueid_   (variable(s) used to uniquely identify subjects);
    %put _trttotvar_=&_trttotvar_  (transposed treatment total variable);
    %put _trtpref_=&_trtpref_  (treatment variable prefix used in transpose);
    %put _trtvarlist_=&_trtvarlist_ (transposed treatment variables);
    %put _trtvallist_=&_trtvallist_  (treatment arm values unquoted);
    %put _trtinlist_=&_trtinlist_  (treatment arm values suitable for an IN() conditional);
    %put _trtnum_=&_trtnum_  (number of treatment arms);
    %put _trtcwidths_=&_trtcwidths_    (column widths according to format &_popfmt_);
    %put _trtfwidths_=&_trtfwidths_    (column widths according to format &_poptfmt_);
    %put _trttotcwidth_=&_trttotcwidth_   ("Total" column width according to format &_popfmt_);
    %put _trttotfwidth_=&_trttotfwidth_   ("Total" column width according to format &_poptfmt_);
    %put _trttotals_=&_trttotals_;

    %put;
    %put MSG: (popfmt) Dataset "_popfmt" has been created containing population totals;
    %put MSG: (popfmt) with one observation per treatment group and one observation for;
    %put MSG: (popfmt) the total of all treatment groups. Use this to merge with and;
    %put MSG: (popfmt) calculate percentages. Variables are as follows:;
    %put &trtvar: Treatment group (dataset is sorted in this order);
    %put _total: Total population for the treatment group;
    %put;
  %end;

  %goto skip;
  %exit: %put &err: (popfmt) Leaving macro due to problem(s) listed;
  %skip:

  options &savopts;

%mend popfmt;
