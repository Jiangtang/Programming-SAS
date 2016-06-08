/*<pre><b>
/ Program   : qcrrcat.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 23-Jan-2012
/ Purpose   : To generate the coded ranges and labels from RRCAT
/ SubMacros : %words
/ Notes     : The coded ranges and labels as a result of the RRCAT value are
/             returned to two macro variables that must exist outside this
/             macro. The segments will be delimited by a / slash just as is
/             used for the RRCAT string. The label segments will each be in
/             double quotes.
/
/ Limitations:
/
/
/ Usage     : %let mr=;
/             %let ml=;
/             %qcrrcat(-0.25 / -0.5 / -1 / 1 / 4,mr,ml);
/             %put mr=&mr;
/             %put ml=&ml;
/
/ mr=LAB < 0.25*LL/0.25*LL <= LAB < 0.5*LL/0.5*LL <= LAB < LL/LL <= LAB <= UL/
/ UL < LAB <= 4*UL/LAB > 4*UL
/ ml="< 0.25*LL"/"[0.25*LL, 0.5*LL)"/"[0.5*LL, LL)"/"[LL, UL]"/"(UL, 4*UL]"/
/ "> 4*UL"
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ rrcat             (pos) RRCAT value (not quoted)
/ mrange            (pos) Name of macro variable to receive the coded ranges
/ mlabel            (pos) Name of macro variable to receive the range labels
/ ll=LL             Variable name for the lower limit (defaults to LL)
/ ul=UL             Variable name for the upper limit (defaults to UL)
/ lab=LAB           Variable name for the lab value  (defaults to LAB)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  23Jan12         New (v1.0)
/=============================================================================*/

%put MACRO CALLED: qcrrcat v1.0;

%macro qcrrcat(rrcat,
              mrange,
              mlabel,
                  ll=LL,
                  ul=UL,
                 lab=LAB
               );

  %local i err errflag parts limit part iplus op1 op2 br1 br2 ;
  %let err=ERR%str(OR);
  %let errflag=0;


  %if not %length(&rrcat) %then %do;
    %let errflag=1;
    %put &err: (qcrrcat) No RRCAT string supplied as first parameter;
  %end;

  %if not %length(&mrange) %then %do;
    %let errflag=1;
    %put &err: (qcrrcat) No range macro variable name supplied as second parameter;
  %end;

  %if not %length(&mlabel) %then %do;
    %let errflag=1;
    %put &err: (qcrrcat) No label macro variable name supplied as third parameter;
  %end;

  %if &errflag %then %goto exit;


  %let parts=%words(&rrcat,delim=/);

  %*- store the segments for use in the code and labels -;
  %do i=1 %to &parts;
    %local seg&i;
    %let part=%scan(&rrcat,&i,/);
    %if %sysevalf(&part LT 0) %then %let limit=&ll;
    %else %let limit=&ul;
    %let part=%sysfunc(abs(&part));
    %if &part NE 1 %then %let seg&i=&part*&limit;
    %else %let seg&i=&limit;
  %end;

  %*- start of the ranges and labels -;
  %let &mrange=&lab < &seg1;
  %let &mlabel= "  < &seg1";

  %*- loop through and add ranges and labels -;
  %do i=1 %to &parts;
    %let iplus=%eval(&i+1);
    %if %index(&&seg&i,&ll) %then %do;
      %let op1=<=;
      %let br1=[;
    %end;
    %else %do;
      %let op1=<;
      %let br1=%str(%();
    %end;
    %if &iplus LE &parts %then %do;
      %if %index(&&seg&iplus,&ul) %then %do;
        %let op2=<=;
        %let br2=];
      %end;
      %else %do;
        %let op2=<;
        %let br2=%str(%));
      %end;
    %end;
    %if &iplus GT &parts %then %do;
      %let &mrange=&&&mrange/&lab > &&seg&i;
      %let &mlabel=&&&mlabel/"    > &&seg&i";
    %end;
    %else %do;
      %let &mrange=&&&mrange/&&seg&i &op1 &lab &op2 &&seg&iplus;
      %let &mlabel=&&&mlabel/"&br1.&&seg&i, &&seg&iplus&br2";
    %end;
  %end;

  %goto skip;
  %exit: %put &err: (qcrrcat) Leaving macro due to problem(s) listed;
  %skip:

%mend qcrrcat;
