/*<pre><b>
/ Program   : dlm2sas.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 02-Jul-2011
/ Purpose   : To read in a delimited flat file and convert it to a sas dataset
/ SubMacros : none
/ Notes     : This will only work on SIMPLE files where the delimiter is never
/             included in a valid text field so you should not use this on comma
/             delimited files as a comma might be part of a valid text string.
/             All the columns in the output dataset will be CHARACTER so you
/             should convert the fields you want to numeric in a subsequent data
/             step. All the character fields are the number of bytes long that
/             is specified to colw=. If you want to shorten these fields to more
/             suitable lengths then this must be done in a subsequent data step.
/             The %optlength macro might be useful for this. If you use
/             getnames=yes (default) then any text found is converted to make it
/             a valid syntax uppercase variable name.
/ Usage     : %dlm2sas(C:\Mylib\myfile.csv,mydset)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ infile            (pos) (quoted or unquoted) Full path name of input file
/ dsout             (pos) Output dataset name (defaults to _dlm2sas) (modifiers
/                   are allowed)
/ delimiter="09"x   Delimiter character (defaults to horizontal tab)
/ colw=256          Number of bytes to allocate to each column
/ getnames=yes      By default, use the first row as the source of the column
/                   names otherwise columns are named C1, C2 etc..
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  02Jul11         Add checking of input parameters (v1.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dlm2sas v1.1;

%macro dlm2sas(infile,
                dsout,
            delimiter="09"x,
                 colw=256,
             getnames=yes
               );

  %local maxcol colnames err;
  %let err=ERR%str(OR);

  %if not %length(&infile) %then %do;
    %put &err: (dlm2sas) No file path specified;
    %goto exit;
  %end;
  %else %do;
    %let infile=%sysfunc(dequote(&infile));
    %if not %sysfunc(fileexist(&infile)) %then %do;
      %put &err: (dlm2sas) File "&infile" can not be found;
      %goto exit;
    %end;
  %end;

  %if not %length(&dsout) %then %let dsout=_dlm2sas;
  %if not %length(&colw) %then %let colw=256;
  %if not %length(&delimiter) %then %let delimiter="09"x;

  %if not %length(&getnames) %then %let getnames=yes;
  %let getnames=%upcase(%substr(&getnames,1,1));

  data _null_;
    length name $ 32 colnames $ 1024;
    infile "&infile" lrecl=32767 ;
    input;
    maxcol=countc(_infile_,&delimiter)+1;
    call symput('maxcol',put(maxcol,best.));
    %if &getnames EQ Y %then %do;
      i=1;
      name=trim(scan(_infile_,i,&delimiter));
      do while(name ne "");
        *- make sure name syntax is valid -;
        name=upcase(translate(trim(name),"____________________"," '&%+()@/\#?=$!.,:-"));
        colnames=trim(colnames)||" "||name;
        i=i+1;
        name=trim(scan(_infile_,i,&delimiter));
      end;
    %end;
    %else %do;
      name="";
      do i=1 to maxcol;
        colnames=trim(colnames)||" C"||compress(put(i,3.));
      end;
    %end;
    call symput('colnames',trim(colnames));
    stop;
  run;

  data &dsout;
    informat &colnames $&colw.. ;
    format &colnames $&colw.. ;
    infile "&infile" delimiter=&delimiter MISSOVER DSD lrecl=32767 
    %if &getnames EQ Y %then %do;
      firstobs=2 
    %end;
    ;
    input &colnames;
  run;

  %goto skip;
  %exit: %put &err: (dlm2sas) Leaving macro due to problem(s) listed;
  %skip:

%mend dlm2sas;
