/*<pre><b>
/ Program   : dropstartwords.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-Nov-2014
/ Purpose   : In-datastep function-style macro to drop any of a list of words
/             that might start a string and be followed by at least one space
/             character.
/ SubMacros : none
/ Notes     : This macro makes it easier to use the prxchange function to drop
/             starting words in a string where those words might be preceded by
/             spaces at the start of the string, must be followed by a space and
/             might be followed by more spaces. The start word(s) and spaces
/             either side will be dropped.
/
/             The word(s) specified to be dropped must be given as the second
/             positional parameter value and for multiple words, they must be
/             separated by the "|" ("or") character and no spaces are allowed
/             between the words. The words are not case sensitive so all forms
/             of the specified words casewise will be dropped.
/
/             To simplify the call to this macro for common start words then
/             define a shell macro to call this macro that specifies these
/             start words as is done in the usage notes.
/
/ Usage     : %macro noifwhere(str);
/             %dropstartwords(&str,IF|WHERE)
/             %mend noifwhere;
/
/             data _null_;
/               str="   If   a=b, and c=c";
/               str2=%noifwhere(str);
/               put '####' str2=;
/             run;
/
/             ####STR2=a=b, and c=c
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ string            (pos) Literal text in quotes or name of a character variable
/                   to drop the start word(s) from.
/ words             (pos) Word or words separated by the "|" ("or") character to
/                   be dropped from the start of the string. No spaces are
/                   allowed between the words and the "|" separator.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  04Nov14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dropstartwords v1.0;

%macro dropstartwords(string,words);
prxchange("s/^\s*(&words)\s+//i",1,&string)
%mend dropstartwords;
