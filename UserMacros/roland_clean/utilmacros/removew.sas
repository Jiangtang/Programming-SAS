/*<pre><b>
/ Program   : removew.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 05-Dec-2012
/ Purpose   : Function-style macro to remove all occurrences of the target
/             word(s) from a source list of words.
/ SubMacros : %words
/ Notes     : For a word to be removed, the whole word must match. This macro
/             will not remove substrings in the sense that "low" will not be
/             removed from the end of the word "yellow". Multiple occurences of
/             a word will be removed. This macro will only work correctly for
/             lists of space-delimited words containing no special characters
/             that need quoting. You should avoid combinations of a string with
/             many words and many target words such that their product is very
/             high (e.g. 100 x 100 = 10000) as this code will run slow and use
/             a lot of processor power. Data step solutions or SQL solutions are
/             better for those cases. Final result returned will have leading
/             and trailing spaces removed and multiple adjacent blanks replaced
/             by single blanks.
/ Usage     : %let colors2=%removew(&rainbow,green yellow);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ string            (pos) Unquoted space-delimited source list of words
/ targetwords       (pos) Unquoted space-delimited target word(s) to remove
/ casesens=no       Whether the search for the target word(s) is case sensitive
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  26Jan08         compbl bug fixed
/ rrb  04May11         Code tidy
/ rrb  05Dec12         Usage notes macro call coreected
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: removew v1.1;

%macro removew(string,
          targetwords,
             casesens=no
              );

  %local i j result match twords swords tword sword;

  %if not %length(&casesens) %then %let casesens=no;
  %let casesens=%upcase(%substr(&casesens,1,1));

  %let twords=%words(&targetwords);
  %let swords=%words(&string);

  %let result=;

  %do i=1 %to &swords;
    %let match=0;
    %let sword=%scan(&string,&i,%str( ));
    %do j=1 %to &twords;
      %let tword=%scan(&targetwords,&j,%str( ));
      %if "&casesens" EQ "Y" %then %do;
        %if "&tword" EQ "&sword" %then %do;
          %let match=1;
          %let j=&twords;
        %end;
      %end;
      %else %do;
        %if "%upcase(&tword)" EQ "%upcase(&sword)" %then %do;
          %let match=1;
          %let j=&twords;
        %end;
      %end;
    %end;
    %if not &match %then %let result=&result &sword;
  %end;

  %if %length(&result) %then %let result=%sysfunc(compbl(&result));

&result

%mend removew;
