%macro for(macro_var_list,data=,values=,array=,to=,from=1,by=1,do=,delim=%str(
),length=);

/*

 Function: This macro performs a loop executing SAS code. It
 proceeds sequentially through one of 4 possible data sources:
 (1) the records of a SAS dataset, (2) the values of a value
 list, (3) a range of integer values or (4) the elements of
 macro arrays. Data source values are assigned to macro
 variables specified in macro_var_list.

 Example:

 %for(hospid hospname, data=report_hosps, do=%nrstr(
 title ”&hospid &hospname Patient Safety Indicators”;
 proc print data=psi_iqi(where=(hospid=”&hospid”)); run;
 ))

 The example above loops over the dataset ”report_hosps”, which
 has dataset variables ”hospid” and ”hospname”. For each dataset
 observation, macro variables &hospid and &hospname are assigned
 values from the identically named dataset variables and the loop
 code is performed, which prints a report.

 Parameters:
 macro_var_list = space-separated list of macro variable names
 to be assigned values upon each loop iteration.
 data = Dataset name, with optional libname and where clause.
 values = Delimiter-separated list of values (default delimiter
 is space)
 array = Space-separated list of macro array names
 to = Upper limit of iteration range. The triple "to=",
 "from=" and "by=" defines the iteration range, as in
 a %do-%to-%by statement. The presence of "to="

 specifies a range data source.
 from = Lower limit of iteration range (default=1).
 by = Increment in iteration range (default=1)
 do = The SAS code to be generated for each iteration of
 the %for macro. If macro variable substitution is
 to be done in the loop code (the typical case) enclose
 the code in a %nrstr() macro call to defer macro
 substitution to loop execution time.
 delim = Delimiters for separating values (default is space).
 length = Number of macro array elements to iterate over.
 When length= is omitted, the length is defined by the
 first macro variable name in the "array=" list.
 That first name with an "n" appended must be a macro
 variable containing the array length.

 Only 1 of the keyword parameters data=, values=, array=, or
 to= are permitted per %for call. For each of these, the macro
 variable &_n_ is set to 1 for the first iteration, and incremented
 by one for each successive iteration.

 For data= iterations:
 For each observation in the dataset, all macro variables in the
 macro_var_list are assigned values of identically named dataset
 variables and the "do=" SAS code is executed. The macro closes
 the dataset when end-of-dataset is reached.

 For values= iterations:
 The variables named in macro_var_list are assigned successive values
 from the values list. When all variables are assigned, the "do=" SAS
 code is executed. The process repeats until the end of value list is
 reached. If the end of value list is reached before all variables in
 macro_var_list are assigned values, then the iteration is terminated
 without performing the "do=" code on the partially assigned variables
 (the number of values in the value list should be a multiple of the
 number of names in macro_var_list).

 For array= iterations:
 The names in the macro_var_list are macro variables that will be
 assigned entries from the corresponding arrays in the "array="
 list for each loop iteration.

 For to= iterations:
 The first variable in the macro_var_list (if any) is assigned values
 as it would be by a %do-%to-%by statement.

 NOTE: Macro variable values obtained from datasets and arrays remain
 unquoted when they contain only letters, digits, whitespace, '_'
 and '.', otherwise they are quoted. Values obtained from value list
 are always unquoted.

 Author: Jim Anderson, UCSF, james.anderson@ucsf.edu
 "Please keep, use and pass on the %more and %close_more macros
 with this authorship note. -Thanks "

 Please send improvements, fixes or comments to Jim Anderson.

*/

 %global _for_loop_gen;
 %if &_for_loop_gen=%str( ) %then %let _for_loop_gen=0;
 %local _for_loop_itid _for_loop_ct _for_loop_code _for_loop_i
 _for_loop_val1 _for_loop_var1 _n_ _for_loop_set
 _for_loop_arrays _for_loop_values _for_loop_to

 for_loop_var_num;
 %let _for_loop_set=%length(&data);
 %let _for_loop_arrays=%length(&array);
 %let _for_loop_values=%length(&values);
 %let _for_loop_to=%length(&to);
 %if (&_for_loop_set>0)+(&_for_loop_arrays>0)+
 (&_for_loop_values>0)+(&_for_loop_to>0)>1 %then
 %do;
 %put ERROR: "for" macro only one of "data=", "to=", "values=" or "array=" allowed;
 %return;
 %end;
 %let _for_loop_code=&do;
 %if %eval(%index(&do,%nrstr(%if))+%index(&do,%nrstr(%do))) %then
 %do; %* conditional macro code - need to embed in macro;
 %let _for_loop_gen=%eval(&_for_loop_gen+1);
 %unquote(%nrstr(%macro) _for_loop_&_for_loop_gen(); &do %nrstr(%mend;))
 %let _for_loop_code=%nrstr(%_for_loop_)&_for_loop_gen();
 %end;
 %let _for_loop_ct=0;
 %if &_for_loop_set %then
 %do; %* loop over dataset;
 %let _for_loop_itid=%sysfunc(open(&data));
 %if &_for_loop_itid=0 %then
 %do;
 %put ERROR: cant open dataset data=&data;
 %return;
 %end;
 %do %while(%sysfunc(fetch(&_for_loop_itid,NOSET))>=0);
 %let _for_loop_ct=%eval(&_for_loop_ct+1);
 %let _n_=&_for_loop_ct;
 %let _for_loop_i=1;
 %let _for_loop_var1=%scan(&macro_var_list,1,%str( ));
 %do %while(%str(&_for_loop_var1) ne %str( ));
 %let _for_loop_var_num=%sysfunc(varnum(&_for_loop_itid,&_for_loop_var1));
 %if &_for_loop_var_num=0 %then
 %do;
 %put ERROR: "&_for_loop_var1" is not a dataset variable;
 %return;
 %end;
 %if %sysfunc(vartype(&_for_loop_itid,&_for_loop_var_num))=C %then
 %do; %* character variable;
 %let _for_loop_val1=%qsysfunc(getvarc(&_for_loop_itid,&_for_loop_var_num));
 %if %sysfunc(prxmatch("[^\w\s.]+",&_for_loop_val1)) %then
 %let &_for_loop_var1=%qtrim(&_for_loop_val1);
 %else
 %let &_for_loop_var1=%trim(&_for_loop_val1);
 %end;
 %else
 %do; %* numeric variable;
 %let &_for_loop_var1=%sysfunc(getvarn(&_for_loop_itid,&_for_loop_var_num));
 %end;
 %let _for_loop_i=%eval(&_for_loop_i+1);
 %let _for_loop_var1=%scan(&macro_var_list,&_for_loop_i,%str( ));
 %end;
