/*<pre><b>
/ Program      : capmac.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 11-Jan-2013
/ Purpose      : Function-style macro to capitalise the first letter of each
/                word in a macro string.
/ SubMacros    : %words %quotelst (%qlowcase from SI supplied autocall library
/                is called so this must be on the sasautos path).
/ Notes        : You can specify words to ignore. Case must match for these.
/                If the string you supply might contain commas or unbalanced
/                quotes then you should use %nrbquote() around it. See usage.
/ Usage        : %let tidy=%capmac(%nrbquote(A, B AND C'S RESULTS));
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
/ rrb  04May11         Code tidy
/ rrb  11Jan13         Header tidy. %lowcase removed from submacro list and
/                      use of %qlowcase documented. %nrbquote() recommended in
/                      place of %bquote() in Notes and Usage. Version number
/                      unchanged as no change made to the macro code (v1.0)
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

%mend capmac;
