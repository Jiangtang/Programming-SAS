/*<pre><b>
/ Program      : xytitles.sas
/ Version      : 1.2
/ Author       : Roland Rashleigh-Berry
/ Date         : 30-Jul-2007
/ Purpose      : Spectre (Clinical) macro to finish creating the header lines
/                for the imaginary XenuYama pharmaceutical company style.
/ SubMacros    : %casestrmac %lowcase %maxtitle %titlegen %attrn
/ Notes        : This is one of the titles style macros called from %titles. It
/                finishes what %titles started according to the "xy" style. 
/ Usage        : Must be called from within the %titles macro and must not be
/                used standalone.
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ program=          Program name 
/ label=            Label (max two characters lower case) to identify the set of
/                   titles when there is multiple sets of titles per program.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  19Mar06          _tline2_ _tline3_ _tline4_ _figbkmark_ added for figures
/ rrb  13Feb07         "macro called" message added
/ rrb  02Mar07         Use "&_ptlibref_.." instead of "der."
/ rrb  07Mar07         _popdone_ global macro variable used to indicate whether
/                      the population label has been set up in the titles and
/                      use of _pagescript_ global macro variable dropped.
/ rrb  30Jul07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: xytitles v1.2;

%macro xytitles(program=,label=);

  %*- set up global macro variables -;
  %global _tline2_ _tline3_ _tline4_ _figbkmark_ _popdone_;
  %if not %length(&_popdone_) %then %let _popdone_=0;
  %let _tline2_=;
  %let _tline3_=;
  %let _tline4_=;
  %let _figbkmark_=;


  %*- set up needed local variables -;
  %local popalert tcount;


  %*- Alert flag for when the population in the form &_poplabel_ has -;
  %*- been detected in one of the titles. If that is the case then for -;
  %*- a table, do not put out a following population title. -;
  %let popalert=0;


  %*- For tables, make sure the word "TABLE" is in upper case in first title -;
  %*- and that the population label is also in upper case. -;
  %if "&_reptype_" EQ "TABLE" %then %do;
    %let _repid_=%casestrmac(&_repid_,TABLE);
    %let _poplabel_=%upcase(&_poplabel_);
  %end;
  %else %if "&_reptype_" EQ "ATTACHMENT" %then %do;
    %let _repid_=%casestrmac(&_repid_,ATTACHMENT);
    %let _poplabel_=%upcase(&_poplabel_);
  %end;
  %*- For non-tables, make sure the first letter is upper case and the rest lower case -;
  %else %do;
    %let _repid_=%casestrmac(&_repid_,
      %substr(&_reptype_,1,1)%lowcase(%substr(&_reptype_,2)));
  %end;



  *- set up and create the top three header lines of a standard report -;
  data _null_;
    length text $ &_ls_ datestr $ 32;
    *- date string for draft report to add to the title -;
    datestr=put(date(),weekdate32.);
    datestr=substr(datestr,index(datestr,",")+2);
    text="&_drugname_";
    substr(text,&_ls_,1)='FF'x;
    call execute("title1"||' "'||text||'";');
    text="&_protocol_";
    %if "&_reptype_" NE "TABLE" and "&_reptype_" NE "ATTACHMENT" %then %do;
      substr(text,%eval(&_ls_-%length(&_repid_)+1))="&_repid_";
    %end;
    call execute("title2"||' "'||text||'";');
    text="&_report_";
    if index(upcase(text),'DRAFT') then text=trim(text)||" "||datestr;
    %if %length(&_poplabel_) %then %do;
      %if "&_reptype_" NE "TABLE" and "&_reptype_" NE "ATTACHMENT" %then %do;
        substr(text,%eval(&_ls_-%length(&_poplabel_)+1))="&_poplabel_";
        %let _popdone_=1;
      %end;
    %end;
    call execute("title3"||' "'||text||'";');
  run;


  %*- For tables, throw a blank title line, put table title on -;
  %*- following line and then throw another blank title line. -;
  %*- For others, just throw a blank title line to leave a gap. -;
  %if "&_reptype_" EQ "TABLE" or "&_reptype_" EQ "ATTACHMENT" %then %do;
    title4 "   ";
    title5 "&_repid_";
    title6 "   ";
  %end;
  %else %do;
    title4 "  ";
  %end;


  %*- do a quiet count of titles (i.e. do not display maximum values yet) -;
  %maxtitle(quiet)
  %let tcount=&_maxtitle_;


  *- extract titles -;
  data _titles;
    set &_ptlibref_..titles(where=(program="&program" and label="&label"));
  run;


  %*- Only process the titles if there is more than one -;
  %*- since the first title has already been dealt with. -;
  %if %attrn(_titles,nobs) GT 1 %then %do;

    *- process the titles -;
    data _titles(keep=type number text);
      set _titles;
      *- drop this as we have already set up the first title -;
      if type="T" and number=1 then delete;
      if type="T" and number=2 then call symput('_tline2_',trim(text));
      if type="T" and number=3 then call symput('_tline3_',trim(text));
      if type="T" and number=4 then call symput('_tline4_',trim(text));
      *- increment the title number depending on how many titles already put out -;
      if type='T' then number=number-1+&_maxtitle_;
      *- Replace "&" character in titles and footnotes with a special character -;
      *- if not followed by an underscore so we do not get warning messages -;
      *- about unresolved macro variables. -;
      do while (index(text,'&') and (index(text,'&') NE index(text,'&_')));
        substr(text,index(text,'&'),1)='FD'x;
      end;
      *- Replace "%" character in titles and footnotes with a special character -;
      *- if not followed by a space so we do not get warning messages about -;
      *- macros not resolved. -;
      do while (index(text,'%') and (index(text,'%') NE index(text,'% ')));
        substr(text,index(text,'%'),1)='F8'x;
      end;
      *- Replace double quote character with a special character -;
      text=translate(text,'F0'x,'"');
      *- Set a flag to tell this macro not to add an extra titles population -;
      *- line if it detects a call to _poplabel_ in one of the titles. -;
      if type='T' and index(upcase(text),'&_POPLABEL_') then do;
        call symput('popalert',"1");
        call symput('_popdone_',"1");
      end;
    run;


    *- generate the extra titles from the extracted titles -;
    %titlegen(_titles)

  %end;


  %*- For a table, put the population title as last title unless it is -;
  %*- blank or it has been detected in the title lines (i.e. &popalert=1) -;
  %if "&_reptype_" EQ "TABLE" and %length(&_poplabel_) and (&popalert EQ 0) %then %do;
    %maxtitle(quiet)
    %*- Only add this population title if some extra -;
    %*- titles were generated in the previous step. -;
    %if &_maxtitle_ GT &tcount %then %do;
      title%eval(&_maxtitle_+1) "&_poplabel_";
      %let _popdone_=1;
    %end;
  %end;

  %let _figbkmark_=&_repid_;
  %if %length(&_tline2_) %then %do;
    %let _figbkmark_=%superq(_figbkmark_) %superq(_tline2_);
    %if %length(&_tline3_) %then %do;
      %let _figbkmark_=%superq(_figbkmark_) %superq(_tline3_);
      %if %length(&_tline4_) %then %do;
        %let _figbkmark_=%superq(_figbkmark_) %superq(_tline4_);
      %end;
    %end;
  %end;
  %let _figbkmark_=%superq(_figbkmark_) &_poplabel_;


  %put;
  %put MSG: (xytitles) The following global macro variables have been set;
  %put MSG: (xytitles) and can be used in your code. ;
  %put _repid_=&_repid_;
  %put _poplabel_=&_poplabel_;
  %put _popdone_=&_popdone_;
  %put _tline2_=%superq(_tline2_);
  %put _tline3_=%superq(_tline3_);
  %put _tline4_=%superq(_tline4_);
  %put _figbkmark_=%superq(_figbkmark_);
  %put;


  *- tidy up -;
  proc datasets nolist;
    delete _titles;
    run;
  quit;

%mend xytitles;
