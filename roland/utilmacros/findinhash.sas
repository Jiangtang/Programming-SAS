/*<pre><b>
/ Program   : findinhash.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 29-Apr-2014
/ Purpose   : In-datastep macro to call a hash object
/ SubMacros : none
/ Notes     : This macro should be used in a data step along with the
/             %makehash macro as shown in the usage notes. A numeric variable
/             named "_rc" that receives the return code is created and can be
/             dropped from the output dataset using a DROP statement.
/ Usage     : data test2;
/               %findinhash(class,sashelp.class,name age,sex height weight);
/               set test;
/               %findinhash(class);
/               DROP _rc;
/             run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ hashname          (pos) Name of the hash object to call (unquoted)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Apr14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: findinhash v1.0;

%macro findinhash(hashname);
_rc=&hashname..find();
%mend findinhash;
