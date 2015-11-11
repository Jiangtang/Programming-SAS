/*<pre><b>
/ Program   : makehash.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 01-May-2014
/ Purpose   : In-datastep macro to set up a hash object
/ SubMacros : %cvarlens %quotelst %commas
/ Notes     : This macro MUST be used in a data step as shown in the usage
/             notes. Note especially that this macro is called BEFORE the SET
/             statement.
/
/             A numeric variable named "_rc" that receives the return code is
/             created and can be dropped from the output dataset using a DROP
/             statement (see usage notes).
/             
/ Usage     : data test2;
/               %makehash(class,sashelp.class,name age,sex height weight);
/               set test;
/               %findinhash(class);
/               DROP _rc;
/             run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ hashname          (pos) Name to give the hash object (unquoted)
/ ds                (pos) Dataset name (no modifiers)
/ keyvars           (pos) List of key variables separated by spaces
/ datavars          (pos) List of data variables separated by spaces
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Apr14         New (v1.0)
/ rrb  01May14         %cvarlens macro used in place of %varlens macro (v1.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: makehash v1.1;

%macro makehash(hashname,ds,keyvars,datavars);
LENGTH %cvarlens(&ds,&datavars);
if _n_=1 then do;
  declare hash &hashname(dataset: "&ds");
  _rc = class.defineKey(%commas(%quotelst(&keyvars)));
  _rc = class.defineData(%commas(%quotelst(&datavars)));
  _rc = class.defineDone();
  call missing(%commas(&datavars));
end;
%mend makehash;
