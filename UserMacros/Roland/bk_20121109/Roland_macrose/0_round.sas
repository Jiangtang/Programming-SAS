/*<pre><b>
/ Program   : round.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To round all the numeric variables in a list of datasets.
/ SubMacros : %dsall %words %varlistn
/ Notes     : You can use the _all_ notation to refer to all the datasets in a
/             library. You would normally run this against datasets obtained 
/             from a different platform before you use the data. This is because
/             numbers are stored to different accuracies on different platforms.
/             You would normally run this after running %dropvars on the
/             datasets to drop umwanted variables.
/ Usage     : %round(work._all_)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- ------------------------description-------------------------
/ list              (pos) List of datasets. The _all_ notation can be used.
/ roundto=0.0000000001    Value to round to.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: round v1.0;

%macro round(list,roundto=0.0000000001);

  %local varlistn i j;
  %dsall(&list)

  %do i=1 %to %words(&_dsall_);
    %let varlistn=%varlistn(%scan(&_dsall_,&i,%str( )));
    %if %length(&varlistn) %then %do;
      data %scan(&_dsall_,&i,%str( ));
        set %scan(&_dsall_,&i,%str( ));
      %do j=1 %to %words(&varlistn);
        %scan(&varlistn,&j,%str( ))=round(%scan(&varlistn,&j,%str( )),&roundto);
      %end;
      run;
    %end;
  %end;

%mend round;
