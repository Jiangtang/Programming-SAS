%macro for(macro_var_list,in=,do=);

/* 
  Function: This macro performs a loop generating SAS code.  It
    proceeds sequentially through one of 5 kinds of data objects: 
    SAS dataset, value list, number range, dataset contents and
    directory contents.  Data object values are assigned to macro 
    variables specified in macro_var_list upon each loop iteration. 
    
    Example:
     
      %for(hospid hospname, in=[report_hosps], do=%nrstr(
          title "&hospid &hospname Patient Safety Indicators";
          proc print data=psi_iqi(where=(hospid="&hospid")); run;
      ))

  The example above loops over the dataset "report_hosps", which 
  has dataset variables "hospid" and "hospname".  For each dataset
  observation, macro variables &hospid and &hospname are assigned 
  values from the identically named dataset variables and the loop 
  code is generated, which in the example prints a report.
    
  Parameters: 
    macro_var_list = space-separated list of macro variable names
              to be assigned values upon each loop iteration. 
    in      = Data object to access.  Object type is distinguished
              by choice of brackets (or no backets for a range):
                  (a b c)  - a space-separated value list whose
                             values are sequentially accessed.
                  [xyz]    - a SAS dataset whose observations are
                             sequentially accessed.
                  {xyz}    - a SAS dataset whose variable descriptions
                             (proc contents) are sequentially accessed.
                  <c:\abc> - a directory path whose file descriptions
                             are sequentially accessed.
                  1:100    - a number range whose values are 
                             sequentially accessed.
    do      = The SAS code to be generated for each iteration of
              the %for macro.  If macro variable substitution is
              to be done in the loop code (the typical case) enclose 
              the code in a %nrstr() macro call to defer macro
              substitution to loop generation time.
  
    For dataset [ ] iterations:
    The dataset name can be qualified with a libname and where clause.
    For each observation in the dataset, all macro variables in the
    macro_var_list are assigned values of identically named dataset 
    variables and the "do=" SAS code is generated. 
    
    For dataset contents { } iterations:
    The dataset name can be qualified with a libname.
    For each variable in the dataset, the macro variables in the
    macro_var_list are assigned values to describe the dataset
    variable and the "do=" SAS code is generated.  Valid names in
    macro_var_list are "name", "type", "length", "format" and "label".
        name   - is set to the variable name
        type   - is set to 1 for numeric variables and 2 for
                 character variables.
        format - is set to the variable format
        length - is set to the variable length
        label  - is set to the variable label
    
    For directory < > iterations:
    For each file in the directory, the macro variables in the
    macro_var_list are assigned values to describe a directory
    file and the "do=" SAS code is generated.  Valid names in
    macro_var_list are "filepath", "filename", "shortname", 
    "extension", and "isdir". 
        filepath - full pathname of file
        filename - filename with extension
        shortname - filename without extension
        extension - file extension
        isdir  - 1 if file is directory, else 0 
    
    For value list ( ) iterations:
    Space is the default value separator.  Enclose other separator 
    characters in nested parentheses, e.g., in=((|)Joe Jones|Al Smith) 
    The variables named in macro_var_list are assigned successive values
    from the value list. When all variables are assigned, the "do=" SAS
    code is generated.  The process repeats until the end of value list is
    reached.  If the end of value list is reached before all variables in
    macro_var_list are assigned values, then the iteration is terminated
    without generating the "do=" code on the partially assigned variables
    (the number of values in the value list should be a multiple of the
    number of names in macro_var_list).
    
    For range : iterations:
    A range with 2 numbers uses a single colon and has an implied
    increment of 1.  For a range with 3 numbers (e.g., in=1:11:2),
    the final number is the increment. The first variable in the 
    macro_var_list is assigned values as it would be by a 
    %do-%to-%by statement.
    
    NOTE: Macro variable values obtained from datasets remain unquoted 
    when they contain only letters, digits, whitespace, '_' and '.', 
    otherwise they are quoted.  Values obtained from value list are 
    always unquoted.

  Author: Jim Anderson, UCSF, james.anderson@ucsf.edu
    "Please keep, use and pass on the %for macro 
     with this authorship note.  -Thanks "

  Please send improvements, fixes or comments to Jim Anderson.

*/

  %local _for_itid _for_ct _for_do _for_i _for_val1 _for_var1 _n_ 
         _for_dir _for_var_num _for_in_first _for_in_last _for_in_length 
         _for_in_sep _for_in_values _for_in_more _for_extra;  
  %let _for_do=&do;
  %if %eval(%index(&do,%nrstr(%if))+%index(&do,%nrstr(%do))) %then
  %do; %* conditional macro code - need to embed in macro;
    %global _for_gen;
    %if &_for_gen=%str( ) %then %let _for_gen=0;
    %else %let _for_gen=%eval(&_for_gen+1);
    %unquote(%nrstr(%macro) _for_loop_&_for_gen(); &do %nrstr(%mend;))
    %let _for_do=%nrstr(%_for_loop_)&_for_gen();
  %end;
  %let _for_ct=0;
  %let _for_in_first=%qsubstr(&in,1,1);
  %let _for_in_length=%length(&in);
  %let _for_in_last=%qsubstr(&in,&_for_in_length,1);
  %if &_for_in_first=%qsubstr((),1,1) %then
  %do; %* loop over value list;
  	%if &_for_in_last ne %qsubstr((),2,1) %then
  	%do;
  		%put ERROR: "for" macro "in=(" missing terminating ")";
  		%return;
  	%end;
    %if &macro_var_list=%str( ) %then
    %do; %*empty variable list - perhaps (s)he just wants &_n_;
      %let macro_var_list=_for_extra;
    %end;
  	%if %qsubstr(&in,2,1) ne &_for_in_first %then
  	%do; %* implicit space separator -- empty entries disallowed;
  	  %if &_for_in_length<3 %then %return;
  	  %let _for_in_values=%substr(&in,2,%eval(&_for_in_length-2));
      %local _for_value_index;
      %let _for_value_index=1;
      %do %while(1);
        %let _for_ct=%eval(&_for_ct+1);
        %let _n_=&_for_ct;
      	%let _for_i=1;
      	%let _for_var1=%scan(&macro_var_list,1,%str( ));
      	%do %while(%str(&_for_var1) ne %str( ));
      	  %let _for_val1=%scan(&_for_in_values,&_for_value_index,%str( ));
      	  %let _for_value_index=%eval(&_for_value_index+1);
      	  %if %length(&_for_val1)=0 %then
      	  %do; %* end of values before end of variables, terminate iteration;
            %return;
          %end;
      	  %let &_for_var1=&_for_val1;
      	  %let _for_i=%eval(&_for_i+1);
      	  %let _for_var1=%scan(&macro_var_list,&_for_i,%str( ));
      	%end;
  %unquote(&_for_do)
      %end;
      %return;
  	%end;
  	%else
  	%do; %* explicit separator -- empty entries allowed;
  		%if &_for_in_length<6 %then %return; %* empty list;
  		%let _for_in_sep=%qsubstr(&in,3,1);
  		%if %qsubstr(&in,4,1) ne &_for_in_last %then
  		%do;
  			%put ERROR: "for" macro "in=" explicit separator missing right parenthesis;
  			%return;
  		%end;
  		%let _for_in_values=%qleft(%qtrim(%qsubstr(&in,5,%eval(&_for_in_length-5))));
	    %let _for_in_more=1;
	    %do %while(1);
	      %let _for_ct=%eval(&_for_ct+1);
	      %let _n_=&_for_ct;
	    	%let _for_i=1;
	    	%let _for_var1=%scan(&macro_var_list,1,%str( ));
	    	%do %while(%str(&_for_var1) ne %str( ));
		  		%if &_for_in_more=0 %then %return; %* end of value list;
          %if &_for_in_sep=%qsubstr(&_for_in_values,1,1) %then %let &_for_var1=;
	    	  %else %let &_for_var1=%scan(&_for_in_values,1,&_for_in_sep);
	    	  %let _for_i=%eval(&_for_i+1);
	    	  %let _for_var1=%scan(&macro_var_list,&_for_i,%str( ));
	    	  %let _for_in_more=%index(&_for_in_values,&_for_in_sep);
          %if %length(&_for_in_values)=&_for_in_more %then %let _for_in_values=%str( );
	    	  %else %let _for_in_values=%qsubstr(&_for_in_values,%eval(&_for_in_more+1));
	    	%end;
	%unquote(&_for_do)
	    %end;
	    %return;
  	%end;
  %end;
  %else %if &_for_in_first=%str([) %then
  %do; %* loop over dataset;
    %local _for_in_dataset;
  	%if &_for_in_last ne %str(]) %then
  	%do;
  		%put ERROR: "for" macro "in=[" missing terminating "]";
  		%return;
  	%end;
  	%if &_for_in_length<3 %then %return;
  	%let _for_in_dataset=%substr(&in,2,%eval(&_for_in_length-2));
	  %let _for_itid=%sysfunc(open(&_for_in_dataset));
	  %if &_for_itid=0 %then
	  %do;
	    %put ERROR: for macro cant open dataset &_for_in_dataset;
	    %return;
	  %end;
    %do %while(%sysfunc(fetch(&_for_itid,NOSET))>=0);
      %let _for_ct=%eval(&_for_ct+1);
      %let _n_=&_for_ct;
    	%let _for_i=1;
    	%let _for_var1=%scan(&macro_var_list,1,%str( ));
    	%do %while(%str(&_for_var1) ne %str( ));
    	  %let _for_var_num=%sysfunc(varnum(&_for_itid,&_for_var1));
    	  %if &_for_var_num=0 %then
    	  %do;
    	    %put ERROR: "&_for_var1" is not a dataset variable;
    	    %return; 
    	  %end;
    	  %if %sysfunc(vartype(&_for_itid,&_for_var_num))=C %then
    	  %do; %* character variable;
    	    %let _for_val1=%qsysfunc(getvarc(&_for_itid,&_for_var_num));
      	  %if %sysfunc(prxmatch("[^\w\s.]+",&_for_val1)) %then
      	    %let &_for_var1=%qtrim(&_for_val1);
      	  %else
      	    %let &_for_var1=%trim(&_for_val1);
    	  %end;
    	  %else
    	  %do; %* numeric variable;
    	    %let &_for_var1=%sysfunc(getvarn(&_for_itid,&_for_var_num));
    	  %end;
    	  %let _for_i=%eval(&_for_i+1);
    	  %let _for_var1=%scan(&macro_var_list,&_for_i,%str( ));
    	%end;
