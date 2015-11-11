/*<pre><b>
/ Program   : complibs.sas
/ Version   : 3.2
/ Author    : Roland Rashleigh-Berry
/ Date      : 15-Apr-2011
/ Purpose   : To "proc compare" identically-named datasets in two libraries
/ SubMacros : %supasort %attrc %words %nvarsc %nvarsn %varlistc %missvars
/             %match %dsall %quotelst %varlist %removew %varlistn %nodup
/ Notes     : It is for comparing different versions of the data to identify
/             what has been added or deleted or changed. Each dataset is
/             compared with each identically named dataset in each library.
/             Titles will be assigned internally during macro execution.
/
/             You can either set up the librefs before calling this macro and
/             pass the pure libref names to the parameters or if you put in
/             quotes then it will assign the librefs for you and deassign on
/             completion.
/
/             If the datasets are supposed to be exactly the same then set the
/             parameter direct=yes and it will do an obs by obs comparison. If
/             not then you are recommended to supply a list of sort variables to
/             sortvars= for your datasets that you use to define uniqueness of
/             the observations. %supasort will be called to sort the datasets
/             for variables found in this variable list. This is needed since we
/             can not assume the datasets are in any particular order and we
/             need an order for comparisons. If you leave this blank then it
/             will be assumed that matching datasets are already sorted in a
/             unique order and this sort order will be used in the comparison.
/             If no such sort variables exist then the variables defined to
/             dfsortvars= will be used but failing that an error message will be
/             put out for that dataset.
/
/             If you set chardiff=yes then the differences found in character
/             fields are shown in a "proc print" so you are not limited to only
/             20 characters as shown the the standard "proc compare" output.
/             Using this option will greatly increase the size of the output.
/             Only the "id" variables plus character variables where a change
/             was found are shown in this listing.
/
/ Usage     : %complibs(base,comp)
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ libold            (pos) Libref of old library or path name enclosed in quotes.
/ libnew            (pos) Libref of new library or path name enclosed in quotes.
/ sortvars          (optional) List of variables separated by spaces that you
/                   would use to sort the datasets to obtain uniqueness. If left
/                   blank then the current sort order is used.
/ dfsortvars        (options) Default sort variables to use if none defined to
/                   sortvars= and no current sort variables detected for a
/                   dataset.
/ direct=no         By default, do not do a one to one obs comparison. Overrides
/                   sort variable parameters if set to yes. Use this is your
/                   datasets should be exactly the same.
/ options           Options for "proc compare". "listall" is the default.
/ chardiff=no       (unquoted) By default, do not show detailed character field
/                   differences.
/ dslist            Optional list of datasets to compare that you know exist in
/                   both libraries.
/ titlenum=1        Start title number
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  30Mar06         Use current sort variables for each dataset if nothing is
/                      supplied to sortvars= and added dfsortvars= and direct=
/                      parameters.
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  15Jul08         chardiff= parameter added for detailed analysis of
/                      character variable difference beyond the 20 character
/                      limit (v3.0)
/ rrb  12Oct09         Header tidy
/ rrb  30Jan11         titlenum= parameter added (v3.1)
/ rrb  15Apr11         dslist= parameter added (v3.2)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: complibs v3.2;

%macro complibs(libold,
                libnew,
                sortvars=,
                dfsortvars=,
                direct=no,
                options=listbase,
                chardiff=no,
                dslist=,
                titlenum=1
                );

  %local fnew fold refnew refold sortedby ds i j match cvars err;

  %let err=ERR%str(OR);
  %if not %length(&direct) %then %let direct=no;
  %let direct=%upcase(%substr(&direct,1,1));

  %if not %length(&chardiff) %then %let chardiff=no;
  %let chardiff=%upcase(%substr(&chardiff,1,1));

  %*- Set up libref if libnew is a file name (starts with a quote) -;
  %if %index(%str(%'%"),%qsubstr(&libnew,1,1)) %then %do;
    %let fnew=Y;
    %let refnew=NEW;
    libname NEW &libnew access=readonly;
  %end;
  %else %let refnew=%upcase(&libnew);


  %*- Set up libref if libold is a file name (starts with a quote) -;
  %if %index(%str(%'%"),%qsubstr(&libold,1,1)) %then %do;
    %let fold=Y;
    %let refold=OLD;
    libname OLD &libold access=readonly;
  %end;
  %else %let refold=%upcase(&libold);

  %if NOT %length(&dslist) %then %do;

    *- Get a list of datasets in the old library -;
    proc sort data=sashelp.vtable(keep=memname libname memtype
                         where=(libname="&refold" and memtype='DATA'))
               out=_baseds(drop=libname memtype);
      by memname;
    run;


    *- Get a list of datasets in the new library -;
    proc sort data=sashelp.vtable(keep=memname libname memtype
                         where=(libname="&refnew" and memtype='DATA'))
               out=_compds(drop=libname memtype);
      by memname;
    run;


    *- Select out those datasets that exist in both libraries -;
    data _both;
      merge _baseds(in=_base) _compds(in=_comp);
      by memname;
      if _base and _comp;
    run;


    *- Write list of matching datasets out to a macro variable -;
    proc sql noprint;
      select memname into :dslist separated by ' ' from _both;
    quit;

    proc datasets nolist;
      delete _baseds _compds _both;
    run;
    quit;

  %end;
  %else %let dslist=%upcase(&dslist);

  %*- For each dataset in the list, do the following -;
  %do i=1 %to %words(&dslist);
    %let ds=%scan(&dslist,&i,%str( ));

      *- Base data ready for sorting -;
    data _base;
      set &refold..&ds;
    run;

    *- Compare data ready for sorting -;
    data _comp;
      set &refnew..&ds;
    run;

    *- assign title for the output -;
    title&titlenum "Comparison of &ds dataset between &refold and &refnew libraries";


    %*- direct obs by obs comparison -;
    %if "&direct" EQ "Y" %then %do;
      proc compare base=_base compare=_comp &options;
      run;
    %end;

    %else %do;  %*- sorted comparison -;

      %*- sort base and compare data into matching variable order -;
      %if %length(&sortvars) %then %do;
        %supasort(_base _comp,&sortvars)
        %let sortedby=%attrc(_base,sortedby);
      %end;
      %else %do;
        %let sortedby=%attrc(&refold..&ds,sortedby);
        %if not %length(&sortedby) %then %let sortedby=%attrc(&refnew..&ds,sortedby);
        %if %length(&sortedby) %then %do;
          proc sort data=_base;
            by &sortedby;
          run;
          proc sort data=_comp;
            by &sortedby;
          run;
        %end;
        %else %if %length(&dfsortvars) %then %do;
          %supasort(_base _comp,&dfsortvars)
          %let sortedby=%attrc(_base,sortedby);
        %end;
      %end;


      %if %length(&sortedby) %then %do;

        *- Do the comparison between the datasets -;
        proc compare base=_base compare=_comp &options;
          id &sortedby;
        run;

  %if "&chardiff" EQ "Y" %then %do;

        *- show detailed character variable differences -;
        proc compare base=_base compare=_comp out=_result outnoequal outbase outcomp outdif noprint;
          id &sortedby;
        run;

        data _dif;
          set _result(where=(_type_="DIF"));
          drop _type_;
        run;

        %put >>>>>>>>>> ds=&ds;
        %put >>>>>>>>>> sortedby=&sortedby;

        %let cvars=%varlistc(_dif);
        %put >>>>>>>>>> cvars=&cvars;

        %if %words(&cvars) EQ 0 %then %goto skip;

        %let cvars=%removew(&cvars,&sortedby);
        %put >>>>>>>>>> cvars with sortedby removed = &cvars;


        %if %words(&cvars) EQ 0 %then %goto skip;

        data _dif;
          set _dif(keep=&sortedby &cvars);
          %do j=1 %to %words(&cvars);
            if not index(%scan(&cvars,&j,%str( )),"X")
              then %scan(&cvars,&j,%str( ))=" ";
          %end;
        run;

        %missvars(_dif);
        run;
        %put >>>>>>>>>>> all-missing variables = &_miss_;

        %if %words(&_miss_) EQ 0 %then %let match=;
        %else %let match=%match(&cvars,&_miss_);

        %if "&match" EQ "&cvars" %then %goto skip;

        data _result2;
          merge _dif(in=_dif keep=&sortedby) _result(keep=&sortedby _type_ &cvars);
          by &sortedby;
          if _dif;
          %if %length(&match) %then %do;
            drop &match;
          %end;
        run;

        proc print data=_result2 label noobs;
          id &sortedby;
        run;

        %skip:
  %end;

      %end;
      %else %do;
        %put;
        %put &err: (complibs) No sort variable list determined for dataset &ds;
        %put;
      %end;

    %end;

  %end;


  *- Tidy up temporary datasets now we are finished -;
  proc datasets nolist;
    delete _base _comp;
  run;
  quit;


  %*- Clear librefs if these were assigned internally -;
  %if "&fnew" EQ "Y" %then %do;
    libname &refnew clear;
  %end;
  %if "&fold" EQ "Y" %then %do;
    libname &refold clear;
  %end;


%mend complibs;
