/*
Sample 33078: 
How to find a specific value in any variable 
in any SAS data set in a library

http://support.sas.com/kb/33/078.html

few modification by Jiangtang Hu@20120221

;*/

options nomprint nomlogic nosymbolgen nonotes;

/* parameters are unquoted, libref name, search string */

%macro grep(librf,string) ;  
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
            if &&var&j = "&string" then
            put "String &string found in dataset &librf..&&ds&i for variable &&var&j";
          %end;
        run;
    %end;
  %end; 

options notes;

%mend;

%*grep(sashelp,John);
%grep(ct,EGORRES);
