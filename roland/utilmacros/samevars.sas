/*<pre><b>
/ Program   : samevars.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 25-Apr-2013
/ Purpose   : Function-style macro to return true (1) or false (0) if variables
/             in one dataset have the same variables and of the same type as
/             those in another dataset.
/ SubMacros : %hasvarsc %hasvarsn
/ Notes     : Use this on datasets where the combined variable count is 40 or
/             less due to the large amount of macro looping.
/ Usage     : %if not %samevars(dset1,dset2) %then %do....
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dset1             (pos) First dataset for comparison of variables
/ dset2             (pos) Second dataset for comparison of variables
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  25Apr13         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: samevars v1.0;

%macro samevars(dset1,dset2);
  %if %hasvarsc(&dset1,%varlistc(&dset2)) 
  and %hasvarsc(&dset2,%varlistc(&dset1))
  and %hasvarsn(&dset1,%varlistn(&dset2)) 
  and %hasvarsn(&dset2,%varlistn(&dset1))
  %then 1;
  %else 0;
%mend samevars;
