/*<pre><b>
/ Program   : dropend.sas
/ Version   : 1.2
/ Author    : Roland Rashleigh-Berry
/ Date      : 16-Apr-2013
/ Purpose   : Function-style macro to drop the end of a string along with the
/             specified delimiter.
/ SubMacros : none
/ Notes     : You would typically run this on a path name where you want to drop
/             the last segment and perhaps replace the last segment with another
/             string (see usage notes).
/
/             prxchange is used but your delimiter will be automatically 
/             escaped if required.
/
/             If the delimiter is a round bracket then you will both have to use
/             %nrbqoute() on the string and macro quote the round bracket
/             delimiter using %str(%() or %str(%)).
/
/             If the delimiter is a comma then you will have to use %nrbquote()
/             on the string and macro quote the comma delimiter using %str(,) .
/
/ Usage     : %let str=aaa\bbb\cccc\ddddd\eeee\pgm;
/             %put >>>>> %dropend(&str,\)\data;
/       >>>>> aaa\bbb\cccc\ddddd\eeee\data
/
/             %let str=aaa/bbb/cccc/ddddd/eeee/pgm;
/             %put >>>>> %dropend(&str,/)/data;
/       >>>>> aaa/bbb/cccc/ddddd/eeee/data
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) String
/ delim             (pos) Delimiter
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  08Apr13         new (v1.0)
/ rrb  09Apr13         Changed so that if the delimiter is the last character in
/                      the string then the dropped end will act on the next to
/                      last delimiter (v1.1)
/ rrb  16Apr13         A delimiter character that need escaping for regular
/                      expression purposes will be automatically escaped by
/                      having a backslash put in front of it (v1.2)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dropend v1.2;

%macro dropend(str,delim);
%if %index(\.$^[]*+%str(,%(%)),&delim) %then %let delim=\&delim;
%sysfunc(prxchange(s|(^.*)&delim..+$|\1|,-1,%nrbquote(&str)))
%mend dropend;
