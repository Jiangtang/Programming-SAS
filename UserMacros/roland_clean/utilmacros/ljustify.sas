/*<pre><b>
/ Program   : ljustify.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To left-justify all character fields in a dataset
/ SubMacros : none
/ Notes     : If there are no character variables in the input data set then it
/             will cause an error. Use %nvarsc to check that the number of
/             character variables is greater than zero, if unsure, before
/             calling this macro.
/ Usage     : %ljustify(dset)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) Input dataset
/ dsout             (pos) Output dataset (defaults to input dataset)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: ljustify v1.0;

%macro ljustify(dsin,dsout);

  %if not %length(&dsout) %then %let dsout=%scan(&dsin,1,%str(%());

  data &dsout;
    set &dsin;
    array _char {*} _character_;
    do _i=1 to dim(_char);
      _char(_i)=left(_char(_i));
    end;
    drop _i;
  run;

%mend ljustify;
  