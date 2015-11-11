/** The %transpose macro
  *
  * This program performs transpositions of SAS datasets very similar to those that
  * can be achieved with PROC TRANSPOSE, but in such a manner that is easier to use
  * when performing complex transpositions and runs significantly faster
  *
  * AUTHORS: Arthur Tabachneck, Xia Ke Shan, Robert Virgile and Joe Whitehurst
  * CREATED: January 20, 2013
  * MODIFIED: September 4, 2014

  Parameter Descriptions:

  *libname_in* the parameter to which you can assign the name of the SAS library that
  contains the dataset you want to transpose. If left null, and the data parameter is
  only assigned a one-level filename, the macro will set this parameter to equal WORK

  *libname_out* the parameter to which you can assign the name of the SAS library
  where you want the transposed file written. If left null, and the out parameter only
  has a one-level filename assigned, the macro will set this parameter to equal WORK

  *data* the parameter to which you would assign the name of the file that you want
  to transpose.  Like with PROC TRANSPOSE, you can use either a one or two-level
  filename.  If you assign a two-level file name, the first level will take precedence
  over the value set in the libname_in parameter.  If you assign a one-level
  filename, the libname in the libname_in parameter will be used

  *out* the parameter to which you would assign the name of the transposed file that
  you want the macro to create.  Like with PROC TRANSPOSE, you can use either a one
  or two-level filename.  If you use assign a two-level file name, the first level
  will take precedence over the value set in the libname_out parameter.  If you use a
  one-level filename, the libname in the libname_out parameter will be used

  *by* the parameter to which you would assign the name of the data’s by variable
  or variables.  The by parameter is identical to the by statement used in PROC
  TRANSPOSE, namely the identification of the variable that the macro will use to
  form by groups, however one or more by variables must be specified.  By groups
  define the record level of the resulting transposed file

  *prefix* the parameter to which you would assign a string that you want each
  transposed variable to begin with

  *var* the parameter to which you would assign the name or names of the variables
  that you want the macro to transpose.  You can assign any combination of variable
  names or variable list(s) that you could assign to PROC TRANSPOSE’s var statement.
  If left null, all variables, all numeric variables, or all character variables
  (other than by, id and copy variables) will be assigned, dependent upon the value
  assigned to the autovars parameter

  *autovars* the parameter to which you would assign the types of variables you want
  automatically assigned to the var parameter in the event that the var parameter has
  a null value.  Possible values are: NUM, CHAR or ALL.  If left null, the macro code
  will set this parameter to equal NUM

  *id* the parameter to which you would assign the variable whose values you want
  concatenated with the var variable(s) selected.  Only one variable can be assigned
  
  *descendingid* the parameter that defines whether id values should be output in
  descending order. Possible values are YES or NO. If left null, the macro code will
  set this parameter to equal NO and id values will be output in ascending order

  *var_first* the parameter that defines whether var names should precede id values in
  the concatenated variable names resulting from a transposition. Possible values are
  YES or NO.  Concatenated variables names will be constructed as follows:
  prefix+var or id+delimiter+var or id.  If left null, the macro code will set this
  parameter to equal YES

  *format* the parameter to which you would assign the format you want applied
  to the id variable in the event you don't want the variable’s actual format
  to be applied. If left null, and the variable doesn't have a format assigned,
  the macro code will create a format based on the variable's type and length

  *delimiter* the parameter to which you would assign the string you want
  assigned between the id values and var variable names in the variable name
  that will be assigned to the transposed variables the macro will create

  *copy* the parameter to which you would assign the name or names of any
  variables that you want the macro to copy rather than transpose
  
  *drop* the parameter to which you would assign the name(s)  of any variables
  you want dropped from the output.  Since only &by, &copy and transposed variables
  are kept, this parameter would only be used if you want to drop one or more of the
  &by variables

  *sort* the parameter to which you would indicate whether the input dataset
  must first be sorted before the data is transposed.  Possible values are:
  YES or NO. If left null, the macro code will set this parameter to equal NO

  *sort_options* while the noequals option will be used for all sorts, you would use
  this parameter to specify any additional options you want used (e.g., presorted,
  force and/or tagsort

  *use_varname* the parameter you would use if you don't want the var names
  to be included in the transposed variable names.  Possible values are: YES or NO.
  If left null, the macro code will set this parameter to equal YES

  *preloadfmt* If you want to predefine all possible id variable values, and the
  order in which those values will be assigned to the transposed variables, you can
  use this parameter to assign a one or two-level filename for a file you want the
  macro to use.  The file must contain a variable that has the same name as the data
  file's id variable, and a 2nd variable called 'order' that will reflect the desired
  order. The file must have one record for every id value the macro will find in the
  data, although it can also contain id values that aren't present in the data.
  Regarding the order variable, the value 1 must be assigned to the value you want
  furthest left, increasing by 1 for each remaining value, and the furthest right
  variable must be equal to the total number of id levels. If a two-level file name
  is specified, the first level will take precedence over the value set in the
  libname_in parameter. If a one-level filename is assigned, the libname in the
  libname_in parameter will be used (or 'work' if the libname_in parameter is null)

  Example:
  data order;
    input date date9. order;
    cards;
  31mar2013 1
  30jun2013 2
  30sep2013 3
  31dec2013 4
  ;

  *guessingrows* the parameter you would use to specify the maximum number of rows
  that will be read to determine the output ordering of the id variable’s values.
  If left null, the macro will set this parameter high enough to read all records

  *newid* the parameter you would use to specify the name you want to assign to a
  new variable that will be created in the event that you don't specify an id
  variable.  If not declared, this parameter will be set to equal 'row'

*/

