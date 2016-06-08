/*<pre><b>
/ Program    : proginfo.sas
/ Version    : 1.3
/ Author     : Roland Rashleigh-Berry
/ Date       : 12-Oct-2009
/ Purpose    : Spectre (Clinical) macro to store important program information
/              in global macro variables.
/ SubMacros  : (relies on %protinfo and %jobinfo already run)
/              %lowcase %attrn %qreadpipe %layout2lsps
/ Notes      : This reads the "titles" dataset in the "der" library and writes
/              program-specific information to global macro variables.
/ Usage      : %proginfo
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ program=          (optional) Program name override
/ label=            (optional) Label (max two characters lower case) to identify
/                   the set of titles when there is multiple output per program.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  19Mar06         Global macro variables _rotate_ _vsize_ _hsize_ _vorigin_
/                      _horigin_ _device_ added for figures.
/ rrb  13Feb07         "macro called" message added
/ rrb  21Feb07         Made Windows compliant
/ rrb  02Mar07         Use "&_ptlibref_.." instead of "der."
/ rrb  19Jul07         Added _lisfile_ global macro variable
/ rrb  30Jul07         Header tidy
/ rrb  12Oct09         Call to %readpipe changed to call to %qreadpipe due to
/                      macro renaming (v1.3)
/===============================================================================
/ No guarantee as to the suitability or accuracy of this code is given or
/ implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: proginfo v1.3;

%macro proginfo(program=,label=);

  %local i holdlayout lsps err;
  %let err=ERR%str(OR);
  %global _layout_ _pop_ _poplabel_ _reptype_ _repid_ _repsort_ _replabel_ 
          _lisfile_ _ls_ _ps_ _longline_ _abort_
          _rotate_ _vsize_ _hsize_ _vorigin_ _horigin_ _device_
          ;


  %*- abort check -;
  %global _abort_;
  %if %length(&_abort_) %then %do;
    %put &err: (proginfo) There has been a problem in a previous macro so this macro will now exit;
    %goto exit;
  %end;


  %*- set linesize and pagesize to impossible values -;
  %let _ls_=0;
  %let _ps_=0;


  %*- program name defaults to that set up in _prog_ -;
  %if not %length(&program) %then %let program=&_prog_;


  %*- label should be lower case if supplied -;
  %if %length(&label) %then %let label=%lowcase(&label);


  %*- check the dataset we need is there -;
  %if not %sysfunc(exist(&_ptlibref_..titles)) %then %do;
    %put &err: (proginfo) Titles information dataset "&_ptlibref_..titles" not found;
    %let _abort_=1;
    %goto exit;
  %end;


  *- extract data for this program -;
  data _titles;
    set &_ptlibref_..titles(where=(program="&program" and label="&label"));
  run;


  %*- make sure we found something for this program and if not abort -;
  %if not %attrn(_titles,nobs) %then %do;
    %let _abort_=1;
    %put &err: (proginfo) No titles information found for program=&program label=&label;
    %goto exit;
  %end;
  

  *- write the values to global macro variables -;
  data _null_;
    length repsort repstr $ 23 lisfile $ 38;
    set _titles;
    if type='T' and number=1 then do;
      call symput('_replabel_',trim(label));
      if lisfile=" " then lisfile=trim(program)||".lis"||left(label);
      call symput('_lisfile_',trim(lisfile));
      call symput('_layout_',trim(layout));
      call symput('_pop_',trim(population));
      call symput('_reptype_',upcase(scan(text,1," ")));
      call symput('_repid_',trim(text));
      if lisfile=" " then lisfile=trim(program)||".lis"||left(label);
      repstr=scan(text,2," ");
      repsort='000-000-000-000-000-000';
      do i=1 to 6;
        bit=upcase(scan(repstr,i,"."));
        len=length(bit);
        if bit ne " " then substr(repsort,(i-1)*4+(4-len),len)=bit;
      end;
      call symput('_repsort_',repsort);
    end;
  run;


  %*- set up the population label using those defined for the protocol -;
  %if %length(&_pop_) %then %do;
    %do i=1 %to 9;
      %if "&_pop_" EQ "&&_pop&i._" %then %do;
        %let _poplabel_=&&_poplabel&i._;
        %let i=9;
      %end;
    %end;
    %if not %length(&_poplabel_) %then %do;
      %put &err: (proginfo) Population abbreviation "&_pop_" not mapped to a label;
      %let _abort_=1;
      %goto exit;
    %end; 
  %end;


  %*- complete the layout if this is partial e.g. lc -;
  %let holdlayout=&_layout_;
  %if not %length(&_layout_) %then %let _layout_=&_dflayout_;
  %else %if %length(&_layout_) EQ %length(%sysfunc(compress(&_layout_,0123456789))) %then %do;
    %if "&_layout_" NE "L" and "&_layout_" NE "P"
    and "&_layout_" NE "LT" and "&_layout_" NE "PT" %then %do;
      %put &err: (proginfo) Layout &holdlayout not recognised;
      %let _abort_=1;
      %goto exit;
    %end;
    %else %let _layout_=&&_df&_layout_.layout_;
  %end;
  %if not %length(&_layout_) %then %do;
    %put &err: (proginfo) Layout &holdlayout not mapped to one with a font size;
    %let _abort_=1;
    %goto exit;
  %end;


  %if "%substr(&_layout_,1,1)" EQ "L" %then %let _rotate_=landscape;
  %else %let _rotate_=portrait;


  %if "&_paper_" EQ "A4" %then %do;
    %let _device_=PS300A4;
    %if "&_rotate_" EQ "landscape" %then %do;
      %let _horigin_=&_bmargin_.in;
      %let _vorigin_=&_rmargin_.in;
      %let _hsize_=%sysevalf(11.7-&_tmargin_-&_bmargin_)in;
      %let _vsize_=%sysevalf(8.27-&_lmargin_-&_rmargin_)in;
    %end;
    %else %do;
      %let _horigin_=&_lmargin_.in;
      %let _vorigin_=&_bmargin_.in;
      %let _hsize_=%sysevalf(8.27-&_lmargin_-&_rmargin_)in;
      %let _vsize_=%sysevalf(11.7-&_tmargin_-&_bmargin_)in;
    %end;
  %end;
  %else %do;
    %let _device_=PS300;
    %if "&_rotate_" EQ "landscape" %then %do;
      %let _horigin_=&_bmargin_.in;
      %let _vorigin_=&_rmargin_.in;
      %let _hsize_=%sysevalf(11.0-&_tmargin_-&_bmargin_)in;
      %let _vsize_=%sysevalf(8.5-&_lmargin_-&_rmargin_)in;
    %end;
    %else %do;
      %let _horigin_=&_lmargin_.in;
      %let _vorigin_=&_bmargin_.in;
      %let _hsize_=%sysevalf(8.5-&_lmargin_-&_rmargin_)in;
      %let _vsize_=%sysevalf(11.0-&_tmargin_-&_bmargin_)in;
    %end;
  %end;

  %if "&sysscp" EQ "WIN" %then %do;
    %*- Calculate the line size and page size using the "layout2lsps" macro -;
    %*- and write the results to the global macro variables _ls_ and _ps_ . -;
    %layout2lsps(lmargin=&_lmargin_,rmargin=&_rmargin_,tmargin=&_tmargin_,
                 bmargin=&_bmargin_,paper=&_paper_,layout=&_layout_);
    run;

    %if "&_ls_" EQ "ERROR" %then %do;
      %put &err: (proginfo) Layout &_layout_ not recognised by the "layout2lsps" macro;
      %let _abort_=1;
      %goto exit;
    %end;  

  %end;
  %else %do;
    %*- calculate the line size and page size using the "layout2lsps" script -;
    %let lsps=%qreadpipe(layout2lsps -l &_lmargin_ -r &_rmargin_ -t &_tmargin_ -b &_bmargin_ -p &_paper_ -f &_layout_);


    %*- check that the layout was OK for the layout2lsps script -;
    %if "%upcase(%substr(%quote(&lsps),1,5))" EQ "ERROR" %then %do;
      %put &err: (proginfo) Layout &_layout_ not recognised by the "layout2lsps" script;
      %let _abort_=1;
      %goto exit;
    %end;


    %let _ls_=%scan(&lsps,1,%str( ));
    %let _ps_=%scan(&lsps,2,%str( ));
  %end;


  %*- check we have a good value for linesize and if not quit -;
  %if %length(&_ls_) LT 2 %then %do;
    %put &err: (proginfo) SAS linesize value could not be determined for layout &_layout_;
    %let _abort_=1;
    %goto exit;
  %end;


  %*- set up a long time for dividing up sections in the output -;
  %let _longline_=%sysfunc(repeat(_,%eval(&_ls_-1)));



  %put;
  %put MSG: (proginfo) The following global macro variables have been set up and can be;
  %put MSG: (proginfo) used in your code. The information is a combination of what was;
  %put MSG: (proginfo) in the .titles file for that program and what is in "protocol.txt";
  %put _layout_=&_layout_;
  %put _rotate_=&_rotate_;
  %put _device_=&_device_;
  %put _vsize_=&_vsize_;
  %put _hsize_=&_hsize_;
  %put _vorigin_=&_vorigin_;
  %put _horigin_=&_horigin_;
  %put _pop_=&_pop_;
  %put _poplabel_=&_poplabel_;
  %put _reptype_=&_reptype_;
  %put _repid_=&_repid_;
  %put _replabel_=&_replabel_;
  %put _lisfile_=&_lisfile_;
  %put _repsort_=&_repsort_;
  %put _ls_=&_ls_;
  %put _ps_=&_ps_;
  %put _longline_=&_longline_;
  %put;


  %goto skip;
  %exit: %put &err: (proginfo) Leaving macro due to problem(s) listed;
  %skip:

%mend proginfo;
