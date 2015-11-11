/*<pre><b>
/ Program   : nocommas.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 27-May-2014
/ Purpose   : Function-style macro to translate commas into spaces
/ SubMacros : none
/ Notes     : No attempt is made to "tidy up" after the commas have been
/             translated into spaces. A simple replacement of every comma with a
/             space is performed. This macro can be used inside another macro
/             call to remove commas before the outer macro start to work.
/
/             This macro should not use the parameter= convention. It should be
/             used with a purely positional parameter value only.
/
/ Usage     : %let str=aa, bb, cc;
/             %put >>> %nocommas(&str);
/             >>> aa  bb  cc
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (only positional) String to translate commas into spaces
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  27May14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: nocommas v1.0;

%macro nocommas/parmbuff;
%qsubstr(%sysfunc(translate(&syspbuff,%str( ),%str(,))),2,%length(&syspbuff)-2)
%mend nocommas;
