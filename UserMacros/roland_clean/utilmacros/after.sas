/*<pre><b>
/ Program   : after.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to give you what comes directly after a
/             target string.
/ SubMacros : none
/ Notes     : This macro is for scanning text to give you the next space-
/             delimited word or quote-enclosed string directly following one
/             of a list of nine target strings that you can specify. For
/             multiple target strings, it will use the first match. The search
/             is not case sensitive. Note that if your target contains an equals
/             sign then you must enclose it in %str( ) otherwise it is
/             interpreted as a parameter. See usage notes.
/ Usage     : %let width=%after(&str,%str(width=),%str( w=));
/ 
/===============================================================================
/ REQUIREMENTS SPECIFICATION:
/ --id--  ---------------------------description--------------------------------
/ REQ001: The user be allowed to specify up to nine target strings.
/ REQ002: Macro parameters should be positional.
/ REQ003: This macro should be a function-style macro that returns a result.
/ REQ004: For multiple target strings then what follows the first matching
/         target string will be returned. 
/ REQ005: If what follows the target string is a single-quoted or double-quoted
/         string then that whole string (including quotes) should be returned.
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ string            (pos) String to search
/ target1-9         (pos) Target strings
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/ rrb  24Mar09         Requirements specification added to header
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: after v1.0;

%macro after(string,
            target1,
            target2,
            target3,
            target4,
            target5,
            target6,
            target7,
            target8,
            target9);

  %local word i start len qtype;
  %let len=0;
  %do i=1 %to 9;
    %if %index(%qupcase(&string),%qupcase(&&target&i)) %then %do;
      %let start=%index(%qupcase(&string),%qupcase(&&target&i))+%length(&&target&i);
      %if %qsubstr(&string,&start,1) EQ %str(%')
       or %qsubstr(&string,&start,1) EQ %str(%") %then %do;
         %let qtype=%qsubstr(&string,&start,1);
         %if %index(%qsubstr(&string,&start+1),%str(&qtype)) 
           %then %let len=%eval(%index(%qsubstr(&string,&start+1),%str(&qtype))+1);
         %if &len %then %let word=%qsubstr(&string,&start,&len);
         %else %let word=%qscan(%qsubstr(&string,&start),1,%str( ));
      %end;
      %else %let word=%qscan(%qsubstr(&string,&start),1,%str( ));
      %let i=9;
    %end;
  %end;

&word

%mend after;
