/*<pre><b>
/ Program   : qcworst.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 18-Jan-2012
/ Purpose   : To QC the setting of WORST repeat values
/ SubMacros : none
/ Notes     : This macro requires variables LAB, LL, UL and WORSTDIR to be
/             present in the input dataset as well as _PERIOD that holds a
/             numeric value as follows: 0=pre-pre treatment, 1=pre-treatment,
/             2=on treatment, 3=post treatment, 99=others.
/
/             The input dataset must be sorted in the order STUDY PTNO LABNM
/             _PERIOD VISNO SUBEVNO and the output dataset will be returned in
/             the same order with no extra variables added.
/
/ Limitations:
/
/             This macro follows XLAB 2 conventions where there is a missing
/             WORSTDIR and will set all Repeats and non-zero subevno to
/             _FGREPT=5 and will warn in the log if this has happened.
/
/ Usage     : %qcworst(_lab3,_lab4)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ inlab             (pos) Input lab dataset (no modifiers)
/ outlab            (pos) Output lab dataset (no modifiers)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  18Jan12         New (v1.0)
/=============================================================================*/

%put MACRO CALLED: qcworst v1.0;


%macro qcworst(inlab,outlab);

    %local badlab wrn;
    %let wrn=WARN%str(ING);

    data _qcworst;
      retain _dirflag "  ";
      set &inlab;
      by study ptno labnm _period visno subevno;
      if first.visno then _dirflag=" ";
      if first.visno and not last.visno then do;
        if lab<mean(ll,ul) then _dirflag="-1";
        else _dirflag="+1";
      end;
    run;

    *- on treatment values for finding the worst -;
    data _qcontw;
      length _fgwrs $ 2;
      set _qcworst(keep=study ptno labnm _period visno subevno
                     lab worstdir _dirflag
               where=(_period=2));
      if worstdir in ("-1" "+1") then _fgwrs=worstdir;
      else _fgwrs=_dirflag;
      if _fgwrs="-1" then _evno=subevno;
      else _evno=1000-subevno;
    run;

    *- sort into lab value order -;
    proc sort data=_qcontw;
      by study ptno labnm visno lab _evno;
    run;

    *- keep obs depending on the direction -;
    data _qcontw2;
      set _qcontw;
      by study ptno labnm visno;
      if (first.visno and _fgwrs="-1") 
      or (last.visno and _fgwrs="+1")
      or _fgwrs=" ";
    run;

    *- merge back in with data to show the WORST repeats -;
    data &outlab _qcbad(keep=labnm);
      merge _qcontw2(keep= study ptno labnm _period visno subevno in=_a) _qcworst;
      by study ptno labnm _period visno subevno;
      if not _a and _period=2 then _fgrept=5;
      *--- The below lines were added to copy XLAB 2 behaviour ---;
      *--- when it does not get a WORSTDIR value merged in.    ---;
      if not (first.visno and last.visno) and missing(worstdir) 
       and _period=2 then do;
        _fgrept=5;
        output _qcbad;
      end;
      if _period=2 and missing(worstdir) and subevno>0 then do;
        _fgrept=5;
        output _qcbad;
      end;
      output &outlab;
      drop _dirflag;
    run;

    proc sql noprint;
      select distinct(labnm) into: badlab separated by " " from _qcbad;
    quit;

    proc datasets nolist;
      delete _qcworst _qcontw _qcontw2 _qcbad;
    run;
    quit;

    %if %length(&badlab) %then 
%put &wrn: (qcworst) Some WORST repeat values incorrectly flagged for lab parameter(s) &badlab as no match with WORSTDIR;

%mend qcworst;