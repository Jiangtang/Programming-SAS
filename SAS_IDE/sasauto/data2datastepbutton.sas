/*
http://blogs.sas.com/content/sastraining/2016/03/11/jedi-sas-tricks-data-to-data-step-macro/

http://blogs.sas.com/content/sastraining/2016/05/01/jedi-sas-tricks-make-button-base-sas/
*/
%macro Data2DataStepButton(dsn,lib,file,obs);
   %local varlist msgtype ;
   %window Data2DataStep columns=80 rows=20
   # 3 @ 6 'Libref:                 ' lib 41 attr=underline 
   # 5 @ 6 'Data Set:               ' dsn 41 attr=underline 
   # 7 @ 6 'Program file name:      ' file 50 attr=underline
   # 9 @ 6 'Number of Obervations:  ' obs  3 attr=underline
   #12 @ 6  'Press ENTER to continue';

%display Data2DataStep;

   %if %superq(obs)= %then %let obs=MAX;
   %let msgtype=NOTE;
   %if %superq(dsn)= %then %do;
      %let msgtype=ERROR;
      %put &msgtype: You must specify a data set name;
      %put;
      %goto syntax;
   %end;
   %let dsn=%qupcase(%superq(dsn));
   %if %superq(dsn)=!HELP %then %do;
   %syntax:
      %put &msgtype: &SYSMACRONAME macro help document:;
      %put &msgtype- Purpose: Converts a data set to a SAS DATA step.;
      %put &msgtype- Syntax: %nrstr(%%)&SYSMACRONAME(dsn<,lib,file,obs>);
      %put &msgtype- dsn:  Name of the dataset to be converted. Required.;
      %put &msgtype- lib:  LIBREF where the dataset resides. Optional.;
      %put &msgtype- file: Fully qulaified filename for the DATA step produced. Optional.;
      %put &msgtype-       Default is %nrstr(create_&lib._&dsn._data.sas) in the SAS default directory.;
      %put &msgtype- obs:  Max observations to include the created dataset. Optional.;
      %put &msgtype-       Default is MAX (all observations);
      %put;
      %put NOTE:   &SYSMACRONAME cannot be used in-line - it generates code.;
      %put NOTE-   Use !HELP to print these notes.;
      %return;
   %end; 

   %if %superq(lib)= %then %do;
       %let lib=%qscan(%superq(dsn),1,.);
       %if %superq(lib) = %superq(dsn) %then %let lib=WORK;
       %else %let dsn=%qscan(&dsn,2,.);
   %end;
   %let lib=%qupcase(%superq(lib));
   %let dsn=%qupcase(%superq(dsn));
   %if %sysfunc(exist(&lib..&dsn)) ne 1 %then %do;
      %put ERROR: (&SYSMACRONAME) - Dataset &lib..&dsn does not exist.;
      %let msgtype=NOTE;
      %GoTo syntax;
   %end;

   %if %superq(file)= %then %do;
      %let file=create_&lib._&dsn._data.sas;
      %if %symexist(USERDIR) %then %let file=&userdir/&file;
   %end;

   %if %symexist(USERDIR) %then %do;
      %if %qscan(%superq(file),-1,/\)=%superq(file) %then
         %let file=&userdir/&file;
   %end;

   proc sql noprint;
   select Name
         into :varlist separated by ' '
      from dictionary.columns
      where libname="&lib"
        and memname="&dsn"
   ;
   select case type
             when 'num' then 
                case 
                   when missing(format) then cats(Name,':32.')
                   else cats(Name,':',format)
                end 
             else cats(Name,':$',length,'.')
          end
         into :inputlist separated by ' '
      from dictionary.columns
      where libname="&lib"
        and memname="&dsn"
   ;
   quit;

   data _null_;
      file "&file" dsd;
      if _n_ =1 then do;
         put "data &lib..&dsn;";
         put @3 "infile datalines dsd truncover;";
         put @3 "input %superq(inputlist);";
         put "datalines4;";
      end;
      set &lib..&dsn(obs=&obs) end=last; 
      put &varlist @;
      if last then do;
         put;
         put ';;;;';
      end;
      else put;
   run;
%mend;