%unquote(&_for_do)
    %end;
	  %let _for_i=%sysfunc(close(&_for_itid));
    %return;
  %end;
  %else %if &_for_in_first=%str({) %then
  %do; %* loop over proc contents;
    %local _for_in_dataset;
  	%if &_for_in_last ne %str(}) %then
  	%do;
  		%put ERROR: "for" macro "in={" missing terminating "}";
  		%return;
  	%end;
  	%if &_for_in_length<3 %then %return;
  	%let _for_in_dataset=%substr(&in,2,%eval(&_for_in_length-2));
	  %let _for_itid=%sysfunc(open(&_for_in_dataset));
	  %if &_for_itid=0 %then
	  %do;
	    %put ERROR: for macro cant open dataset &_for_in_dataset;
	    %return;
	  %end;
	  %let _for_ct = %sysfunc(attrn(&_for_itid,NVARS));
    %do _for_i=1 %to &_for_ct;
      %let _n_=&_for_i;
    	%let _for_var_num=1;
    	%let _for_var1=%upcase(%scan(&macro_var_list,1,%str( )));
    	%do %while(%str(&_for_var1) ne %str( ));
    	  %if &_for_var1=NAME %then
    	  %do;
    	    %let name=%sysfunc(varname(&_for_itid,&_for_i));
    	  %end;
    	  %else %if &_for_var1=FORMAT %then
    	  %do;
    	    %let format=%sysfunc(varfmt(&_for_itid,&_for_i));
    	  %end;
    	  %else %if &_for_var1=TYPE %then
    	  %do;
    	    %if %sysfunc(vartype(&_for_itid,&_for_i))=C %then
    	      %let type=2;
    	    %else
    	      %let type=1;
    	  %end;
    	  %else %if &_for_var1=LENGTH %then
    	  %do;
    	    %let length=%sysfunc(varlen(&_for_itid,&_for_i));
    	  %end;
    	  %else %if &_for_var1=LABEL %then
    	  %do;
    	    %let _for_val1=%qsysfunc(varlabel(&_for_itid,&_for_i));
      	  %if %sysfunc(prxmatch("[^\w\s.]+",&_for_val1)) %then
      	    %let label=%qtrim(&_for_val1);
      	  %else
      	    %let label=%trim(&_for_val1);
    	  %end;
    	  %else
    	  %do;
    	    %put ERROR: "&_for_var1" is not NAME, TYPE, FORMAT, LENGTH or LABEL;
    	    %return; 
    	  %end;
    	  %let _for_var_num=%eval(&_for_var_num+1);
    	  %let _for_var1=%upcase(%scan(&macro_var_list,&_for_var_num,%str( )));
    	%end;
