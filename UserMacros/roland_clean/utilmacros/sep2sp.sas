/*<pre><b>
/ Program   : sep2sp.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 26-Mar-2013
/ Purpose   : Function-style macro to convert groups of commas and spaces in a
/             string to single spaces.
/ SubMacros : none
/ Notes     : "sep2sp" is best remembered as "separators" to "spaces" where the
/             separators are groups of spaces and commas that will each be
/             replaced by a single space. If your string contains commas then
/             you should surround the string with %nrbquote() when calling this
/             macro.
/ Usage     : %let newstr=%sep2sp(%nrbquote(a  , b,    ,,, c));
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) String to convert
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  26Mar13         new (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: sep2sp v1.0;

%macro sep2sp(str);
%sysfunc(prxchange(s|[%str( )%str(,)]+|%str( )|,-1,%nrbquote(&str)))
%mend sep2sp;

