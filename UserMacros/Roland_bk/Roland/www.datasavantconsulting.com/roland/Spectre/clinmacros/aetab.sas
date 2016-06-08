/*<pre><b>
/ Program   : aetab.sas
/ Version   : 2.6
/ Author    : Roland Rashleigh-Berry
/ Date      : 29-May-2015
/ Purpose   : To create a multi-level AE table of counts and percentages
/ SubMacros : %freqlvls %trnslvls %comblvls %prntlvls %mvarlist %removew
/             %hasvarsc %varnum %nlobs %varlist %mvarvalues %quotelst %words
/             %npctpvals %zerogrid %delmac (assumes %popfmt already run)
/ Notes     : You must have run %popfmt before calling this macro and the 
/             treatment variable and the patient unique identifier you supplied
/             to %popfmt must be present in the input AE dataset.
/
/             The output must remain as pure ascii output because of the use of
/             split characters which will not be rendered correctly in ODS.
/
/             You only need specify the first two positional parameters to get
/             a report. The column labels will be generated from the variable
/             labels in that case.
/
/             The default ordering of the output is by descending patient
/             frequency count for the totals treatment arm. To override this
/             ordering you have to specify numeric informats to the parameters
/             LVL1INFMT etc.. The %mkordinfmt macro might be useful to create
/             these numeric informats.
/
/             You are not limited to ten footnotes if you use the pageline or
/             endline parameters. If you have a footnotes macro that works with
/             compute blocks in proc report then you can specify the macro name
/             to the pagemacro= or endmacro= parameters.
/
/             Note that this macro uses the %splitvar macro to align characters
/             and this only works for Western character sets. See the %splitvar
/             macro header for more information.
/
/ Usage     : %aetab(ae3,msoc mhlgt mhlt mpt aeint)
/
/             %aetab(dsin=ae3,varlist=msoc mhlgt mhlt mpt aeint)
/
/             %aetab(dsin=ae3,varlist=msoc mhlgt mhlt mpt aeint,trtalign=center,
/                  colw=48,trtlabel="_Treatment Arms_" " ",total=yes,events=yes,
/                  alllowlvl=yes,alllowwhere=lvl5 ne ".",lowinfmt=int.);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) Input dataset (where clause allowed). Note that all
/                   the data in this dataset (with any where clause applied)
/                   will be used to calculate counts and percentages so you
/                   should only provide it with the data you want to see these
/                   counts and percentages for. There is no need to "collapse"
/                   multiple records into single records for the percentages
/                   since these are based on unique subject counts. However, it
/                   is important to make sure multiple records are collapsed if
/                   the number of events has been requested.
/ msglevel=X        Message level to use inside this macro for notes and 
/                   information written to the log. By default, both Notes and
/                   Information are suppressed. Use msglevel=N or I for more
/                   information.
/ varlist           (pos) AE levels variable list (current maximum of 9)
/ total=yes         By default, show the column for the totals of all treatments
/ trtfmt            (optional) Format to override the default format created by
/                   %popfmt.
/ events=no         By default, do not show event counts
/ print=yes         By default, print the output. Set this to no to make the
/                   internal datasets available for further processing.
/ pctfmt=5.1        Format for the percentage
/ pctsign=no        By default, do not show the % sign for the percentage
/ minpct            Minimum percentage below which items will be dropped
/                   (applies to the trtord treatment arm)
/ trtord            Treatment value for ordering the output and the arm for the
/                   minpct value to be applied to (defaults to the total
/                   treatment arm value).
/ pvalues=no        By default, do not calculate p-values
/ pvaltrtlist       List of treatment arm values (separated by spaces) used for
/                   p-value calculation (defaults to not using the value
/                   assigned to _trttotstr_ ).
/ pvalvar=_pvalue   Name of numeric p-value variable
/ pvalstr=_pvalstr  Name of character p-value variable
/ pvallbl="p-value" Label for numeric and character p-value variables (quoted)
/ pvalfmt=p63val.   Default format (created inside this macro) for formatting
/                   p-value statistic (6.3 unless <0.001 or >0.999).
/ pvalkeep=         Expression for p-value values to keep. If condition is not
/                   met then numeric and string values are set to missing.
/ fisherid=^        Symbol to suffix formatted p-values for the Fisher exact
/                   test.
/ chisqid=~         Symbol to suffix formatted p-values for the Chi-square test
/ nfmt=3.           Format for the N count (will be corrected if too small)
/ evfmt=4.          Format for the event count (will be corrected if too small)
/ colw=40           Column width for the combined AE terms
/ split=@           Split character for proc report
/ usecolon=yes      This is a splitting control and tells the %splitvar macro
/                   that you want text that flows onto further lines to align
/                   with any colon present if near the start of the string.
/ spacing=4         Spacing between the columns
/ topline=yes       Default is to show a line at the top of the report
/ indent=3          Indentation for each AE level
/ hindent=0         Hanging indent for lines that flow onto following lines
/ trtalign=center   Column label alignment
/ trtlabel          Label to show over the treatment arm columns
/ comblabel         Label for the AE terms column. If not specified then this
/                   label will be constructed from the variable labels.
/ breaklvl=1        Level at which you want to skip lines in proc report
/ alllowlvl=no      By default, do not show all the possible low level terms
/                   for every higher level term.
/ alllowwhere       Optional where term to limit the number of low level terms
/                   when using the alllowlvl=yes option.
/ lvl1anylbl="Patients with any Adverse Event"  Label to use for the first line
/                   of the report which is a count of unique patients with AEs.
/                   If you set this to " " then this line will be dropped.
/ lowinfmt          The lowest level numeric ordering informat (must be
/                   specified if alllowlvl=yes set).
/ lvl1-9infmt       Names of numeric informats to change the default ordering of
/                   the AE table.
/ pageline=no       By default, do not show a line at the bottom of the page.
/ pageline1-9       Footnote lines to show at the end of the page
/ pagemacro         Name of the footnotes macro (no % sign) that creates
/                   footnotes in proc report compute blocks.
/ endline=no        By default, do not show a line at the end of the report
/ endline1-9        Footnote lines to show at the end of the report
/ endmacro          Name of the footnotes macro (no % sign) that creates
/                   footnotes in proc report compute blocks.
/ filtercode        SAS code you specify to drop observations and do minor
/                   reformatting before printing is done. If this code
/                   contains commas then enclose in quotes (the quotes will be
/                   dropped from the start and end before the code is executed).
/                   You can have multiple lines of sas code if you end each line
/                   with a semicolon. For serious editing you should do this in
/                   a macro defined to extmacro= .
/ extmacro          External macro to call (no % sign) and will typically be
/                   used to include or drop stats values in the report.
/ dsparam           Name of parameter dataset. This can EITHER be a "flat"
/                   dataset with variable names matching parameter names OR a
/                   Name-Value pair "tall" dataset (both Name and Value must be
/                   character variables and be called "Name" and "Value" in the
/                   input dataset) with the contents of Name matching a parameter
/                   name and Value its value. "Tall" datasets are suited to the
/                   metadata-driven use of this macro. In both cases, variables
/                   should be character variables. Numeric values can be used
/                   but they must be supplied as characters. Note that parameter
/                   values that are normally supplied in quotes such as 'Courier'
/                   must be enclosed in extra quotes such as Value="'Courier'"
/                   when building the parameter dataset.
/
/                   You can use dataset modifiers when specifying the input
/                   dataset and these modifiers will be applied to create the
/                   internal work dataset "_dsparam". Do not call your parameter
/                   dataset "_dsparam" as this is reserved for use inside this
/                   macro and will be deleted.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  28Oct11         New (v1.0)
/ rrb  31Oct11         Parameter dataset and pctsign= handling added plus nfmt=
/                      and evfmt= values will be corrected if too small (v1.1)
/ rrb  31Oct11         minpct= processing for total column added (v1.2)
/ rrb  02Nov11         pvalue processing added (v2.0)
/ rrb  03Nov11         trtord= processing added (v2.1)
/ rrb  08Nov11         filtercode= and extmacro= processing added (v2.2)
/ rrb  14Nov11         Major bug fixed for p-values calculations. Changed the
/                      dataset pre-processing for calling the p-values macro to
/                      add zero observations where there is no match with the
/                      "totals" treatment arm (v2.3)
/ rrb  26Dec11         Header updated to explain that this macro only works
/                      correctly for Western character sets.
/ rrb  30Dec11         msglevel= processing added (v2.4)
/ rrb  30Jul12         Call to %delmac added at end (v2.5)
/ rrb  14Sep14         Use of "keyword" dropped for boolean options (v2.6)
/ rrb  29May15         Header description of dsin= parameter updated.
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: aetab v2.6;

%macro aetab(dsin,
          varlist,
         msglevel=X,
            total=yes,
           trtfmt=,
           events=no,
            print=yes,
             nfmt=3.,
           pctfmt=5.1,
          pctsign=no,
           minpct=,
           trtord=,
          pvalues=no,
      pvaltrtlist=,
          pvalvar=_pvalue,
          pvalstr=_pvalstr,
          pvallbl="p-value",
          pvalfmt=p63val.,
         pvalkeep=,
         fisherid=^,
          chisqid=~,
            evfmt=4.,
             colw=40,
            split=@,
         usecolon=yes,
          spacing=4,
          topline=yes,
           indent=3,
          hindent=0,
         trtalign=center,
         trtlabel=,
        comblabel=,
         breaklvl=1,
        alllowlvl=no,
      alllowwhere=,
       lvl1anylbl="Patients with any Adverse Event",
         lowinfmt=,
        lvl1infmt=,
        lvl2infmt=,
        lvl3infmt=,
        lvl4infmt=,
        lvl5infmt=,
        lvl6infmt=,
        lvl7infmt=,
        lvl8infmt=,
        lvl9infmt=,
         pageline=no,
        pageline1=,
        pageline2=,
        pageline3=,
        pageline4=,
        pageline5=,
        pageline6=,
        pageline7=,
        pageline8=,
        pageline9=,
       pageline10=,
       pageline11=,
       pageline12=,
       pageline13=,
       pageline14=,
       pageline15=,
        pagemacro=,
          endline=no,
         endline1=,
         endline2=,
         endline3=,
         endline4=,
         endline5=,
         endline6=,
         endline7=,
         endline8=,
         endline9=,
        endline10=,
        endline11=,
        endline12=,
        endline13=,
        endline14=,
        endline15=,
         endmacro=,
       filtercode=,
         extmacro=,
          dsparam=
            );

  %local parmlist;

  %*- get a list of parameters for this macro -;
  %let parmlist=%mvarlist(aetab);

  
  %local savopts lvls lvllist plugwith trtw trtvar trttot trtpref trtvars 
         uniqueid maxn maxev err errflag pvalds pvalpr;

  %let err=ERR%str(OR);
  %let errflag=0;

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

             /*-----------------------------------------*
                      Parameter dataset handling
              *-----------------------------------------*/


  %if %length(&dsparam) %then %do;



    %*- remove the macro variable name "parmlist" from this list -;
    %let parmlist=%removew(&parmlist,parmlist);

    *-- handle possible dataset modifiers --;
    data _dsparam;
      set &dsparam;
    run;
 
    %if %hasvarsc(_dsparam,name value) %then %do;
      *-- we have a Name-Value pair dataset so transpose it to a "flat" dataset --;
      proc transpose data=_dsparam(keep=name value) out=_dsparam(drop=_name_);
        var value;
        id name;
      run;
 
      %if %varnum(_dsparam,_label_) %then %do;
        *-- drop the _label_ --;
        data _dsparam,
          set _dsparam:
          drop _label_;
        run;
      %end;
    %end;

    %if %nlobs(_dsparam) NE 1 %then %do;
      %let errflag=1;
      %put &err: (aetab) The parameter dataset dsparam=&dsparam should have one;
      %put &err: (aetab) observation but this dataset has %nlobs(_dsparam) observations.;
      %put &err: (aetab) Checking of this dataset will continue but it can not be used.;
      %put;
    %end;

    %let varlist2=%varlistn(_dsparam);
    %if %length(&varlist2) %then %do;
      %let errflag=1;
      %put &err: (aetab) Numeric variables are not allowed in the parameter dataset ;
      %put &err: (aetab) dsparam=&dsparam but the following numeric variables exist:;
      %put &err: (aetab) &varlist2;
      %put;
    %end;

    %if %varnum(_dsparam,dsparam) %then %do;
      %let errflag=1;
      %put &err: (aetab) The variable DSPARAM is present in the parameter dataset;
      %put &err: (aetab) dsparam=&dsparam but use of this variable inside a;
      %put &err: (aetab) parameter dataset is not allowed.;
      %put;
    %end;

    proc contents noprint data=_dsparam out=_unicont(keep=name);
    run;

    data _null_;
      length badvars $ 2000;
      retain badvars ;
      set _unicont end=last;
      name=upcase(name);
      if name not in (%quotelst(&parmlist)) then badvars=trim(badvars)||" "||name;
      if last then call symput('badvars',trim(left(badvars)));
    run;

    %if %length(&badvars) %then %do;
      %let errflag=1;
      %put &err: (aetab) The following list of variables in dsparam=&dsparam;
      %put &err: (aetab) do not match any of the macro parameter names so the;
      %put &err: (aetab) parameter dataset will not be used:;
      %put &err: (aetab) &badvars;
      %put;
    %end;

    proc datasets nolist;
      delete _unicont;
    run;
    quit;

    %if &errflag %then %goto exit;

    *- the parameter dataset is good so call symput all the variables -;
    data _null_;
      set _dsparam;
      array _char {*} _character_;
      length __y $ 32;
      do __i=1 to dim(_char);
        __y=vname(_char(__i));
        call symput(__y,trim(left(_char(__i))));
      end;
    run;

    %let varlist2=%varlist(_dsparam);

    proc datasets nolist;
      delete _dsparam;
    run;
    quit;

    %put MSG: (aetab) The following macro parameters and their values were;
    %put MSG: (aetab) set as the result of use of the dsparam=&dsparam;
    %put MSG: (aetab) parameter dataset:;
    %mvarvalues(&varlist2);
    %put;

  %end;


      /*-----------------------------*
           check parameter settings
       *-----------------------------*/ 


  %let trtvar=&_trtvar_;

  %if not %length(&trtord) %then %let trtord=&_trttotstr_;
  %let trttot=&_trttotstr_;
  %let trtpref=&_trtpref_;
  %let uniqueid=&_uniqueid_;

  %if not %length(&trtfmt) %then %let trtfmt=&_popfmt_;

  %if not %length(&pvalues) %then %let pvalues=no;
  %let pvalues=%upcase(%substr(&pvalues,1,1));

  %if not %length(&total) %then %let total=yes;
  %let total=%upcase(%substr(&total,1,1));

  %if not %length(&pctsign) %then %let pctsign=no;
  %let pctsign=%upcase(%substr(&pctsign,1,1));

  %let trtvars=&_trtvarlist_;
  %if &total EQ Y %then %let trtvars=&_trtvarlist_ &_trttotvar_;


  %if not %length(&print) %then %let print=yes;
  %let print=%upcase(%substr(&print,1,1));

  %if not %length(&events) %then %let events=no;
  %let events=%upcase(%substr(&events,1,1));

  %if not %length(&pvaltrtlist) %then %let pvaltrtlist=ne &_trttotstr_;
  %else %let pvaltrtlist=in (&pvaltrtlist);

  %let lvls=%words(&varlist);

  %let lvllist=;
  %do i=1 %to &lvls;
    %let lvllist=&lvllist lvl&i;
  %end;

  %if not %length(&indent) %then %let indent=3;

  %if not %length(&comblabel) %then %do;
    %let comblabel="%varlabel(%scan(&dsin,1,%str(%()),%scan(&varlist,1,%str( )))";
    %do i=2 %to &lvls;
      %let comblabel=&comblabel
      "%sysfunc(repeat(%str( ),%eval((&i-1)*&indent-1)))%varlabel(%scan(&dsin,1,%str(%()),%scan(&varlist,&i,%str( )))";
    %end;
  %end;


      /*----------------------------------------------*
          calculate frequency counts and percentages 
       *----------------------------------------------*/ 


  %freqlvls(dsin=&dsin,varlist=&varlist,trtvar=&trtvar,trttot=&trttot,
            mvarmax=maxn,nodupvars=&uniqueid,dsout=_patcnt);

  %let maxn=&maxn;
  %if %length(&maxn) GT %scan(&nfmt,1,.) %then %let nfmt=%length(&maxn).;

  %if &events EQ Y %then %do;

    %freqlvls(dsin=&dsin,varlist=&varlist,trtvar=&trtvar,trttot=&trttot,calcord=no,
              mvarmax=maxev,dsout=_events);

    %let maxev=&maxev;
    %if %length(&maxev) GT %scan(&evfmt,1,.) %then %let evfmt=%length(&maxev).;

    data _tranrdy;
      merge _patcnt _events(rename=(_freq_=_events));
      by &trtvar &lvllist;
    run;

    data _tranrdy;
      %if &pctsign EQ Y %then %do;
        retain pctplug "%) ";
      %end;
      %else %do;
        retain pctplug ") ";
      %end;
      length str $ 30;
      merge _popfmt _tranrdy end=last;
      by &trtvar;
      _pct=100*_freq_/_total;
      str=put(_freq_,&nfmt)||" ("||put(_pct,&pctfmt)||pctplug||put(_events,&evfmt);
      if last then do;
        call symput('plugwith','"'||put(0,&nfmt)||" ("||put(0,&pctfmt)||pctplug||put(0,&evfmt)||'"');
      end;
      drop pctplug;
    run;

  %end;

  %else %do;

    data _tranrdy;
      %if &pctsign EQ Y %then %do;
        retain pctplug "%)";
      %end;
      %else %do;
        retain pctplug ")";
      %end;
      length str $ 30;
      merge _popfmt _patcnt end=last;
      by &trtvar;
      _pct=100*_freq_/_total;
      str=put(_freq_,&nfmt)||" ("||put(_pct,&pctfmt)||pctplug;
      if last then do;
        call symput('plugwith','"'||put(0,&nfmt)||" ("||put(0,&pctfmt)||pctplug||'"');
      end;
      drop pctplug;
    run;

  %end;


  %if &pvalues EQ Y %then %do;
   
    *- make sure we have zero _freq_ values for all combinations -;
    %zerogrid(zerovar=_freq_,
              dsout=_zerogrid(where=(&trtvar &pvaltrtlist)),
              var1=&trtvar _total,ds1=_popfmt,
              var2=&lvllist,ds2=_tranrdy);

    *- sort the data ready to merge on top of zero values -;
    proc sort data=_tranrdy(keep=&trtvar &lvllist _freq_
                           where=(&trtvar &pvaltrtlist))
               out=_forpvals;
      by &trtvar &lvllist;
    run;

    *- merge on top of zero _freq_ values -;
    data _forpvals;
      merge _zerogrid _forpvals;
      by &trtvar &lvllist;
    run;

    *- generate the value for the p-value calculation -;
    data _forpvals;
      set _forpvals;
      _response=1;
      _weight=_freq_;
      output;
      _response=0;
      _weight=_total-_freq_;
      output;
      keep &lvllist &trtvar _response _weight;
    run;

    proc sort data=_forpvals;
      by &lvllist &trtvar;
    run;

    %if %attrn(_forpvals,nobs) GT 0 %then %do;
      %let pvalds=_pvalues;
      %let pvalpr=&pvalstr;
      %npctpvals(dsin=_forpvals,byvars=&lvllist,pvalvar=&pvalvar,pvallbl=&pvallbl,
                 pvalstr=&pvalstr,pvalfmt=&pvalfmt,pvalkeep=&pvalkeep,
                 trtvar=&trtvar,respvar=_response,countvar=_weight,
                 chisqid=&chisqid,fisherid=&fisherid);

      %if %length(&lvl1anylbl) %then %do;
        data _pvalues;
          set _pvalues;
          if lvl1=:"ANY " then lvl1=&lvl1anylbl;
          if lvl1=" " then delete;
        run;
        proc sort data=_pvalues;
          by &lvllist;
        run;
      %end;

    %end;

    proc datasets nolist;
      delete _zerogrid _forpvals;
    run;
    quit;

  %end;


      /*----------------------------------------------*
            transpose the values by treatment arm 
       *----------------------------------------------*/ 

  %trnslvls(dsin=_tranrdy,dsout=_tran,var=str,trtvar=&trtvar,trtfmt=&trtfmt,
  trtord=&trtord,alllowlvl=&alllowlvl,alllowwhere=&alllowwhere,lowinfmt=&lowinfmt,
  plugwith=&plugwith,lvls=&lvls,lvl1anylbl=&lvl1anylbl,prefix=&trtpref,
  lvl1infmt=&lvl1infmt,lvl2infmt=&lvl2infmt,lvl3infmt=&lvl3infmt,
  lvl4infmt=&lvl4infmt,lvl5infmt=&lvl5infmt,lvl6infmt=&lvl6infmt,
  lvl7infmt=&lvl7infmt,lvl8infmt=&lvl8infmt,lvl9infmt=&lvl9infmt);

  %if %length(&minpct) %then %do;
    proc sort data=_tranrdy out=_tranpct;
      by &lvllist &trtvar;
    run;
    proc transpose prefix=_PCT data=_tranpct out=_tranpct(drop=_name_);
      by &lvllist; 
      id &trtvar;
      var _pct;
      format &trtvar;
    run;
    %if %length(&lvl1anylbl) %then %do;
      data _tranpct;
        set _tranpct;
        if lvl1=:"ANY " then lvl1=&lvl1anylbl;
        if lvl1=" " then delete;
      run;
      proc sort data=_tranpct;
      by &lvllist;
      run;
    %end;
    proc sort data=_tran;
      by &lvllist;
    run;
    data _tran;
      merge &pvalds _tran _tranpct;
      by &lvllist;
      if _pct%sysfunc(compress(&trtord,%str(%'%"))) >= &minpct;
    run;
  %end;
  %else %do;
    %if %length(&pvalds) %then %do;
      proc sort data=_tran;
        by &lvllist;
      run;
      data _tran;
        merge &pvalds _tran;
        by &lvllist;
      run;
    %end;
  %end;
        


      /*----------------------------------------------*
          combine the AE terms into a single column 
       *----------------------------------------------*/ 

  %comblvls(dsin=_tran,dsout=_trancmb,lvls=&lvls,colw=&colw,split=&split,
           indent=&indent,hindent=&hindent,usecolon=&usecolon);



        /*-----------------------------------------*
                  Manipulate output dataset 
         *-----------------------------------------*/

  %*-- apply filter code if any --;
  %if %length(&filtercode) %then %do;
    data _trancmb;
      set _trancmb;
      %unquote(%qdequote(&filtercode));
    run;
  %end;


  %*- call external data manipulation macro if set -;
  %if %length(&extmacro) %then %do;
    %&extmacro;
  %end;


             /*----------------------------*
                 print the final dataset 
              *----------------------------*/ 

  %if &print NE N %then %do;

    %let trtw=%eval(%scan(&nfmt,1,.)+%scan(&pctfmt,1,.)+3);
    %if &events EQ Y %then %let trtw=%eval(&trtw+1+%scan(&evfmt,1,.));
    %if &pctsign EQ Y %then %let trtw=%eval(&trtw+1);

    %prntlvls(dsin=_trancmb,lvls=&lvls,colw=&colw,trtvars=&trtvars,
    breaklvl=&breaklvl,trtw=&trtw,spacing=&spacing,trtalign=&trtalign,
    trtlabel=&trtlabel,comblabel=&comblabel,split=&split,topline=&topline,
    pageline=&pageline,pageline1=&pageline1,pageline2=&pageline2,
    pageline3=&pageline3,pageline4=&pageline4,pageline5=&pageline5,
    pageline6=&pageline6,pageline7=&pageline7,pageline8=&pageline8,
    pageline9=&pageline9,pageline10=&pageline10,pageline11=&pageline11,
    pageline12=&pageline12,pageline13=&pageline13,pageline14=&pageline14,
    pageline15=&pageline15,pagemacro=&pagemacro,pvalvar=&pvalpr,
    endline=&endline,endline1=&endline1,endline2=&endline2,
    endline3=&endline3,endline4=&endline4,endline5=&endline5,
    endline6=&endline6,endline7=&endline7,endline8=&endline8,
    endline9=&endline9,endline10=&endline10,endline11=&endline11,
    endline12=&endline12,endline13=&endline13,endline14=&endline14,
    endline15=&endline15,endmacro=&endmacro);

    proc datasets nolist;
      delete &pvalds _patcnt _events _tranrdy _tran _trancmb;
    run;
    quit;

  %end;

  %goto skip;
  %exit: %put &err: (aetab) Leaving macro due to problem(s) listed;
  %skip:

  %delmac(\_npct:);

  options &savopts;

%mend aetab;