%unquote(&_for_do)
    %end;
	  %let _for_i=%sysfunc(close(&_for_itid));
    %return;
  %end;  
  %else %if &_for_in_first=%str(<) %then
  %do; %* loop over directory contents;
  	%if &_for_in_last ne %str(>) %then
  	%do;
  		%put ERROR: "for" macro "in=<" missing terminating ">";
  		%return;
  	%end;
    %let _for_val1=;
  	%if &_for_in_length<3 %then %return;
    %let _for_dir=%substr(&in,2,%eval(&_for_in_length-2));
	  %let _for_itid=%sysfunc(filename(_for_val1,&_for_dir));
	  %let _for_itid=%sysfunc(dopen(&_for_val1));
	  %if &_for_itid=0 %then
	  %do;
	    %put ERROR: cant open directory path=&_for_dir;
	    %return;
	  %end;
	  %let _for_ct = %sysfunc(dnum(&_for_itid));
    %do _for_i=1 %to &_for_ct;
      %let _n_=&_for_i;
    	%let _for_var_num=1;
    	%let _for_var1=%upcase(%scan(&macro_var_list,1,%str( )));
    	%do %while(%str(&_for_var1) ne %str( ));
    	  %let _for_extra=%sysfunc(dread(&_for_itid,&_for_i));
    	  %if &_for_var1=FILENAME %then
    	  %do;
    	    %let filename=&_for_extra;
    	  %end;
    	  %else %if &_for_var1=EXTENSION %then
    	  %do;
    	    %if %index(&_for_extra,%str(.)) ne 0 %then
    	    %do;
    	      %let extension=.%scan(&_for_extra,-1,%str(.));
    	    %end;
    	    %else
    	    %do;
    	      %let extension=;
    	    %end;
    	  %end;
    	  %else %if &_for_var1=FILEPATH %then
    	  %do;
    	    %let filepath=&_for_dir\&_for_extra; %*windows specific;
    	  %end;
    	  %else %if &_for_var1=SHORTNAME %then
    	  %do;
    	    %if %index(&_for_extra,%str(.)) ne 0 %then
    	    %do;
    	      %let _for_val1=%eval(%length(&_for_extra)-
    	               %length(%scan(&_for_extra,-1,%str(.)))-1);
    	      %let shortname=%substr(&_for_extra,1,&_for_val1);
    	    %end;
    	    %else
    	    %do;
    	      %let shortname=&_for_extra;
    	    %end;
    	  %end;
    	  %else %if &_for_var1=ISDIR %then
    	  %do; %*below windows specific;
    	    %let _for_var1=_forfile;
    	    %let _for_val1=%sysfunc(filename(_for_var1,&_for_dir\&_for_extra));
    	    %let _for_val1=%sysfunc(dopen(&_for_var1));
    	    %let isdir=%eval(&_for_val1 ne 0);
    	    %if &isdir %then 
    	    %do; 
    	      %let _for_val1=%sysfunc(dclose(&_for_val1));
    	    %end;
    	  %end;
    	  %else
    	  %do;
    	    %put ERROR: "&_for_var1" is not FILENAME, EXTENSION, FILEPATH, SHORTNAME or ISDIR;
    	    %return; 
    	  %end;
    	  %let _for_var_num=%eval(&_for_var_num+1);
    	  %let _for_var1=%upcase(%scan(&macro_var_list,&_for_var_num,%str( )));
    	%end;
