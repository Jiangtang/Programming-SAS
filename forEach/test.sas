/*
%for(list-of-macro-variable-names, in=source-of-loop-values, do=SAS-code-to-generate)

%for( <list of macro variables to be set for each observation>, <data source>, 
 <SAS code to perform for each observation> ) 


 (1) obtains values from the data source, 
 (2) assigns those values to the list of macro variables, 
 (3) substitutes the macro variable values where the variables appear in the SAS code to generate, and 
 (4) outputs (i.e., generates) the modified SAS code.

*/

/*
value list:        (a b c)
SAS dataset:       [xyz]  
number range:      1:100
dataset contents:  {xyz}
directory contents: <c:\abc>

*/

options mlogic mprint symbolgen;
options nomlogic nomprint nosymbolgen;

/*1. value list:  enclosing the list in parentheses: ( )*/
/*
dataset contents and
directory contents*/

%let many=(hello goodbye);
%for(one, in=&many, do=%nrstr(
	%put one=&one;
		)
	)

%for(one,in=(hello Goodbye),do=%nrstr(
	%put &one;
))



%let many=(hello goodbye);
%for(one two, in=&many, do=%nrstr(%put one=&one two=&two;))



/*2. number range: 1:5*/
/*todo: by increase in 2008 version and backward*/
%for(one, in=1:10, do=%nrstr(%put one=&one;))



%for(i,in=11:16,do=%nrstr(
	proc sort data=class_&i;
		by height;
	run;
))



/*3. datasets: enclosing the dataset name in brackets: [ ]*/
/*
, the names used in the macro variable list must 
match variable names in the data source dataset. 
*/


data example;
    one = 'interesting!'; two = 'certainly.'; output;
    one = 'useful?'; 	  two = 'not sure.';  output;
run;
 
%let many=[example];
%for(one, in=&many, do=%nrstr(%put one=&one;))

%for(one, in=[example], do=%nrstr(%put one=&one;))

/*
when there are multiple variables in the macro variable list, 
successive entries of the value list are assigned to 
the successive macro variables upon each iteration, 
until the value list is exhausted.
*/

%for(one two, in=[example], do=%nrstr(%put one=&one two=&two;))


/*Split dataset sashelp.class into separate datasets by the age variable*/
proc sort data=sashelp.class nodupkey out=ages; by age; run;
 
data %for(age, in=[ages], do=%nrstr(class_&age(where=(age=&age))));
    set sashelp.class;
run;


/*4. dataset contents: dataset name is enclosed in braces: { }*/

/*Rename all variables in a dataset with the same prefix (for example, “abc_”)*/
/*??*/
proc contents data=sashelp.class out=class noprint; run; 
 
 data up_ready; 
 set ready; 
 %for(name type length, data=class, do=%nrstr( 
 %if &type=2 and &length<3 %then 
 %do; 
 &name = upcase(&name); 
 %end; 
 )) 
 run; 


%let renames=%for(sex, in={bb}, do=%nrstr(&name=abc_&sex));
proc datasets;
    modify some_dataset;
    rename &renames;
quit;



/*5. directory contents: enclosed in angle-brackets: < >*/
/*Import all spreadsheets in all subfolders of a top folder*/

%let topfolderpath= ... path to some directory ... ;
%for(filepath, in=<&topfolderpath>, do=%nrstr(
    %let subfolderpath=&filepath;
    %for(filepath shortname, in=<&subfolderpath>, do=%nrstr(
        proc import datafile="&filepath" out=&shortname 
            dbms="excel" replace; 
        run;
    ))
))







