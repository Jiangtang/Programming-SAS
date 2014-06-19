/*<pre><b>
/ Program   : views2data.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 28-Jun-2013
/ Purpose   : To convert all sas data views in one library into data sets in
/             another library.
/ SubMacros : %vwlist %words
/ Notes     : There does not appear to be a native way of copying views from one
/             location to another and turning them into data sets in the process
/             which is a common requirement for when data is sent to regulatory
/             authorities. This macro fills that gap.
/ Usage     : %views2data(viewlib,datalib);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ viewlib           (pos) Libref of the library containing views
/ datalib           (pos) Libref of the library to contain the data sets
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  28Jun13         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: views2data v1.0;

%macro views2data(viewlib,datalib);
  %local i view;
  %vwlist(&viewlib);
  %do i=1 %to %words(&_vwlist_);
    %let view=%scan(&_vwlist_,&i,%str( ));
    data &datalib..&view;
      set &viewlib..&view;
    run;
  %end;
%mend views2data;
