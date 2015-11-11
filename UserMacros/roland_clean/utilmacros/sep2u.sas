/*<pre><b>
/ Program   : sep2u.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 24-Aug-2012
/ Purpose   : Function-style macro to convert groups of commas and spaces in a
/             string to single underscores.
/ SubMacros : none
/ Notes     : "sep2u" is best remembered as "separators" to "underscores" where
/             the separators are groups of spaces and commas that will each be
/             replaced by a single underscore. If your string contains commas
/             then you should surround the string with %nrbquote() when calling
/             this macro.
/ Usage     : %let newstr=%sep2u(%nrbquote(a  , b,    ,,, c));
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) String to convert
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  24Aug12         new (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: sep2u v1.0;

%macro sep2u(str);
%sysfunc(prxchange(s|[%str( )%str(,)]+|%str(_)|,-1,%nrbquote(&str)))
%mend sep2u;