%macro transpose(libname_in=,
                 libname_out=,
                 data=,
                 out=,
                 by=,
                 prefix=,
                 var=,
                 autovars=,
                 id=,
                 descendingid=,
                 var_first=,
                 format=,
                 delimiter=,
                 copy=,
                 drop=,
                 sort=,
                 sort_options=,
                 use_varname=,
                 preloadfmt=,
                 guessingrows=,
                 newid=);

/*Check whether the data and out parameters contain one or two-level filenames*/
  %let lp=%sysfunc(findc(%superq(data),%str(%()));
  %if &lp. %then %do;
    %let rp=%sysfunc(findc(%superq(data),%str(%)),b));
    %let dsoptions=%qsysfunc(substrn(%nrstr(%superq(data)),&lp+1,&rp-&lp-1));
    %let data=%sysfunc(substrn(%nrstr(%superq(data)),1,%eval(&lp-1)));
  %end;
  %else %let dsoptions=;
  %if %sysfunc(countw(&data.)) eq 2 %then %do;
    %let libname_in=%scan(&data.,1);
    %let data=%scan(&data.,2);
  %end;
  %else %if %length(&libname_in.) eq 0 %then %do;
    %let libname_in=work;
  %end;

  %if %sysfunc(countw(&out.)) eq 2 %then %do;
    %let libname_out=%scan(&out.,1);
    %let out=%scan(&out.,2);
  %end;
  %else %if %length(&libname_out.) eq 0 %then %do;
    %let libname_out=work;
  %end;

  %if %length(&newid.) eq 0 %then %do;
    %let newid=row;
  %end;

  /*obtain last by variable*/
  %if %length(&by.) gt 0 %then %do;
    %let lastby=%scan(&by.,-1);
  %end;
  %else %do;
    %let lastby=;
  %end;

/*Create macro variable to contain a list of variables to be copied*/
 %let to_copy=;
  %if %length(&copy.) gt 0 %then %do;
    data t_e_m_p;
      set &libname_in..&data. (obs=1 keep=&copy.);
    run;

    proc sql noprint;
      select name
        into :to_copy separated by " "
          from dictionary.columns
            where libname="WORK" and
                  memname="T_E_M_P"
        ;
      quit;
  %end;

/*Populate var parameter in the event it has a null value*/
  %if %length(&var.) eq 0 %then %do;
    data t_e_m_p;
      set &libname_in..&data. (obs=1 drop=&by. &id. &copy.);
    run;

    proc sql noprint;
      select name
        into :var separated by " "
          from dictionary.columns
            where libname="WORK" and
                  memname="T_E_M_P"
        %if %sysfunc(upcase("&autovars.")) eq "CHAR" %then %do;
                  and type="char"
        %end;
        %else %if %sysfunc(upcase("&autovars.")) ne "ALL" %then %do;
                  and type="num"
        %end;
        ;
      quit;
  %end;
  
/*Initialize macro variables*/
  %let vars_char=;
  %let varlist_char=;
  %let vars_num=;
  %let varlist_num=;
  %let formats_char=;
  %let format_char=;
  %let formats_num=;
  %let format_num=;

