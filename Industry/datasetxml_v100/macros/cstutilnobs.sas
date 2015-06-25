%* cstutilnobs                                                                    *;
%*                                                                                *;
%* Returns the number of observations in a data set or an error.                  *;
%*                                                                                *;
%* If the data set does not exist or cannot be opened, an error occurs.           *;
%*                                                                                *;
%* These actions occur:                                                           *;
%* 1. The macro attempts to open the data set.                                    *;
%*    If the data set cannot be opened, an error message is returned and          *;
%*    processing stops.                                                           *;
%* 2. The macro checks the values of the data set attributes ANOBS (Does SAS know *;
%*    how many observations there are?) and WHSTMT (Is a WHERE statement in       *;
%*    effect?).                                                                   *;
%* 3. If SAS knows the number of observations and there is no WHERE clause, the   *;
%*    value of the data set attribute NLOBS (number of logical observations) is   *;
%*    returned.                                                                   *;
%* 4. If SAS does not know the number of observations (perhaps this is a view or  *;
%*    transport data set) or if a WHERE clause is in effect, a forced read is done*;
%*    of the data set using NLOBSF. (NOTE: that this can be slow for large data   *;
%*    sets.)                                                                      *;
%*    If the data set exists, the value returned is a whole number. If the data   *;
%*    set cannot be opened, a period (the default missing value) is returned.     *;
%*                                                                                *;
%*   Examples:                                                                    *;
%*     %put %cstutilnobs(_cstDataSetName=sashelp.class)                           *;
%*     %put %cstutilnobs(_cstDataSetName=sashelp.class(where=(sex="M")))          *;
%*     %put %cstutilnobs(_cstDataSetName=sashelp.vtable)                          *;
%*     title "sashelp.class has %cstutilnobs(_cstDataSetName=sashelp.class) obs"  *;
%*                                                                                *;
%* @param _cstDataSetName - required - The (libname.)memname of the data set.     *;
%*            Default: _last_                                                     *;
%*                                                                                *;
%* @since 1.5                                                                     *;
%* @exposure internal                                                             *;

%macro cstutilnobs(_cstDataSetName=_last_)
    / des='CST: Returns the number of observations in a data set';

  %* Declare local variables used in the macro  *;
  %local _cstdsid _cstnobs _cstrc;

  %let _cstdsid = %sysfunc(open(&_cstDataSetName, I));
   %* Failed to open the data set *;
   %if &_cstdsid = 0
    %then %do;
      %put %sysfunc(sysmsg());
      %let _cstnobs = .;
      %goto exit_abort;
    %end;
    %else %do;
      %* Check to see if the engine is aware of # obs *;
      %* and if there is an active where clause       *;
      %if %sysfunc(attrn(&_cstdsid, ANOBS)) = 1 and
          %sysfunc(attrn(&_cstdsid, WHSTMT)) = 0
        %then %let _cstnobs = %sysfunc(attrn(&_cstdsid, NLOBS));
        %else %let _cstnobs = %sysfunc(attrn(&_cstdsid,NLOBSF));
      %let _cstrc = %sysfunc(close(&_cstdsid));
    %end;
  %exit_abort:
  %*;&_cstnobs%*;

%mend cstutilnobs;
