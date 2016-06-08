/*<pre><b>
/ Program      : capmac.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 30-Jul-2007
/ Purpose      : Function-style macro to capitalise the first letter of each
/                word in a macro string.
/ SubMacros    : %words %quotelst %lowcase
/ Notes        : You can specify words to ignore. Case must match for these.
/                If the string you supply might contain commas or unbalanced
/                quotes then you should use %bquote() around it. See usage.
/ Usage        : %let tidy=%capmac(%bquote(A, B AND C'S RESULTS));
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ string            (pos) Macro string to convert
/ ignore            List of strings (separated by spaces) to ignore
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: capmac v1.0;

%macro capmac(string,ignore=);

%local i igquote bit words;

%if %length(&ignore) %then %let igquote=%quotelst(&ignore);
%let words=%words(&string);

%do i=1 %to &words;
  %let bit=%qscan(&string,&i,%str( ));
  %if %length(&ignore) %then %do;
    %if %index(&igquote,"%bquote(&bit)") %then %do;
&bit
      %goto done;
    %end;
  %end;
  %let bit=%qlowcase(&bit);
  
  %*- One character word -;
  %if %length(&bit) EQ 1 %then %do;
    %if &i EQ 1 %then %do;
%qupcase(&bit)
    %end;
    %else %if "%bquote(&bit)" EQ "a" %then %do;
a
    %end;
    %else %do;
%qupcase(&bit)
    %end;
   %end;
  
  %*- Longer than one character word -;
  %else %do;
    %*- always capitalise the first word -;
    %if &i EQ 1 %then %do;
%qupcase(%substr(&bit,1,1))%qsubstr(&bit,2)
    %end;
    %*- leave join words as lower text if not the last word -;
    %else %if %index("an" "and" "as" "at" "but" "by" "for" "in" "is" "it" "of"
                     "on" "or" "so" "that" "the" "to" "when" "with",
      "%bquote(&bit)") and (&i LT &words) %then %do;
&bit
    %end;
    %*- all other cases -;
    %else %do;
%qupcase(%substr(&bit,1,1))%qsubstr(&bit,2)
    %end;
  %end;
  
%done:
%end;

%mend;
