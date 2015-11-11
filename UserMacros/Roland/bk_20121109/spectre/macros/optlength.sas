/*<pre><b>
/ Program   : optlength.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 29-Mar-2007
/ Purpose   : To create a length statement for character variables that take up
/             less length than that allotted to the variable.
/ SubMacros : %nvarsc
/ Notes     : The length statement will get written out to a global macro
/             variable. Only those character variables whose longest length is
/             less than the allotted length will be output. 
/ Usage     : optlength(dset)
/             data dset;
/               &_optlength_;
/               set dset;
/             run;
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) Input dataset
/ globvar=_optlength_ Name of global macro variable.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: optlength v1.0;

%macro optlength(dsin,globvar=_optlength_);

%global &globvar;
%let &globvar=;

%local nvarsc;
%let nvarsc=%nvarsc(%scan(&dsin,1,%str(%()));
%if not &nvarsc %then %goto exit;

data _null_;
  set &dsin end=last;
  array _char {*} _character_;
  length _str $ 32767;
  array _length {&nvarsc} 8 _temporary_ (&nvarsc*1);
  do _i=1 to dim(_char);
    if length(_char(_i))>_length(_i) then _length(_i)=length(_char(_i));
  end;
  if last then do;
    _str='length';
    do _i=1 to dim(_char);
      if _length(_i)<vlength(_char(_i)) then _str=trim(_str)||' '||trim(vname(_char(_i)))||
      ' $ '||compress(put(_length(_i),5.));
    end;
    if _str NE 'length' then call symput("&globvar",trim(_str));
  end;
run;

%exit:
%mend;
  