/*Create file t_e_m_p to contain one record with all var variables*/
  data t_e_m_p;
    set &libname_in..&data. (obs=1 keep=&var.);
  run;

/*Create macro variables containing untransposed var names and formats*/
  proc sql noprint;
    select name, case
                   when missing(format) then " $"||strip(put(length,5.))||'.'
                   else strip(format)
                 end
      into :vars_char separated by " ",
           :formats_char separated by "~"
        from dictionary.columns
          where libname="WORK" and
                memname="T_E_M_P" and
                type="char"
    ;
    select name, case
                   when missing(format) then "best12."
                   else strip(format)
                 end
      into :vars_num separated by " ",
           :formats_num separated by "~"
        from dictionary.columns
          where libname="WORK" and
                memname="T_E_M_P" and
                type="num"
    ;
    select name
      into :vars_all separated by " "
        from dictionary.columns
          where libname="WORK" and
                memname="T_E_M_P"
    ;
  quit;

/*If sort parameter has a value of YES, create a sorted temporary data file*/
  %if %sysfunc(upcase("&sort.")) eq "YES" %then %do;
    %let notsorted=;
    proc sort data=&libname_in..&data.
                (
                 keep=&by. &id. &vars_char. &vars_num. &to_copy.
                 &dsoptions.
                ) 
                 out=t_e_m_p &sort_options. noequals;
      by &by.;
    run;
    %let data=t_e_m_p;
    %let libname_in=work;
  %end;
  %else %do;
    %let notsorted=notsorted;
  %end;

  /*if no id parameter is present, create one from &newid.*/
  %if %length(&id.) eq 0 %then %do;
    data t_e_m_p;
      set &libname_in..&data.;
      by &by.;
      if first.&lastby then &newid.=1;
      else &newid+1;
    run;
    %let id=&newid.;
    %let data=t_e_m_p;
    %let libname_in=work;
  %end;

/*Ensure guessingrows parameter contains a value*/
  %if %length(&guessingrows.) eq 0 %then %do;
    %let guessingrows=%sysfunc(constant(EXACTINT));
  %end;

/*Ensure a format is assigned to an id variable*/
  %if %length(&id.) gt 0 %then %do;
    proc sql noprint;
      select type,length,%sysfunc(strip(format))
        into :tr_macro_type, :tr_macro_len, :tr_macro_format
          from dictionary.columns
            where libname="%sysfunc(upcase(&libname_in.))" and
                  memname="%sysfunc(upcase(&data.))" and
                  upcase(name)="%sysfunc(upcase(&id.))"
        ;
    quit;

    %if %length(&format.) eq 0 %then %do;
      %let optsave=%sysfunc(getoption(missing),$quote.);
      options missing=.;
      %if %length(&tr_macro_format.) gt 0 %then %do;
        %let format=&tr_macro_format.;
      %end;
      %else %if "&tr_macro_type." eq "num " %then %do;
        %let format=%sysfunc(catt(best,&tr_macro_len.,%str(.)));
      %end;
      %else %do;
        %let format=%sysfunc(catt($,&tr_macro_len.,%str(.)));
      %end;
      options missing=&optsave;
    %end;
  %end;

