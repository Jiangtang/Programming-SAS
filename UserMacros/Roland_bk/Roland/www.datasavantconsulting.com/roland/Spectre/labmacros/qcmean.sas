/*<pre><b>
/ Program   : qcmean.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 23-Jan-2012
/ Purpose   : To QC the setting of MEAN or MEDIAN repeat values
/ SubMacros : %match %varlist
/ Notes     : This macro requires a variable _PERIOD present in the input
/             dataset that holds a numeric value as follows:
/                0=pre-pre treatment, 1=pre-treatment,
/                2=on treatment, 3=post treatment, 99=others.
/
/             The input dataset must be sorted in the order STUDY PTNO LABNM
/             _PERIOD VISNO SUBEVNO and the output dataset will be returned in
/             the same order with no extra variables added but with added MEAN
/             or MEDIAN observations.
/
/ Limitations:
/
/
/ Usage     : %qcmean(_lab3,_lab4)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ inlab             (pos) Input lab dataset (no modifiers)
/ outlab            (pos) Output lab dataset (no modifiers)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  23Jan12         New (v1.0)
/=============================================================================*/

%put MACRO CALLED: qcmean v1.0;


%macro qcmean(inlab,outlab,stat=mean,reptval=1);

   %local i labvars var;
   %let labvars=%match(LAB LABSTD LABN,%varlist(&inlab));

   data _qcmean _qcfirst;
     set &inlab;
     by study ptno labnm _period visno subevno;
     if _period=2 then do;
       if not (first.visno and last.visno) then do;
         if first.visno then output _qcfirst;
         _fgrept=&reptval;
       end;
     end;
     output _qcmean;
   run;


   %do i=1 %to %words(&labvars);
     %let var=%scan(&labvars,&i,%str( ));
     proc univariate noprint data=_qcmean(where=(_period=2 and _fgrept=&reptval));
       by study ptno labnm _period visno;
       var &var;
       output out=_qcmuni&i &stat=&var;
     run;
   %end;


   data _qcfirst2;
     merge %do i=1 %to %words(&labvars); 
           _qcmuni&i
           %end; 
           _qcfirst(drop=&labvars);
     by study ptno labnm _period visno;
   run;


    *- merge back in with data -;
    data &outlab;
      set _qcmean _qcfirst2;
      by study ptno labnm _period visno subevno;
    run;

    *- tidy up -;
    proc datasets nolist;
      delete _qcmean _qcfirst _qcfirst2
             %do i=1 %to %words(&labvars); 
              _qcmuni&i
             %end; 
             ;
    run;
    quit;

%mend qcmean;