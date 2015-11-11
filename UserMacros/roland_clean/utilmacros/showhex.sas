/*<pre><b>
/ Program      : showhex.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-May-2011
/ Purpose      : To create a new dataset where hex characters in character
/                variables are highlighted.
/ SubMacros    : %varlistc %words
/ Notes        : Variables in the output dataset will have the same name as
/                those in the input dataset but they will be changed to show up
/                hex characters as hex numbers in < > brackets and the variable
/                length will be as defined to the length= parameter. If no
/                variable list is specified then all character variables are 
/                assumed. If badonly=yes then an extra variable named __obs is
/                retained in the output dataset set to the matching observation
/                number in the input dataset.
/ Usage        : %showhex(test1,test2,cvar1 cvar2 cvar3)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) name of inout dataset (no modifiers)
/ dsout             (pos) name of output dataset (no modifiers)
/ vars              (pos) (optional) character variables (separated by spaces)
/ length=200        Length of the new character variables in the output dataset
/ badonly=yes       By default keep only those observations where hex characters
/                   were found in one or more of the listed character variables.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: showhex v1.0;

%macro showhex(dsin,dsout,vars,length=200,badonly=yes);

  %local i var words errflag err;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&badonly) %then %let badonly=yes;
  %let badonly=%upcase(%substr(&badonly,1,1));
  %if not %length(&vars) %then %let vars=%varlistc(&dsin);


  %if not %length(&dsin) %then %do;
    %put &err: (showhex) No input dataset specified;
    %let errflag=1;
  %end;

  %if not %length(&dsout) %then %do;
    %put &err: (showhex) No output dataset specified;
    %let errflag=1;
  %end;

  %if &errflag %then %goto exit;


  %let words=%words(&vars);

  data &dsout;
    length __char $ 1 __temp1 __temp2 &vars $ &length;
    set &dsin(keep=&vars rename=(
              %do i=1 %to &words;
                %let var=%scan(&vars,&i,%str( ));
                &var=_&var
              %end;
              ));
    __bad=0;
    __obs=_n_;
    %do i=1 %to &words;
      %let var=%scan(&vars,&i,%str( ));
      __temp1=_&var;
      link conv;
      &var=__temp2;
    %end;
    %if "&badonly" EQ "Y" %then %do;
      if __bad then output;
    %end;
    %else %do;
      drop __obs;
    %end;
    drop __temp1 __temp2 __pos __rank __char __i __bad
      %do i=1 %to &words;
        %let var=%scan(&vars,&i,%str( ));
        _&var
      %end;
    ;
    return;
  conv:
    *- converts what is in __temp1 to __temp2 with hex expanded -;
    __temp2=' ';
    __pos=1;
    do __i=1 to length(__temp1);
      __char=substr(__temp1,__i,1);
      __rank=rank(__char);
      if __rank<0020x or __rank>00FFx then do;
      *if __rank<0020x or (007Ex < __rank < 00C0x) 
      and __rank not in (00B0x, 00B4x, 00B5x, 00AEx) then do;
        substr(__temp2,__pos,4)='<'||put(__rank,hex2.)||'>';
        __pos=__pos+4;
        __bad=1;
      end;
      else do;
        substr(__temp2,__pos,1)=__char;
        __pos=__pos+1;
      end;
    end;
  return;
  run;

  %goto skip;
  %exit: %put &err: (showhex) Leaving macro due to problem(s) listed;
  %skip:

%mend showhex;