/*Create macro variables containing ordered lists of the requested transposed variable
  names for character (varlist_char) and numeric (varlist_num) var variables */
  %if %length(&preloadfmt.) gt 0 %then %do;
    %if %sysfunc(countw(&preloadfmt.)) eq 1 %then %do;
      %let preloadfmt=&libname_in..&preloadfmt.;
    %end;
  %end;
  %else %do;
    %if %sysfunc(upcase("&sort.")) eq "YES" %then
     %let dsoptions=;
    proc freq data=&libname_in..&data. (obs=&guessingrows. keep=&id. &dsoptions.)
       noprint;
      tables &id./out=_for_format (keep=&id.);
    run;
    %if %sysfunc(upcase("&descendingid.")) eq "YES" %then %do;
      proc sort data=_for_format;
        by descending &id;
      run;
    %end;
    data _for_format;
      set _for_format;
      order=_n_;
    run;
  %end;

 proc sql noprint;
  %do i=1 %to 2;
    %if &i. eq 1 %then %let i_type=char;
    %else %let i_type=num;
    %if %length(&&vars_&i_type.) gt 0 %then %do;
    select distinct
      %do j=1 %to 2;
        %if &j. eq 1 %then %let j_type=;
        %else %let j_type=format;
        %do k=1 %to %sysfunc(countw(&&vars_&i_type.));
         "&j_type. "||cats("&prefix.",
          %if %sysfunc(upcase("&var_first.")) eq "NO" %then %do;
            put(&id.,&format),"&delimiter."
            %if %sysfunc(upcase("&use_varname.")) ne "NO" %then
            ,scan("&&vars_&i_type.",&k.);
          %end;
          %else %do;
            %if %sysfunc(upcase("&use_varname.")) ne "NO" %then
               scan("&&vars_&i_type.",&k.),;
            "&delimiter.",put(&id.,&format)
          %end;
          )
          %if &j. eq 2 %then
            ||" "||cats(scan("&&formats_&i_type.",&k.,"~"),";");
          %if &k. lt %sysfunc(countw(&&vars_&i_type.)) %then ||;
          %else ,;
        %end;
      %end;
      %if "&tr_macro_type." eq "num " %then &id. format=best12.;
        %else &id.;
        ,order
          into :varlist_&i_type. separated by " ",
               :format_&i_type. separated by " ",
               :idlist separated by " ",
               :idorder separated by " "
           %if %length(&preloadfmt.) gt 0 %then from &preloadfmt.;
           %else from _for_format;
               order by order
    ;
      %let num_numlabels=&sqlobs.;
    %end;
  %end;
  quit;

  proc sql noprint;
    select distinct
        %let j_type=;
        %do k=1 %to %sysfunc(countw(&&vars_all.));
      "&j_type. "||cats("&prefix.",
      
          %if %sysfunc(upcase("&var_first.")) eq "NO" %then %do;
          put(&id.,&format),"&delimiter.",
            %if %sysfunc(upcase("&use_varname.")) ne "NO" %then
          scan("&&vars_all.",&k.);
          )
          %end;
          %else %do;
            %if %sysfunc(upcase("&use_varname.")) ne "NO" %then
          scan("&&vars_all.",&k.),;
          "&delimiter.",put(&id.,&format))
          %end;
          %if &k. lt %sysfunc(countw(&&vars_all.)) %then ||;
          %else ,;
        %end;
        order
          into :varlist_all separated by " ",
               :idorder separated by " "
           %if %length(&preloadfmt.) gt 0 %then from &preloadfmt.;
           %else from _for_format;
               order by order
    ;
  quit;

/*Create a format that will be used to assign values to the transposed variables*/
  data _for_format;
    %if %length(&preloadfmt.) gt 0 %then set &preloadfmt. (rename=(&id.=start)); 
    %else set _for_format  (rename=(&id.=start));
    ;
    %if "&tr_macro_type." eq "num " %then retain fmtname "labelfmt" type "N";
    %else retain fmtname "$labelfmt" type "C";
    ;
    label=
     %if %length(&preloadfmt.) eq 0 %then _n_-1;
     %else order-1;
     ;
  run;

  proc format cntlin = _for_format;
  run ;

/*Create and run the datastep that does the transposition*/
  data &libname_out..&out.;
    set &libname_in..&data. (keep=&by. &id.
      %do i=1 %to %sysfunc(countw("&vars_char.")); 
        %scan(&vars_char.,&i.)
      %end;
      %do i=1 %to %sysfunc(countw("&vars_num.")); 
        %scan(&vars_num.,&i.)
      %end;
      %do i=1 %to %sysfunc(countw("&to_copy.")); 
        %scan(&to_copy.,&i.)
      %end;
      &dsoptions.
      );
    by &by. &notsorted.;
    &format_char. &format_num.
  %if %length(&vars_char.) gt 0 %then %do;
    array want_char(*) $
    %do i=1 %to %eval(&num_numlabels.*%sysfunc(countw("&vars_char."))); 
      %scan(&varlist_char.,&i.)
    %end;
    ;
    array have_char(*) $ &vars_char.;
    retain want_char;
    if first.&lastby. then call missing(of want_char(*));
    ___nchar=put(&id.,labelfmt.)*dim(have_char);
    do ___i=1 to dim(have_char);
      want_char(___nchar+___i)=have_char(___i);
    end;
  %end;
  %if %length(&vars_num.) gt 0 %then %do;
    array want_num(*)
    %do i=1 %to %eval(&num_numlabels.*%sysfunc(countw("&vars_num."))); 
      %scan(&varlist_num.,&i.)
    %end;
    ;
    array have_num(*) &vars_num.;
    retain want_num;
    if first.&lastby. then call missing(of want_num(*));
    ___nnum=put(&id.,labelfmt.)*dim(have_num);
    do ___i=1 to dim(have_num);
      want_num(___nnum+___i)=have_num(___i);
    end;
  %end;
    drop &id. ___: &var. &drop.;
    if last.&lastby. then output;
  run;

  data &libname_out..&out.;
    retain &by. &to_copy. &varlist_all.;
    set &libname_out..&out.;
  run;

