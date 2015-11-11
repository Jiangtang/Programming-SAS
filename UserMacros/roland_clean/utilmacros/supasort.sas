/*<pre><b>
/ Program   : supasort.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To sort a list of datasets by variables if they exist in the
/             datasets.
/ SubMacros : %dsall %words %varlist %quotelst
/ Notes     : You can use the _all_ notation to refer to all the datasets in a
/             library.
/ Usage     : %supasort(work._all_,date time)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ list              (pos) List of datasets. The _all_ notation can be used.
/ by                (pos) List of "by" variables (separated by spaces).
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: supasort v1.0;

%macro supasort(list,by);
  %local byvars varlist i j;
  %dsall(&list)
  %let by=%quotelst(%upcase(&by));

  %do i=1 %to %words(&_dsall_);
    %let byvars=;
    %let varlist=%varlist(%scan(&_dsall_,&i,%str( )));
    %do j=1 %to %words(&varlist);
      %if %index(&by,"%upcase(%scan(&varlist,&j,%str( )))") 
        %then %let byvars=&byvars %scan(&varlist,&j,%str( ));
    %end;
    %if %length(&byvars) %then %do;
      proc sort data=%scan(&_dsall_,&i,%str( ));
        by &byvars;
      run;
    %end;
  %end;
%mend supasort;
