/*<pre><b>
/ Program   : optlength.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 02-Apr-2013
/ Purpose   : To create an optimized LENGTH statement for character variables
/             that take up less length than that allotted to the variables.
/ SubMacros : %nvarsc
/ Notes     : This macro is useful for saving space taken up by uncompressed
/             datasets. It will read through the entire dataset to detect the
/             maximum length actually used by every character variables and
/             where this is less than the allotted length will generate a
/             syntactically correct LENGTH statement and write it to a global
/             macro variable such that it can be resolved in a subsequent data
/             step to adjust the length of the variables (see usage notes).
/
/             A "drop" modifier can be assigned to the dataset such that some
/             variables can be excluded from this optimization calculation such
/             as --TESTCD variables (see usage notes).
/
/             If all character variables are already of optimum length then the
/             global macro variable will contain a null string which will have
/             no effect in a subsequent automatic optimizing data step (if used
/             as shown in the usage notes).
/
/             This macro writes changed lengths out to a dataset in addition to
/             writing to a global macro variable. This is to allow the user more
/             control for keeping the variable order the same as the original
/             since the output dataset can be used to update a "contents" style
/             dataset which can then be used to generate a data structure using
/             the %lstattrib macro and so maintain the original order of the
/             variables.
/
/ Usage     : %optlength(dset(drop=vstestcd));
/             data dset2;
/               &_optlength_;
/               set dset;
/             run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) Input dataset
/ globvar=_optlength_     Name of global macro variable.
/ dsout=_optlens          Output dataset 
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  02Apr13         dsout= parameter added so that changed lengths are also
/                      written to a dataset with variable names "name", "length"
/                      and "old_length" (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: optlength v2.0;

%macro optlength(dsin,globvar=_optlength_,dsout=_optlens);

  %local nvarsc wrn savopts;
  %let wrn=WAR%str(NING);
  %let savopts=%sysfunc(getoption(NOTES));
  options nonotes;

  %if not %length(&globvar) %then %let globvar=_optlength_;
  %global &globvar;
  %let &globvar=;

  %if not %length(&dsout) %then %let dsout=_optlens;

  %let nvarsc=%nvarsc(%scan(&dsin,1,%str(%()));

  %if not &nvarsc %then %do;
    %put &wrn: (optlength) No character variables detected in &dsin so macro will exit;
    %goto exit;
  %end;

  data &dsout(rename=(_name=name _newlen=length _oldlen=old_length));
    set &dsin end=last;
    array _char {*} _character_;
    length _name $ 32 _oldlen _newlen 8;
    length _str $ 32767;
    array _length {&nvarsc} 8 _temporary_ (&nvarsc*1);
    do _i=1 to dim(_char);
      if length(_char(_i))>_length(_i) then _length(_i)=length(_char(_i));
    end;
    if last then do;
      _str='LENGTH';
      do _i=1 to dim(_char);
        _name=vname(_char(_i));
        _oldlen=vlength(_char(_i));
        _newlen=_length(_i);
        if _newlen<_oldlen then do;
          _str=trim(_str)||' '||trim(_name)||' $ '||compress(put(_newlen,5.));
          output;
        end;
      end;
      if _str NE 'LENGTH' then call symput("&globvar",trim(_str));
    end;
    KEEP _name _oldlen _newlen;
  run;

  *- sort in name order for later update purposes -;
  proc sort data=&dsout;
    by name;
  run;

  %exit:

  options &savopts;

%mend optlength;
