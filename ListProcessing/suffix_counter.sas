/*%suffix_counter 
    Purpose: Create a list of variable names formed by adding a numeric counter suffix to a base name. 

    Required arguments: 
        base – the text that should be the base of the variable names 
        end – the last number in the counter 

    Optional arguments: 
        start – the first number inthe counter [default: 1] 
        zpad – the number of digits to which the counter should be padded. Use zpad=0 for no padding. [default: 0] 

    Examples: 
        %put  %suffix_counter(v, 4);
                    produces the text v1 v2 v3 v4
        %put %suffix_counter(v, 14, start=10);
                    produces the text v10 v11 v12 v13 v14
        %put  %suffix_counter(v, 4, zpad=2);
                    produces the text v01 v02 v03 v04

    Credit:
        source code from Robert J. Morris, Text Utility Macros for Manipulating Lists of Variable Names
          (SUGI 30, 2005) www2.sas.com/proceedings/sugi30/029-30.pdf  
*/


%macro suffix_counter(base, end, start=1, zpad=0); 
%local outstr i counter; 

%* Verify macro arguments. ; 
%if (%length(&base) eq 0) %then %do; 
    %put ***ERROR(suffix_counter): Required argument 'base' is missing.; 
    %goto exit; 
%end; 
%if (%length(&end) eq 0) %then %do; 
    %put ***ERROR(suffix_counter): Required argument 'end' is missing.; 
    %goto exit; 
%end; 
%if (&end < &start) %then %do; 
    %put ***ERROR(suffix_counter): The 'end' argument must not be less; 
    %put *** than the 'start' argument.; 
    %goto exit; 
%end; 

%* Construct the outstr by looping from &start to &end, adding the counter 
* value to &base in each iteration. To handle the zero-padding, use the 
* putn function to format the counter variable with the Z. format. ; 
%let outstr=; 
%do i=&start %to &end; 
    %if (&zpad > 0) %then %do; 
        %let counter = %sysfunc(putn(&i, z&zpad..)); 
    %end; 
    %else %do; 
        %let counter = &i; 
    %end; 
    %let outstr=&outstr &base&counter; 
%end; 

%* Output the new list. ; 
&outstr 
%exit: 
%mend suffix_counter; 
