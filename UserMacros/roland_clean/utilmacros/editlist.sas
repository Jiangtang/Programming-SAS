/*<pre><b>
/ Program   : editlist.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 01-Nov-2012
/ Purpose   : Function-style macro to allow you to edit a list of space 
/             delimited items.
/ SubMacros : none
/ Notes     : This macro is for tasks like generating rename statements where a
/             repeat of items in a list is required (see usage notes). The edit
/             string must be enclosed in single quotes. Elements of the list
/             are written to the macro variable "item" which can be referenced
/             in the edit string. If semicolons form part of the edit string
/             then for certain uses these can be protected using %nrstr().
/
/             If used in sas code you might need to %unquote() the final string.
/
/             This macro is essentially the same as the %doallitem macro but
/             giving a different usage emphasis and with no submacros.
/
/ Usage     : %put >>> %editlist(aa bb cc dd,'&item=mr_&item');
/             %put >>> %editlist(xx_aa xx_bb xx_cc,
/             '&item=%substr(&item,4)');
/             %put >>> %editlist(xx_aa xx_bb xx_cc,
/             '%substr(&item,4)=&item%nrbquote(;)');
/
/             (will write to log:)
/             >>> aa=mr_aa bb=mr_bb cc=mr_cc dd=mr_dd
/             >>> xx_aa=aa xx_bb=bb xx_cc=cc
/             >>> aa=xx_aa; bb=xx_bb; cc=xx_cc;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ list              (pos) List of space delimited items
/ editstr           (pos) Edit string (in single quotes)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  31Oct12         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: editlist v1.0;

%macro editlist(list,editstr);
  %local i item;
  %let i=1;
  %let item=%scan(&list,&i,%str( ));
  %do %while(%length(&item));
%sysfunc(dequote(&editstr))
    %let i=%eval(&i + 1);
    %let item=%scan(&list,&i,%str( ));
  %end;
%mend editlist;
