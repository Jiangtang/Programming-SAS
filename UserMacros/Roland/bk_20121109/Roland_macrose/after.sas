/*<pre><b>
/ Program   : after.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 31-Jul-2007
/ Purpose   : Function-style macro to give you what comes directly after a
/             target string.
/ SubMacros : none
/ Notes     : It gives you the word or quote that directly follows a target
/             string. You can specify multiple target strings and it will use
/             the first match. The search is case insensitive. Note that if your
/             target contains an equals sign then you must enclose it in %str( )
/             otherwise it is interpreted as a parameter.
/ Usage     : %let width=%after(&str,%str(width=),%str( w=));
/ 
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

%mend;
