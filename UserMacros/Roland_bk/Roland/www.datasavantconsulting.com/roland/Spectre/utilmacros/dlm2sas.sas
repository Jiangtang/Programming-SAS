/*<pre><b>
/ Program   : dlm2sas.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 07-Jul-2014
/ Purpose   : To read in a delimited flat file and convert it to a sas dataset
/             with all variables character by default.
/ SubMacros : %varlist
/ Notes     : This macro is designed to force fields to be character when a flat
/             file is converted to a SAS dataset to avoid problems where values
/             can start as numeric and then turn into alphanumeric too late to
/             correct the variable type. All the fields will be character and
/             you must either run a following data step to fix lengths and types
/             or you can define a dataset to the dsfixvars= parameter to fix
/             variables in the output dataset.
/
/             This will only work on SIMPLE files where the delimiter is never
/             included in a valid text field so you should not use this on comma
/             delimited files as a comma might be part of a valid text string.
/
/             All the character fields are the number of bytes long that is
/             specified to colw=. If you want to shorten these fields to more
/             suitable lengths then this must be done in a subsequent data step
/             or you can define a dataset to the dsfixvars= parameter.
/
/             The %optlength macro might be useful for finding out the optimum
/             length of character fields.
/
/             If you use getnames=yes (default) then any text found in the first
/             line is converted if needed to form valid variable names.
/
/ Usage     : data fix;
/               length name informat $ 32 type $ 4;
/               name='studyid';length=30;type='char';output;
/               name='ptm';length=8;type='num';informat='??time6.';output;
/             run;
/
/             %dlm2sas(C:\Users\rashleig\Downloads\xxxxx.txt,test,
/             dsfixvars=fix);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ infile            (pos) (unquoted) Full path name of input file. Enclose in
/                   %nrstr() if the path name contains spaces, "&" or "%".
/ dsout             (pos) Output dataset name (defaults to _dlm2sas) (modifiers
/                   are allowed)
/ delimiter="09"x   Delimiter character (defaults to horizontal tab)
/ colw=256          Number of bytes to allocate to each column
/ getnames=yes      By default, use the first row as the source of the column
/                   names otherwise columns are named C1, C2 etc..
/ termstr=CRLF      Terminating characters for each line. CRLF is for Windows
/                   platforms where the file is a pure ascii file. LF is for
/                   Unix platforms or utf-8 encoded files. You can use the
/                   %termstr macro to help you decide this value.
/ dsfixvars=        Dataset containing the fields "name" (char), "type" (char4),
/                   "length" (num) and "informat" (char) for correcting the
/                   output variable characteristics in the output dataset if it
/                   finds a match on variable name. Note that the "informat"
/                   field in this dataset will be APPLIED to transform the
/                   variable and not be used to give the output dataset variable
/                   that informat as an attribute.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  02Jul11         Add checking of input parameters (v1.1)
/ rrb  21Mar13  rrb001 Algorithm changed for deriving variable name from string
/                      containing invalid characters for variable naming so that
/                      multiple adjacent invalid characters are replaced by a
/                      single underscore instead of multiple underscores as
/                      used to be the case (v1.2)
/ rrb  29Apr13         %nrbquote(), %superq() and %nrstr() used to mask file
/                      name and file path must be unquoted (v1.3)
/ rrb  02May13         termstr=CRLF parameter added (v1.4)
/ rrb  07Jul14         dsfixvars= processing added, macro purpose updated and
/                      header info improved (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dlm2sas v2.0;

%macro dlm2sas(infile
              ,dsout
              ,delimiter="09"x
              ,colw=256
              ,getnames=yes
              ,termstr=CRLF
              ,dsfixvars=
               );

  %local maxcol colnames err varlist savopts;
  %let err=ERR%str(OR);

  %if not %length(&infile) %then %do;
    %put &err: (dlm2sas) No file path specified;
    %goto exit;
  %end;
  %else %do;
    %if not %sysfunc(fileexist(%nrbquote(&infile))) %then %do;
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
    infile "%nrstr(%superq(infile))" pad lrecl=32767 termstr=&termstr;
    input;
    maxcol=countc(_infile_,&delimiter)+1;
    call symput('maxcol',put(maxcol,best.));
    %if &getnames EQ Y %then %do;
      i=1;
      name=trim(scan(_infile_,i,&delimiter));
      do while(name ne "");
        *- make sure name syntax is valid -;
        *----- rrb001: the line directly below is the old method no longer used -----;
        ****name=upcase(translate(trim(name),"____________________"," '&%+()@/\#?=$!.,:-"));
        name=upcase(prxchange('s§[^a-zA-Z0-9]+§_§',-1,trim(name)));
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

  data 
    %if not %length(&dsfixvars) %then %do;
      &dsout
    %end;
    %else %do;
      _dlm2
    %end;
    ;
    informat &colnames $&colw.. ;
    format &colnames $&colw.. ;
    infile "%nrstr(%superq(infile))" delimiter=&delimiter 
           MISSOVER DSD lrecl=32767 termstr=&termstr
    %if &getnames EQ Y %then %do;
      firstobs=2 
    %end;
    ;
    input &colnames;
  run;

  %if %length(&dsfixvars) %then %do;

    *- store the option setting for the variable length warning -;
    %let savopts=%sysfunc(getoption(varlenchk,keyword));

    options varlenchk=nowarn;


    *- create a list of variables for a final KEEP statement -;
    %let varlist=%varlist(_dlm2);


    *- get the contents of the temporary dataset -;
    proc contents data=_dlm2 noprint out=_dlm2cont(keep=name type length);
    run;


    *- standardise the variable characteristics -;
    data _dlm2cont;
      length type $ 1;
      set _dlm2cont(rename=(type=old_type));
      name=upcase(name);
      if old_type=1 then type='N';
      else type='C';
      DROP old_type;
    run;
    proc sort data=_dlm2cont;
      by name type;
    run;


    *- standardise the variable characteristics -;
    data _dlm2fix;
      length type $ 1;
      set &dsfixvars;
      type=upcase(type);
      name=upcase(name);
      KEEP name type length informat;
    run;
    proc sort data=_dlm2fix;
      by name type;
    run;


    *- merge the new variable information on top -;
    data _dlm2cont;
      merge _dlm2cont(in=_cont) _dlm2fix(rename=(type=new_type length=new_length));
      by name;
      if _cont;
      if (new_type NE type) or (new_length NE length) ;
    run;


    *- set up fileref for generated code -;
    filename _dlmcode TEMP;


    *- generate the code to reset lengths, rename variables and convert them -;
    data _null_;
      length str $ 120;
      file _dlmcode;
      *- generate the LENGTH statement -;
      put 'LENGTH ';
      do ptr=1 to nobs;
        set _dlm2cont point=ptr nobs=nobs;
        str=trim(name);
        if new_type EQ 'N' then str=str;
        else if new_type EQ 'C'  then str=trim(str)||" $";
        else if type EQ 'C' then str=trim(str)||" $";
        if new_length NE .  then str=trim(str)||" "||strip(put(new_length,4.));
        else if length NE . then str=trim(str)||" "||strip(put(length,4.));
        put str;
      end;
      put ';';
      *- Generate the SET statement with the renames   -;
      *- (do not worry if there are no renames because -;
      *- SAS wont complain about empty declarations).  -;
      put 'SET _dlm2(rename=(';
      do ptr=1 to nobs;
        set _dlm2cont point=ptr;
        if new_type='N' or informat NE ' ' then do;
          str=trim(name)||'=char_'||name;
          put str;
        end;
      end;
      put '));';
      *- generate the transformation of character to numeric -;
      do ptr=1 to nobs;
        set _dlm2cont point=ptr;
        if new_type='N' or informat NE ' ' then do;
          if new_type='N' and informat=' ' then informat='comma32.';
          str=trim(name)||'=input(char_'||trim(name)||','||trim(informat)||');';
          put str;
        end;
      end;
      stop;
    run;


    *- create the final output dataset keeping only the original variables -;  
    DATA &dsout;
      %include _dlmcode / source;
      KEEP &varlist;
    run;    


    *- clear the generated code fileref -;
    filename _dlmcode CLEAR;


    *- tidy up -;
    proc datasets nolist memtype=data;
      delete _dlm2 _dlm2cont _dlm2fix;
    quit;


    *- reset variable length warning option -;
    options &savopts;  

  %end;

  %goto skip;
  %exit: %put &err: (dlm2sas) Leaving macro due to problem(s) listed;
  %skip:

%mend dlm2sas;
