/*%rename_string 
    Purpose: Create a list suitable for the rename statement where the variables in a list 
                are renamed so that they have a common text string as a prefix or suffix.
    dependence: %num_tokens, %parallel_join, %add_string
 

    Required arguments: 
        words – the variable list containing the original names 
        str – the text string to add to each renamed variable 

    Optional arguments: 
        location – whether to add the text string as a prefix or suffix [prefix|suffix, default: suffix] 
        delim – the character(s) separating each variable in the &words list [default: space] 

    Examples: 
    %put  %rename_string(a b c, _1);
                produces the text a=a_1 b=b_1 c=c_1
    %put %rename_string(a b c, r_, location=prefix);
                produces the text a=r_a b=r_b c=r_c
    %put  %rename_string(a|b|c, _1, delim=|);
                produces the text a=a_1 b=b_1 c=c_1
    Credit:
        source code from Robert J. Morris, Text Utility Macros for Manipulating Lists of Variable Names
          (SUGI 30, 2005) www2.sas.com/proceedings/sugi30/029-30.pdf   
*/


%macro rename_string(words, str, delim=%str( ), location=suffix); 
    %* Verify macro arguments. ; 
    %if (%length(&words) eq 0) %then %do; 
        %put ***ERROR(rename_string): Required argument 'words' is missing.; 
        %goto exit; 
    %end; 

    %if (%length(&str) eq 0) %then %do; 
        %put ***ERROR(rename_string): Required argument 'str' is missing.; 
        %goto exit; 
    %end; 
    %if (%upcase(&location) ne SUFFIX and %upcase(&location) ne PREFIX) %then %do; 
        %put ***ERROR(rename_string): Optional argument 'location' must be; 
        %put *** set to SUFFIX or PREFIX.; 
        %goto exit; 
    %end; 

    %* Since rename_string is just a special case of parallel_join, 
    * simply pass the appropriate arguments on to that macro. ; 
    %parallel_join( 
    &words, 
    %add_string(&words, &str, delim=&delim, location=&location), 
    =, 
    delim1 = &delim, 
    delim2 = &delim 
    ) 
    %exit: 
%mend rename_string; 
