/*<pre><b>
/ Program   : qcmedian.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 18-Jan-2012
/ Purpose   : To QC the setting of MEDIAN repeat values
/ SubMacros : %qcmean
/ Notes     : This is a dummy macro that calls %qcmean
/
/ Limitations:
/
/
/ Usage     : %qcmedian(_lab3,_lab4)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ inlab             (pos) Input lab dataset (no modifiers)
/ outlab            (pos) Output lab dataset (no modifiers)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  18Jan12         New (v1.0)
/=============================================================================*/

%put MACRO CALLED: qcmedian v1.0;


%macro qcmedian(inlab,outlab);

  %qcmean(&inlab,&outlab,stat=median,reptval=2);

%mend qcmedian;