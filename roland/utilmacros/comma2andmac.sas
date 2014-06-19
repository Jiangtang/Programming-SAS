/*<pre><b>
/ Program   : comma2andmac.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to replace the last comma-space in a string
/             with " and ".
/ SubMacros : none
/ Notes     : 
/ Usage     : %let newstr=%comma2andmac(&oldstr);
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) string with commas in to change
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  10Feb12         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: comma2andmac v1.0;

%macro comma2andmac / parmbuff;
  %if %length(&syspbuff) GT 2 %then %do;
    %local buff;
    %let buff=%qsubstr(&syspbuff,2,%length(&syspbuff)-2);
%unquote(%sysfunc(prxchange(s/^(.*)(%str(, ))(.*$)/$1 and $3/,1,&buff)))
  %end;
%mend comma2andmac;