%unquote(&_for_do)
    %end;
	  %let _for_i=%sysfunc(dclose(&_for_itid));
	  %let _for_i=%sysfunc(filename(_for_val1,));
    %return;
  %end;
  %else %if %index(&in,%str(:)) %then
  %do; %* loop from:to:by;
    %local _for_in_from _for_in_to _for_in_by;
    %let _for_in_from=%scan(&in,1,%str(:));
    %let _for_in_to=%scan(&in,2,%str(:));
    %if &_for_in_to=%str( ) %then 
    %do;
      %put ERROR: for macro missing value after : in range;
      %return;
    %end;
    %let _for_in_by=%scan(&in,3,%str(:));
    %if &_for_in_by=%str( ) %then %let _for_in_by=1;
    %let _for_var1=%scan(&macro_var_list,1,%str( ));
    %let _for_ct=1;
    %do _for_i=&_for_in_from %to &_for_in_to %by &_for_in_by;
      %let _n_=&_for_ct;
    	%if %str(&_for_var1) ne %str( ) %then %let &_for_var1=&_for_i;
    	%let _for_ct=%eval(&_for_ct+1);
%unquote(&_for_do)
    %end;
    %return;
  %end;
  
  %put ERROR: for macro unrecognized in= argument value "&in";
%mend for;