/*Delete all temporary files*/
  proc delete data=work.t_e_m_p work._for_format;
  run;

%mend transpose;
options NOQUOTELENMAX;

/****************Examples**********************
data have;
  attrib  col1 col2 col3 col4 format=$20.;
  infile datalines;
  input col1 $ col2 $ col3 $ col4 $;
datalines;
A 2014 N 0
A 2013 X 1
A 2012 N 0
A 2011 X 2
B 2013 X 5
B 2012 X 0
B 2011 N 1
B 2010 N 0
;

data order;
  informat col2 $20.;
  format col2 $20.;
  input col2 order;
  cards;
2014   1
2013   2
2011   3
2010   4
;

%transpose(data=have, out=want, by=col1, id=col2, delimiter=_,
 var=col2-col4, preloadfmt=order)

** or **

%transpose(data=have, out=want, by=col1, id=col2, delimiter=_,
 var=col2-col4, descendingid=yes)

data have;
  format idnum 4.;
  input idnum date var1 $;
  informat date date9.;
  format date yymon7.;
  cards;
1 01jan2001 SD
1 01feb2001 EF
1 01mar2001 HK
2 01jan2001 GH
2 01apr2001 MM
2 01may2001 JH
;

%transpose(data=have, out=want, by=idnum, var=var1,
 id=date, format=yymon7., delimiter=_,
 sort=yes, guessingrows=1000)

data have;
  format idnum 4.;
  input idnum date var1 $;
  informat date date9.;
  format date yymon7.;
  cards;
1 01jan2001 GH
1 01apr2001 MM
1 01may2001 JH
2 01jan2001 SD
2 01feb2001 EF
2 01mar2001 HK
;

%transpose(data=have, out=want, by=idnum, var=var1,
 id=date, format=yymon7., delimiter=_,
 sort=yes, guessingrows=1000)

data have (drop=months);
  format idnum 1.;
  informat date date9.;
  format date date9.;
  input date ind1-ind4 ;
  other=2;
  do idnum=1 to 2;
    date="31dec2010"d;
    do months=3 to 12 by 3;
      date=intnx('month',date,3);
      if not(months eq 9 and mod(idnum,2)) then output;
    end;
  end;
  cards;
01dec2010 1 2 3 4
;

%transpose(data=have, out=want, by=idnum, id=date, guessingrows=1000,
 format=qtr1., delimiter=_Qtr, var=ind1-ind4)

%transpose(data=have, out=want, by=idnum, id=date, guessingrows=1000,
 format=qtr1., prefix=Qtr, delimiter=_, var_first=no, var=ind1-ind4)

data have;
  informat name $5.;
  format name $5.;
  input year name height weight;
  cards;
2013 Dick 6.1 185
2013 Tom  5.8 163
2013 Harry 6.0 175
2014 Dick 6.1 180
2014 Tom  5.8 160
2014 Harry 6.0 195
;

data order;
  informat name $5.;
  format name $5.;
  input name order;
  cards;
Tom   1
Dick  2
Harry 3
;

%transpose(data=have, out=want, by=year, id=name, guessingrows=1000,
 delimiter=_, var=height weight, var_first=no, preloadfmt=order)

data have;
 format idnum 4. date date9.;
 input idnum date var1 var2 $;
 informat date date9.;
 cards;
1 31mar2013 1 SD
1 30jun2013 2 EF
1 30sep2013 3 HK
1 31dec2013 4 HL
2 31mar2013 5 GH
2 30jun2013 6 MM
2 30sep2013 7 JH
2 31dec2013 4 MS
;

%transpose(data=have, out=want, by=idnum, id=date, Guessingrows=1000,
 format=qtr1., delimiter=_Qtr, var=var1-var2)
 
 ********************************************************************/
