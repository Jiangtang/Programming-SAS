options nomprint nomlogic nosymbolgen nonotes;

%macro search(librf,string);  /* parameters are unquoted, libref name, search string */
  %let librf = %upcase(&librf);

  proc sql noprint;
    select left(put(count(*),8.)) into :numds
    from dictionary.tables
    where libname="&librf";

    select memname into :ds1 - :ds&numds
    from dictionary.tables
    where libname="&librf";

  %do i=1 %to &numds;
    proc sql noprint;
    select left(put(count(*),8.)) into :numvars
    from dictionary.columns
    where libname="&librf" and memname="&&ds&i" and type='char';

    /* create list of variable names and store in a macro variable */

    %if &numvars > 0 %then %do;
      select name into :var1 - :var&numvars 
      from dictionary.columns
      where libname="&librf" and memname="&&ds&i" and type='char';
      quit;

      data _null_;
        set &librf..&&ds&i;
          %do j=1 %to &numvars;
            if find(&&var&j,"&string",'i')  then
            put "String &string found in dataset &librf..&&ds&i for variable &&var&j";
          %end;
        run;
    %end;
  %end; 

*options notes;

%mend search;

