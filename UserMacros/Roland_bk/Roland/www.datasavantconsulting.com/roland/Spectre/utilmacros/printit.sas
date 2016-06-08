/*<pre><b>
/ Program   : printit.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 21-Aug-2014
/ Purpose   : To "proc report" a dataset using "ods pdf" style where for pre-
/             sas v9.4 datasets they contain the special variables "holder",
/             "_columns", "_title(n)" and "_footnote(n)" where the labels of
/             these variables contain "proc report" layout information as
/             described in this macro or for sas v9.4 datasets or later they
/             contain the "holder" variable and extended dataset attribute
/             values with identifiers "columns", "title(x)" and "footnote(x)"
/             where the values of these extended dataset attributes contain
/             "proc report" layout information.
/ SubMacros : %hasvars %varlabel %varlist
/ Notes     : This macro is the second implementation and will be subject to
/             future changes.
/
/             This macro prints a dataset following a special convention as
/             described in this macro header "purpose" section. The aim of this
/             macro is to enable the full automation of "proc report" reports by
/             using information in variable labels (for pre sas v9.4) or
/             extended dataset attribute values (for sas v9.4 or later).
/
/             The variable "holder" must exist in the dataset and have the same
/             value for all observations. It is used to suppress the lowest
/             "Table" level of the PDF bookmarks.
/
/             The extended attribute identified by "columns" or the label of the
/             "_columns" variable should contain a list of variables (except for
/             the "holder" variable) with "proc report" variable use information
/             attached as follows:
/
/                 vara*on varb*o varc*on vard vare varf
/
/             ...where "*on" signifies "order order=internal noprint" and
/             "*o" signifies "order order=internal" and a lack of formatting
/             information signifies "display". If this information is missing
/             then a list of variables will be generated with no attached 
/             formatting information such that they are all treated as "display"
/             variables. Note that the "holder" variable should not be included
/             in the variable list, nor any variables whose labels contain title
/             and footnote information.
/
/             The titles to use, if any, will be assumed to be contained in the
/             labels of the variables _title1, _title2 etc. for pre-sas v9.4
/             or the extended attribute values for "title1", "title2" etc. for
/             sas v9.4 and later. You can define these as needed.
/
/             The footnotes to use, if any, will be assumed to be contained in
/             the labels of the variables _footnote1, _footnote2 etc. for pre-
/             sas v9.4 or the extended attribute values for "footnote1",
/             "footnote2" etc. for sas v9.4 and later. You can define these as
/             needed.
/
/             Note that no column widths can be defined because this is for an
/             "ods pdf" style report. Also, no column labels can be defined so
/             that your variable labels will become your column labels so you
/             have to ensure you give them labels you want to see in the report.
/
/             If you use all ten footnote positions and ask for a final footnote
/             defined to lastfoot= then a warning message will be issued and
/             this final footnote will not be displayed.
/
/             In this early version of the macro, proclabel is set to a space
/             and the contents value is set to the first title value. This may
/             change in the future to allow more flexibility.
/
/ Usage     : options mrecall mprint notes nodate nonumber
/               sasautos=("Z:\Users\rashleig\utilmacros" SASAUTOS);
/             title1;
/             footnote1;
/
/             ods escapechar="^";
/             ods pdf file="Z:\Users\rashleig\temp\mypdf.pdf"
/                 style=BarrettsBlue;
/             ods listing close;
/
/             *- pre sas v9.4 test dataset -;
/             data class;
/               retain holder "1" _title1 _title4 _title6 
/               _footnote3 _footnote7 _columns "X";
/               set sashelp.class;
/               label _title1="title one"
/                     _title4="title four"
/                     _footnote3="footnote three"
/                     _footnote7="footnote seven"
/                     _columns="name*o age"
/                     ;
/             run;
/
/             *- sas v9.4 and later test dataset -;
/             data class;
/               retain holder "X";
/               set sashelp.class;
/             run;
/             proc datasets lib=work nolist;  
/               modify class;
/               xattr set ds  
/                 title1='title one'
/                 title4='title four'
/                 footnote3='footnote three'
/                 footnote7='footnote seven'
/                 columns='name*o age'
/                 ;  
/             quit;
/
/             %printit(class,
/              lastfoot="last footnote -- page ^{thispage} / ^{lastpage}");
/
/             ods pdf close;
/             ods listing;
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) (no modifiers) Input dataset to print using "proc
/                   report", "ods pdf" style.
/ lastfoot=         (optional) Definition of final footnote to show at the 
/                   bottom of every page.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  17Aug14         New (v1.0)
/ rrb  19Aug14         Changed "foot" to the full spelling "footnote". Used
/                      "_columns" as the store for columns information, rather
/                      than the label of the "holder" variable and coded in the
/                      logic for accepting extended dataset attributes following
/                      the same naming convention (apart from the starting
/                      underscore) for sas v9.4 and later. Modifiers for the
/                      input dataset are no longer allowed due to the added
/                      complexity of passing on extended dataset attributes to
/                      data step copies (v2.0)
/ rrb  21Aug14         Updated example code in header (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: printit v2.0;

%macro printit(dsin,lastfoot=);

  %local err errflag warn i bit maxfoot maxtitl columns var use title1 savopts
         libname memname treataspre94 post93;

  %let err=ERR%str(OR);
  %let errflag=0;
  %let warn=WAR%str(NING);
  %let title1="";
  %let savopts=%sysfunc(getoption(notes));

  options nonotes;

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (printit) No input dataset specified as first positional parameter;
  %end;

  %if &errflag %then %goto exit;


  %if not %hasvars(&dsin,holder) %then %do;
    %let errflag=1;
    %put &err: (printit) Input dataset &dsin lacks the required variable "holder";
  %end;

  %if &errflag %then %goto exit;


  *- Set up "libname" and "memname" for use in SQL select -;
  %let libname=%upcase(%scan(&dsin,1,.));
  %let memname=%upcase(%scan(&dsin,2,.));
  %if not %length(&memname) %then %do;
    %let memname=&libname;
    %let libname=%upcase(%sysfunc(getoption(user)));
    %if not %length(&libname) %then %let libname=WORK;
  %end;


  *- Set a flag for the sas version number -;
  %let post93=0;
  %if %sysevalf(&sysver GT 9.3) %then %let post93=1;



  *- dummy dataset for SQL "from" syntax restrictions -;
  data _dummy;
    _dummy="_dummy";
  run;



  PROC SQL NOPRINT;


  *- How to treat the input dataset, sas-version wise.   -;
  *- It is assumed to be in a pre-sas v9.4 format unless -;
  *- one of the identifying extended dataset attributes  -;
  *- is detected as existing, assuming we are currently  -;
  *- running sas v9.4 or higher. -;

  %let treataspre94=1;
  %if &post93 %then %do;
    select 0 into :treataspre94 separated by ' ' from _dummy
    where exists (select 1 from dictionary.xattrs
    where libname="&libname" and memname="&memname"
    and (upcase(xattr) like "TITLE%" 
      or upcase(xattr) like "FOOTNOTE%" 
      or upcase(xattr) like "COLUMNS"));
  %end;


  %if not &treataspre94 %then %do;
    CREATE table _printit as
    select upcase(xattr) as xattr, xvalue 
    from dictionary.xattrs
    where libname="&libname" and memname="&memname";
  %end;


  *- Get the list of variables to print -;
  %let columns=;
  %if &treataspre94 %then %do;
    %if %hasvars(&dsin,_columns) %then %let columns=%varlabel(&dsin,_columns);
  %end;
  %else %do;
    SELECT xvalue into :columns separated by ' '
    from _printit
    where xattr like "COLUMNS";
  %end;
  


  *- If nothing in the list of columns then generate the list -;
  *- of variables (but do not include the "holder" variable). -;
  %if not %length(&columns) %then
    %let columns=%sysfunc(
    prxchange(s/_title[^\s]+ +|_footnote[^\s]+ +|_columns +|holder +//i,-1,
     %varlist(&dsin)%str( )));


  *- Uppercase all the variables and their print instructions -;
  %let columns=%upcase(&columns);


  *- Find out the last valid footnote number -;
  %let maxfoot=0;
  %do i=10 %to 1 %by -1;
    %let bit=;
    %if &treataspre94 %then %do;
      %if %hasvars(&dsin,_footnote&i) %then
        %let bit=%varlabel(&dsin,_footnote&i);
    %end;
    %else %do;
      select xvalue into :bit separated by ' '
      from _printit
      where xattr like "FOOTNOTE&i";
    %end;
    %if %length(&bit) %then %do;
      %let maxfoot=&i;
      %goto exitfoot;
    %end;
  %end;
  %exitfoot:


  *- Find out the last valid title number -;
  %let maxtitl=0;
  %do i=10 %to 1 %by -1;
    %let bit=;
    %if &treataspre94 %then %do;
      %if %hasvars(&dsin,_title&i) %then
        %let bit=%varlabel(&dsin,_title&i);
    %end;
    %else %do;
      select xvalue into :bit separated by ' '
      from _printit
      where xattr like "TITLE&i";
    %end;
    %if %length(&bit) %then %do;
      %let maxtitl=&i;
      %goto exittitl;
    %end;
  %end;
  %exittitl:


  *- Cancel any existing titles or footnotes -;
  title1;
  footnote1;


  *- Generate the titles -;
  %do i=1 %to &maxtitl;
    %if &treataspre94 %then %do;
      %if %hasvars(&dsin,_title&i) %then %do;
        %if %length(%varlabel(&dsin,_title&i)) %then %do;
          title&i "%varlabel(&dsin,_title&i)";
          %if &i = 1 %then %let title1="%varlabel(&dsin,_title&i)";
        %end;
      %end;
    %end;
    %else %do;
      %let bit=;
      select xvalue into :bit separated by ' '
      from _printit
      where xattr like "TITLE&i";
      %if %length(&bit) %then %do;
        title&i "&bit";
        %if &i = 1 %then %let title1="&bit";
      %end;
    %end;
  %end;


  *- Generate the footnotes -;
  %do i=1 %to &maxfoot;
    %if &treataspre94 %then %do;
      %if %hasvars(&dsin,_footnote&i) %then %do;
        %if %length(%varlabel(&dsin,_footnote&i)) %then %do;
          footnote&i "%varlabel(&dsin,_footnote&i)";
        %end;
      %end;
    %end;
    %else %do;
      %let bit=;
      select xvalue into :bit separated by ' '
      from _printit
      where xattr like "FOOTNOTE&i";
      %if %length(&bit) %then %do;
        footnote&i "&bit";
      %end;
    %end;
  %end;


  QUIT;


  *- Generate the last footnote (if specified) -;
  %if %length(&lastfoot) %then %do;
    %if &maxfoot GT 0 %then %do;
      %if &maxfoot GT 9 %then %do;
        %put &warn: (printit) No room for last footnote so not shown;
      %end;
      %else %if &maxfoot EQ 9 %then %do;
        footnote10 &lastfoot;
      %end;
      %else %do;
        footnote%eval(&maxfoot+2) &lastfoot;
      %end;
    %end;
    %else %do;
      footnote1 &lastfoot;
    %end;
  %end;


  *- Nullify the procedure label -;
  ods proclabel " ";


  *- Now do the "proc report", putting the first title in the contents -;
  proc report nowd missing data=&dsin contents=&title1;
    *- list the variables with the print instructions stripped off -;
    column holder %sysfunc(prxchange(s/\*[^\s]+ +?/ /,-1,&columns%str( )));
    define holder / noprint order;
    break before holder / page contents='';
    *- Loop through the variables to create their "define" statements -;
    %let i=1;
    %let var=%scan(%scan(&columns,&i,%str( )),1,*);
    %let use=%scan(%scan(&columns,&i,%str( )),2,*);
    %do %while(%length(&var));
      define &var /
      %if &use EQ O %then %do;
        order order=internal
      %end;
      %else %if &use EQ ON %then %do;
        order order=internal noprint
      %end;
      %else %do;
        display
      %end;
      ;
      %let i=%eval(&i+1);
      %let var=%scan(%scan(&columns,&i,%str( )),1,*);
      %let use=%scan(%scan(&columns,&i,%str( )),2,*);
    %end;
  run;


  *- Cancel the titles and footnotes now we are done printing -;
  title1;
  footnote1;


  *- Tidy up -;
  proc datasets nolist;
    delete _dummy
    %if not &treataspre94 %then %do;
       _printit
    %end;
    ;
  quit;


  %goto skip;
  %exit: %put &err: (printit) Leaving macro due to problem(s) listed;
  %skip:

  options &savopts;

%mend printit;
