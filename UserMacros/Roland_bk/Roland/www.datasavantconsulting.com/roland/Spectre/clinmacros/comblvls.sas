/*<pre><b>
/ Program   : comblvls.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 26-Dec-2011
/ Purpose   : To combine levels data from the %freqlvls macro
/ SubMacros : %splitvar
/ Notes     : This macro expects the variables LVL1ORD, LVL1, LVL2ORD etc. as
/             created by the %freqlvls macro and will combine the LVLn values
/             and write them indented by level to the COMBLVLS variable with
/             split characters. Note that the %splitvar macro only works for
/             Western character sets where one letter uses one byte. See the
/             header of that macro for more information.
/ Usage     : %comblvls(dsin=myds,lvls=5,varlen=256,colw=50)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) Input dataset
/ lvls              (pos) Number of levels
/ colw              (pos) column width of the display column for splitting
/ dsout             Output dataset
/ indent=3          Indentation of each level
/ hindent=0         Hanging indent for overflowing text
/ varlen=256        Length of COMBLVLS variable
/ split=@           Split character
/ usecolon=yes      By default, if ": " occurs in the string start within 30% of
/                   the defined width then use this to align following line
/                   segments.
/ byvars            By variables (optional)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  27Oct11         New (v1.0)
/ rrb  26Dec11         Header updated regarding Western character sets
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: comblvls v1.0;

%macro comblvls(dsin,
                lvls,
                colw,
               dsout=,
              indent=3,
             hindent=0,
              varlen=256,
               split=@,
            usecolon=yes,
              byvars=
                );

  %local i err errflag;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (comblvls) No dataset specified as the first positional parameter;
  %end;

  %if not %length(&lvls) %then %do;
    %let errflag=1;
    %put &err: (comblvls) No levels count specified as the second positional parameter;
  %end;

  %if not %length(&colw) %then %do;
    %let errflag=1;
    %put &err: (comblvls) No display colw specified as the third positional parameter;
  %end;

  %if &errflag %then %goto exit;

  %if not %length(&dsout) %then %let dsout=&dsin;

  %if not %length(&varlen) %then %let varlen=256;

  %if not %length(&indent) %then %let indent=3;

  %if not %length(&hindent) %then %let hindent=0;

  proc sort data=&dsin;
    by &byvars
      %do i=1 %to &lvls;
        lvl&i.ord
      %end;
      ;
  run;

  data &dsout;
    length comblvls $ &varlen;
    set &dsin;
    by &byvars
    %do i=1 %to &lvls;
      lvl&i.ord
    %end;
    ;
    if first.lvl1ord then comblvls=lvl1;
    %do i=2 %to %eval(&lvls-1);
      else if first.lvl&i.ord then comblvls=repeat(" ",&indent*%eval(&i-1)-1)||lvl&i;
    %end;
    else comblvls=repeat(" ",&indent*%eval(&lvls-1)-1)||lvl&lvls;
    %splitvar(comblvls,,&colw,split=&split,hindent=&hindent,usecolon=&usecolon)
  run;

  %goto skip;
  %exit: %put &err: (comblvls) Leaving macro due to problem(s) listed;
  %skip:
 
%mend comblvls;
