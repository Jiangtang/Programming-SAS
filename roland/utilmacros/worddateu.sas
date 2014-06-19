/*<pre><b>
/ Program   : worddateu.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 24-Aug-2012
/ Purpose   : Function-style macro to convert a date in the form "date"D to a 
/             worddate format string with groups of commas and spaces changed to
/             single underscores.
/ SubMacros : %worddate %sep2u
/ Notes     : The "strip" function is used to strip leading and trailing spaces
/             so you need sas v9.2 or higher. 
/ Usage     : %let worddateu=%worddateu("&sysdate9"D);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ date              (pos) Date in the form "date"D (defaults to current date)
/ format=worddate20.      Default format for the worddate is worddate20.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  24Aug12         new (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: worddateu v1.0;

%macro worddateu(date,format=worddate20.);
%if not %length(&date) %then %let date="&sysdate9"D;
%if not %length(&format) %then %let format=worddate20.;
%sep2u(%nrbquote(%worddate(&date,format=&format)))
%mend worddateu;