%unquote(&_for_loop_code)
 %end;
 %let _for_loop_i=%sysfunc(close(&_for_loop_itid));
 %return;
 %end;
 %else %if &_for_loop_arrays %then
 %do; %* loop over one or more arrays;
 %local _for_loop_arrays _for_loop_array1 _for_loop_len;
 %if &macro_var_list=%str( ) %then %let macro_var_list=&array;

 %let _for_loop_arrays=&array;
 %let _for_loop_array1=%scan(&array,1,%str( ));
 %if &length ne %str( ) %then
 %let _for_loop_len=&length;
 %else
 %do; %* getnumber of iterations from first macro array;
 %if %symexist(&_for_loop_array1.n) %then
 %let _for_loop_len=&&&_for_loop_array1.n;
 %else
 %do;
 %put ERROR: "for" macro for arrays needs "length=" argument;
 %return;
 %end;
 %end;
 %do _for_loop_ct=1 %to &_for_loop_len;
 %let _n_=&_for_loop_ct;
 %let _for_loop_i=1;
 %let _for_loop_var1=%scan(&macro_var_list,1,%str( ));
 %do %while(%str(&_for_loop_var1) ne %str( ));
 %let _for_loop_array1=%scan(&_for_loop_arrays,&_for_loop_i,%str( ));
 %if &_for_loop_array1=%str( ) %then
 %do; %* more variables than arrays;
 %put ERROR: "for" macro has more variables than arrays;
 %return;
 %end;
 %let _for_loop_val1=%superq(&_for_loop_array1&_n_);
 %if %sysfunc(prxmatch("[^\w\s.]+",&_for_loop_val1)) %then
 %let &_for_loop_var1=%qtrim(&_for_loop_val1);
 %else
 %let &_for_loop_var1=%trim(&_for_loop_val1);
 %let _for_loop_i=%eval(&_for_loop_i+1);
 %let _for_loop_var1=%scan(&macro_var_list,&_for_loop_i,%str( ));
 %end;
%unquote(&_for_loop_code)
 %end;
 %return;
 %end;
 %else %if &_for_loop_values ne 0 %then
 %do; %* loop over list of values;
 %local _for_value_index _for_loop_values _for_loop_delim _for_loop_extra;
 %let _for_loop_values=&values;
 %let _for_loop_delim=&delim;
 %let _for_value_index=1;
 %if &macro_var_list=%str( ) %then
 %do; %*empty variable list - perhaps (s)he just wants &_n_;
 %let macro_var_list=_for_loop_extra;
 %end;
 %do %while(1);
 %let _for_loop_ct=%eval(&_for_loop_ct+1);
 %let _n_=&_for_loop_ct;
 %let _for_loop_i=1;
 %let _for_loop_var1=%scan(&macro_var_list,1,%str( ));
 %do %while(%str(&_for_loop_var1) ne %str( ));
 %let
_for_loop_val1=%scan(&_for_loop_values,&_for_value_index,&_for_loop_delim);
 %let _for_value_index=%eval(&_for_value_index+1);
 %if %length(&_for_loop_val1)=0 %then
 %do; %* end of values before end of variables, terminate iteration;
 %return;
 %end;
 %let &_for_loop_var1=&_for_loop_val1;
 %let _for_loop_i=%eval(&_for_loop_i+1);
 %let _for_loop_var1=%scan(&macro_var_list,&_for_loop_i,%str( ));

 %end;
%unquote(&_for_loop_code)
 %end;
 %end;
 %else %if &_for_loop_to %then
 %do; %* loop from &from to &to by &by;
 %*local &macro_var_list;
 %let _for_loop_var1=%scan(&macro_var_list,1,%str( ));
 %let _for_loop_ct=1;
 %do _for_loop_i=&from %to %eval(&to) %by &by;
 %let _n_=&_for_loop_ct;
 %if %str(&_for_loop_var1) ne %str( ) %then %let &_for_loop_var1=&_for_loop_i;
 %let _for_loop_ct=%eval(&_for_loop_ct+1);
%unquote(&_for_loop_code)
 %end;
 %return;
 %end;
 %put ERROR: for macro requires a "data", "values", "to" or "array" keyword;
%mend for;
