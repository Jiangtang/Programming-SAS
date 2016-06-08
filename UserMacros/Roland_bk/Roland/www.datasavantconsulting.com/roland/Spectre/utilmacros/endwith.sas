/*<pre><b>
/ Program   : endwith.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to ensure any non-null value assigned to a
/             macro variable ends with the specified character.
/ SubMacros : none
/ Notes     : This was originally written to ensure that directories assigned to
/             macro variables end with the directory slash, if indeed anything
/             had been assigned. This is difficult to do in open code and so
/             this macro was written.
/ Usage     : filename outfile "%endwith(&outdir,/)output.txt";
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ value             (pos) Contents of macro variable.
/ char              (pos) Character to make sure it ends with if not null.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: endwith v1.0;

%macro endwith(value,char); 
  %if %length(&value) %then %do; 
    %if "%qsubstr(&value,%length(&value),1)" NE "&char" %then %do; 
%superq(value)&char 
    %end; 
    %else %do; 
&value 
    %end; 
  %end; 
  %else %do; 
&value 
  %end; 
%mend endwith;
