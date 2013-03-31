/*%add_string 
    Purpose: Add a text string to each variable in a list as either a prefix or suffix.
    dependence: %num_tokens

    Required arguments: 
        words – the variable list 
        str – the text string to add to each variable in the &words list 

    Optional arguments: 
        location – whether to add the text string as a prefix or suffix [prefix|suffix, default: suffix] 
        delim – the character(s) separating each variable in the &words list [default: space] 

    Examples: 
        %put  %add_string(a b c, _max); *produces the text a_max b_max c_max;            
        %put %add_string(a b c, max_, location=prefix);     *produces the text max_a max_b max_c;            
        %put %add_string(%str(a,b,c), _max, delim=%str(,)); *produces the text a_max,b_max,c_max;

    Credit:
        source code from Robert J. Morris, Text Utility Macros for Manipulating Lists of Variable Names
          (SUGI 30, 2005) www2.sas.com/proceedings/sugi30/029-30.pdf           

*/


%macro add_string(words, str, delim=%str( ), location=suffix); 
    %local outstr i word num_words; 

    %* Verify macro arguments. ; 
    %if (%length(&words) eq 0) %then %do; 
        %put ***ERROR(add_string): Required argument 'words' is missing.; 
        %goto exit; 
    %end; 
    %if (%length(&str) eq 0) %then %do; 
        %put ***ERROR(add_string): Required argument 'str' is missing.; 
        %goto exit; 
    %end; 
    %if (%upcase(&location) ne SUFFIX and %upcase(&location) ne PREFIX) %then %do; 
        %put ***ERROR(add_string): Optional argument 'location' must be; 
        %put *** set to SUFFIX or PREFIX.; 
        %goto exit; 
    %end; 

    %* Build the outstr by looping through the words list and adding the 
    * requested string onto each word. ; 
    %let outstr = ; 
    %let num_words = %num_tokens(&words, delim=&delim); 
    %do i=1 %to &num_words; 
        %let word = %scan(&words, &i, &delim); 
        %if (&i eq 1) %then %do; 
            %if (%upcase(&location) eq PREFIX) %then %do; 
                %let outstr = &str&word; 
            %end; 
            %else %do; 
                %let outstr = &word&str; 
            %end; 
        %end; 
        %else %do; 
            %if (%upcase(&location) eq PREFIX) %then %do; 
                %let outstr = &outstr&delim&str&word; 
            %end; 
            %else %do; 
                %let outstr = &outstr&delim&word&str; 
            %end; 
        %end; 
    %end; 
    %* Output the new list of words. ; 
    &outstr 
    %exit: 
%mend add_string; 
