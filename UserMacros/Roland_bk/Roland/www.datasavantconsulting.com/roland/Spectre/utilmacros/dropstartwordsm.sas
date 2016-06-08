/*<pre><b>
/ Program   : dropstartwordsm.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-Nov-2014
/ Purpose   : Function-style macro to drop any of a list of words that might
/             start a macro string and be followed by at least one space
/             character.
/ SubMacros : none
/ Notes     : This macro makes it easier to use the prxchange function to drop
/             starting words in a macro string where those words must be
/             followed by a space and might be followed by more spaces. The
/             start word(s) and spaces either side will be dropped.
/
/             The word(s) specified to be dropped must be given as the second
/             positional parameter value and for multiple words, they must be
/             separated by the "|" ("or") character and no spaces are allowed
/             between the words. The words are not case sensitive so all forms
/             of the specified words casewise will be dropped.
/
/             Depending on the macro string, you might have to use the
/             %nrbquote() macro function to mask characters (especially commas
/             and round brackets).
/
/             To simplify the call to this macro for common start words then
/             define a shell macro to call this macro that specifies these
/             start words as is done in the usage notes.
/
/ Usage     : %macro noifwherem(str);
/             %dropstartwordsm(&str,IF|WHERE)
/             %mend noifwherem;
/
/             %let str=   If   a=b, and c=c;
/             %let str2=%noifwherem(%nrbquote(&str));
/             %put ####STR2=&str2;
/
/             ####STR2=a=b, and c=c
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ string            (pos) Literal text or a resolved macro variable to drop the
/                   start word(s) from.
/ words             (pos) Word or words separated by the "|" ("or") character to
/                   be dropped from the start of the macro string. No spaces are
/                   allowed between the words and the "|" separator.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  04Nov14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dropstartwordsm v1.0;

%macro dropstartwordsm(string,words);
%sysfunc(prxchange(s/^\s*(&words)\s+//i,1,&string))
%mend dropstartwordsm;
