/*<pre><b>
/ Program   : char2num.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 15-Mar-2013
/ Purpose   : To "effectively" convert a list of character variables to numeric
/ SubMacros : %words
/ Notes     : Converting variable types in SAS datasets is not allowed so this
/             macro will create new numeric variables having the same name as
/             the original character variables as well as the same label. You
/             might find the %numchars macro useful for identifying a list of
/             character variables with pure numeric content. All variables must
/             be specified as a space delimited list. Forms such as char: and 
/             char1-char12 are not allowed.
/
/             No modifiers in brackets are allowed against the input and output
/             data set names.
/ Usage     : %char2num(test,test2,cvar1 cvar2 cvar3 cvar4)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) Input data set (no modifiers in brackets allowed)
/ dsout             (pos) Output data set (no modifiers in brackets allowed)
/ vars              (pos) Character variables to convert to numeric
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  04May11         Code tidy
/ rrb  15Mar13         "old_" replaced by "OLD_" and upcase() used in comparison
/                      of variable labels plus header update (v1.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: char2num v1.1;

%macro char2num(dsin,dsout,vars);

  %local i w oldlist lib mem;

  %let w=%words(&vars);

  %if %length(%scan(&dsout,2,.)) %then %do;
    %let lib=%scan(&dsout,1,.);
    %let mem=%scan(&dsout,2,.);
  %end;
  %else %do;
    %let lib=;
    %let mem=&dsout;
  %end;

  %do i=1 %to &w;
    %let oldlist=&oldlist OLD_%scan(&vars,&i,%str( ));
  %end;

  data &dsout;
    length _execode $ 200;
    set &dsin(rename=(
    %do i=1 %to &w;
      %scan(&vars,&i,%str( ))=%scan(&oldlist,&i,%str( ))
    %end;
    )) end=last;
    %do i=1 %to &w;
      %scan(&vars,&i,%str( ))=input(%scan(&oldlist,&i,%str( )),comma32.);
    %end;

    if last then do;
      _execode="proc datasets nolist memtype=data ";
      call execute(_execode);
      %if %length(&lib) %then %do;
        _execode=" lib=&lib ;modify &mem;label ";
      %end;
      %else %do;
        _execode=";modify &mem;label ";
      %end;
      call execute(_execode);

      %do i=1 %to &w;
        if upcase(vlabel(%scan(&oldlist,&i,%str( )))) ne upcase("%scan(&oldlist,&i,%str( ))") then do;
          _execode=" %scan(&vars,&i,%str( ))=";
          call execute(_execode);
          _execode="'"||trim(tranwrd(vlabel(%scan(&oldlist,&i,%str( ))),"'","''"))||"'";
          call execute(_execode);
        end;
      %end;
      call execute(';run;quit;');
    end;

    drop &oldlist _execode;
  run;
  
%mend char2num;
