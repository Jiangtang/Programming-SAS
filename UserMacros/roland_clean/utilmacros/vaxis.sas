/*<pre><b>
/ Program   : vaxis.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To generate the values to construct a vaxis scale
/ SubMacros : none
/ Notes     : It does not matter if you get the min and max values the wrong way
/             round. This will be detected and fixed. The global macro variables
/             populated are _from_, _to_, _by_, _format_ and _nminor_.
/ Usage     : %vaxis(&min,&max,spare=1)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ min               (pos) Text minimum value (unquoted)
/ max               (pos) Text maximum value (unquoted)
/ minticks=5        Minimum number of major tick marks to show on the axis
/ spare=0           Number of major tick mark divisions to leave spare at the
/                   top for annotation.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: vaxis v1.0;

%macro vaxis(min,max,minticks=5,spare=0);

  %local swap;
  %global _from_ _to_ _by_ _format_ _nminor_;


  %if %sysevalf(&max < &min) %then %do;
    %let swap=&min;
    %let min=&max;
    %let max=&swap;
  %end;

  %if not %length(&spare) %then %let spare=0;
  %let minticks=%eval(&minticks-&spare-1);

  data _null_;
    length fmt $ 5;
    retain ld rd 0;
    x=int(log10((&max-&min)/&minticks))+1;
    _by=10**x;
    _nminor=4;
    if (ceil(&max/_by)*_by-floor(&min/_by)*_by)/_by < &minticks then do;
      _by=5*10**(x-1);
      _nminor=3;
    end;
    if (ceil(&max/_by)*_by-floor(&min/_by)*_by)/_by < &minticks then do;
      _by=2*10**(x-1);
      _nminor=3;
    end;
    if (ceil(&max/_by)*_by-floor(&min/_by)*_by)/_by < &minticks then do;
      _by=10**(x-1);
      _nminor=4;
    end;
    if (ceil(&max/_by)*_by-floor(&min/_by)*_by)/_by < &minticks then do;
      _by=5*10**(x-2);
      _nminor=3;
    end;
    if (ceil(&max/_by)*_by-floor(&min/_by)*_by)/_by < &minticks then do;
      _by=2*10**(x-2);
      _nminor=3;
    end;
    _from=floor(&min/_by)*_by;
    _to=ceil(&max/_by)*_by;
    if &spare GT 0 then _to=_to+(&spare*_by);
    do i=_from to _to by _by;
      if length(left(scan(put(i,best16.),1,'.'))) > ld 
        then ld=length(left(scan(put(i,best16.),1,'.')));
      if scan(put(i,best16.),2,'.') NE ' ' then do;
        if length(left(scan(put(i,best16.),2,'.'))) > rd 
          then rd=length(left(scan(put(i,best16.),2,'.')));
      end;
    end;
    if rd>0 then fmt=compress(put(ld+rd+1,2.))||'.'||compress(put(rd,2.));
    else fmt=compress(put(ld,2.))||'.';
    call symput('_to_',trim(left(putn(_to,fmt))));
    call symput('_from_',trim(left(putn(_from,fmt))));
    call symput('_by_',compress(put(_by,best12.)));
    call symput('_format_',trim(left(fmt)));
    call symput('_nminor_',put(_nminor,1.));
  run;

%mend vaxis;
  