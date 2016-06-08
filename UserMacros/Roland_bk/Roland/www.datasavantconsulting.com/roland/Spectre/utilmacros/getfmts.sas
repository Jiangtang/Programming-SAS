/*<pre><b>
/ Program      : getfmts.sas
/ Version      : 3.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-Jul-2013
/ Purpose      : To get details of a list of user formats defined in a dataset
/ SubMacros    : %words %fmtpath %nobs %getvalue %varnum
/ Notes        : The dataset produced will be the usual style created by proc
/                format cntlout. The format catalogs are searched in the order
/                defined to fmtsearch. 
/
/                Formats that can not be found are written to the global macro
/                variable _badfmts_ and reported in the log. If none of the
/                formats can be found then an error message is written to the
/                log.
/
/                You should make sure your input dataset contains a unique list
/                of user-only formats. You can get this with a "proc contents"
/                and drop format names of " " "$" "DATE" "TIME" "DATETIME"
/                "BEST" and perhaps some more and sort NODUPKEY on "format".
/
/                You can use the libref= parameter to automatically give you a
/                dataset of unique user formats named "_getcont" that the macro
/                will use internally. This dataset will not be deleted so that
/                you can inspect it for possible problems. You can then edit it
/                if need be and use it as input to this macro in a second run.
/
/                The output dataset is in a format that can be used directly by
/                "proc format" as a cntlin= dataset to create formats. If you
/                are sending data offsite then this is a convenient way to
/                supply the formats that go with the datasets you are sending.
/                The receiver of this dataset can recreate the formats by
/                running this simple code:
/                       proc format cntlin=_getfmts;
/                       run;
/
/ Usage        : %getfmts(dsin=fmtlist,fmtvar=format,dsout=allfmts);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ libref            Use this as an alternative to dsin= and fmtvar= and it will
/                   run proc contents to create a dataset that is a unique list
/                   of user formats as input. Note that this is done for _all_
/                   datasets in the library.
/ dsin              One or two part dataset name containing a unique list of
/                   user formats.
/ fmtvar            Name of the variable in the input dataset containing the
/                   format name (character formats should start with a "$")
/ dsout=_getfmts    Name of the dataset to contain all the format information
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13May11         libref= parameter added (v2.0)
/ rrb  15Sep12         Call to %getvalue simplified for new version (v2.1)
/ rrb  04Jul13         Check for input dataset view as well as dataset and
/                      improved instructions in the header regarding use of the
/                      library parameter. Format names in the dsin= dataset
/                      get the ending period and numbers dropped and not in the
/                      macro code for greater efficiency. Duplicate format names
/                      are dropped. Major changes hence (v3.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: getfmts v3.0;

%macro getfmts(dsin=,
               libref=,
               fmtvar=,
               dsout=_getfmts,
               debug=no
              );

  %local i j ext cat catlist gotit err errflag 
         format fmtname first done savopts;
  %let err=ERR%STR(OR);
  %let errflag=0;

  *-- first time through flag --;
  %let first=1;

  *-- to store list of unresolved formats --;
  %global _badfmts_;
  %let _badfmts_=;

  %if NOT %length(&debug) %then %let debug=no;
  %let debug=%upcase(%substr(&debug,1,1));

  %let savopts=%sysfunc(getoption(notes));

  %if &debug NE Y %then %do;
    options nonotes;
  %end;


  /***********************************
           libref handling
   ***********************************/

  %if %length(&libref) %then %do;
    proc contents noprint data=&libref.._all_ out=_getcont(keep=format);
    run;
    proc sort nodupkey 
       data=_getcont(where=(format not in (" " "$" "DATE" "TIME" "DATETIME" "BEST")))
       out=_getcont;
      by format;
    run;
    %let dsin=_getcont;
    %let fmtvar=format;
  %end;


  /***********************************
      Check the parameter settings
   ***********************************/

  %else %do;

    %if NOT %length(&dsout) %then %let dsout=_getfmts;

    %if NOT %length(&dsin) %then %do;
      %let errflag=1;
      %put &err: (getfmts) No input dataset assigned to dsin=;
    %end;
    %else %do;
      %if NOT %sysfunc(exist(&dsin)) 
       and NOT %sysfunc(exist(&dsin,VIEW)) %then %do;
        %let errflag=1;
        %put &err: (getfmts) Dataset or view dsin=&dsin does not exist;
      %end;
      %else %do;
        %if NOT %varnum(&dsin,&fmtvar) %then %do;
          %let errflag=1;
          %put &err: (getfmts) Variable fmtvar=&fmtvar does not exist in dataset dsin=&dsin;
        %end;
        %else %do;
          data _getcont(keep=&fmtvar);
            set &dsin;
            if &fmtvar=" " then delete;
            &fmtvar=upcase(prxchange('s§\d*\.\s*$§§',1,&fmtvar));
            if &fmtvar in (" " "$" "DATE" "TIME" "DATETIME" "BEST") then delete;
          run;
          proc sort nodupkey data=_getcont;
            by &fmtvar;
          run;
          %let dsin=_getcont;
        %end;
      %end;
    %end;

  %end;

  %if &errflag %then %GOTO exit;


  /*********************************************
     Store the format search path catalog list
   *********************************************/

  %let catlist=%fmtpath;


  /*********************************************
        Loop through the formats dataset
   *********************************************/

  %do i=1 %TO %nobs(&dsin);

    *-- get the next format name from the input dataset --;
    %let format=%getvalue(&dsin,&fmtvar,&i);

    %put NOTE: (getfmts) Working on format &format;

    %let ext=FORMAT;
    %let fmtname=&format;

    %if "%substr(&format,1,1)" EQ "$" %then %do;
      %let ext=FORMATC;
      %let fmtname=%substr(&format,2);
    %end;

    /***********************************
        Loop through the catalog list
     ***********************************/

    %let gotit=0;
    %do j=1 %TO %words(&catlist);
      %let cat=%scan(&catlist,&j,%STR( ));
      %if %sysfunc(cexist(&cat..&fmtname..&ext)) %then %do;
        %let gotit=1;
        %let done=&done &format;
        proc format lib=&cat cntlout=_fmtemp;
          select &format;
        run;
        quit;

        /*****************************************
            Enforce consistent variable lengths
         *****************************************/

        data _fmtemp2;
          length start end $ 50 label $ 148;
          set _fmtemp(rename=(start=start_x end=end_x label=label_x));
          start=left(start_x);
          end=left(end_x);
          label=left(label_x);
          drop start_x end_x label_x;
          label start="Starting value for format"
                  end="Ending value for format"
                label="Format value label"
                ;
        run;

          /**********************
              Append the data
           **********************/

        %if &first EQ 1 %then %do;
          data &dsout;
            set _fmtemp2;
          run;
          %let first=0;
        %end;
        %else %do;
          proc append base=&dsout data=_fmtemp2;
          run;
        %end;

          /**********************
                  Tidy up
           **********************/
        proc datasets nolist;
          delete _fmtemp _fmtemp2;
        run;
        quit;

          /**********************
               Leave the loop
           **********************/
        %let j=99;
      %end;
    %end;

    %if NOT &gotit %then %let _badfmts_=&_badfmts_ &format;

  %end;

  %if "&dsin" EQ "_getcont" %then %do;
    proc datasets nolist;
      delete _getcont;
    quit;
  %end;

  options notes;

  %put NOTE: (getfmts) The following format search path was assumed:;
  %put NOTE: (getfmts) &catlist;
  %put;

  %if NOT %length(&done) %then %do;
    %put &err: (getfmts) None of the formats could be found on the format search path;
    %put &err: (getfmts) and the list is stored in the global macro variable _badfmts_ :;
    %put &err: (getfmts) &_badfmts_;
    %goto exit;
  %end;
  %else %do;
    %put NOTE: (getfmts) The following formats were found and processed and the;
    %put NOTE: (getfmts) format information was written to the dataset &dsout :;
    %if NOT %length(&_badfmts_) %then
      %put NOTE: (getfmts) (All the specified formats were found);
    %put NOTE: (getfmts) &done;
  %end;

  %if %length(&_badfmts_) %then %do;
    %put;
    %put NOTE: (getfmts) The following formats could not be found on the format search path;
    %put NOTE: (getfmts) and the list is stored in the global macro variable _badfmts_ :;
    %put NOTE: (getfmts) &_badfmts_;
  %end;

  options &savopts;

  %goto skip;
  %exit: %put &err: (getfmts) Leaving macro due to problem(s) listed;
  %skip:

%mend getfmts;
