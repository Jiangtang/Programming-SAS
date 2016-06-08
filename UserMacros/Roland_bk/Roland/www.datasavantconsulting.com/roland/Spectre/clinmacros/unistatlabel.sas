/*<pre><b>
/ Program      : unistatlabel.sas
/ Version      : 1.1
/ Author       : Roland Rashleigh-Berry
/ Date         : 21-Apr-2013
/ Purpose      : Clinical reporting utility macro to replace _statlabel values
/                in the %unistats output dataset.
/ SubMacros    : none
/ Notes        : You are allowed to amend this macro to add or change the 
/                the replacement of _statlabel values in the %unistats output
/                dataset. If you do you should change the "MACRO CALLED" message
/                to say you are running a local version. You might want to put
/                your own copy of the macro in a folder defined to the sasautos
/                path such that it takes precedence over the original version.
/
/                Alternatively you can create other versions of this macro with
/                a different name and define the name of the macro to the
/                statlabelmacro= parameter when you call %unistats. It is
/                possible that you will have a different macro for each sponsor
/                such that statistic labels for paired statistics matches their
/                preferences.
/
/ Usage        : N/A
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ N/A
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  09Jun11         Header tidy
/ rrb  28Aug11         CIs of the spread of values added (v1.1)
/ rrb  21Apr13         Macro status changed to clinical reporting utility macro
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/
 
%put MACRO CALLED: unistatlabel v1.1;
%*-- Note that if you have amended this macro then you should change the --;
%*-- above line to make it clear you are running a local version such as --;
%*-- change it to "unistatlabel (local) v1.0" --;

%macro unistatlabel;
       if upcase(_statlabel) EQ "PROBN"           then _statlabel="Prob Norm";
  else if upcase(_statlabel) EQ "PROBM"           then _statlabel="Prob >=|M|";
  else if upcase(_statlabel) EQ "PROBS"           then _statlabel="Prob >=|S|";
  else if upcase(_statlabel) EQ "PROBT"           then _statlabel="Prob > |t|";
  else if upcase(_statlabel) EQ "MSIGN"           then _statlabel="M(Sign)";
  else if upcase(_statlabel) EQ "SIGNRANK"        then _statlabel="Sign Rank";
  else if upcase(_statlabel) EQ "USS"             then _statlabel="Uncorr. SSQ";
  else if upcase(_statlabel) EQ "CSS"             then _statlabel="Corr. SSQ";
  else if upcase(_statlabel) EQ "SUMWGT"          then _statlabel="Sum of weights";
  else if upcase(_statlabel) EQ "QRANGE"          then _statlabel="Q3 - Q1";
  else if upcase(_statlabel) EQ "(LCLM75,UCLM75)" then _statlabel="75% CIs (Mean)";
  else if upcase(_statlabel) EQ "(LCLM90,UCLM90)" then _statlabel="90% CIs (Mean)";
  else if upcase(_statlabel) EQ "(LCLM92,UCLM92)" then _statlabel="92% CIs (Mean)";
  else if upcase(_statlabel) EQ "(LCLM,UCLM)"     then _statlabel="95% CIs (Mean)";
  else if upcase(_statlabel) EQ "(LCLM95,UCLM95)" then _statlabel="95% CIs (Mean)";
  else if upcase(_statlabel) EQ "(LCLM97,UCLM97)" then _statlabel="97% CIs (Mean)";
  else if upcase(_statlabel) EQ "(LCLM98,UCLM98)" then _statlabel="98% CIs (Mean)";
  else if upcase(_statlabel) EQ "(LCLM99,UCLM99)" then _statlabel="99% CIs (Mean)";
  else if upcase(_statlabel) EQ "(LCL75,UCL75)"   then _statlabel="75% CIs";
  else if upcase(_statlabel) EQ "(LCL90,UCL90)"   then _statlabel="90% CIs";
  else if upcase(_statlabel) EQ "(LCL92,UCL92)"   then _statlabel="92% CIs";
  else if upcase(_statlabel) EQ "(LCL,UCL)"       then _statlabel="95% CIs";
  else if upcase(_statlabel) EQ "(LCL95,UCL95)"   then _statlabel="95% CIs";
  else if upcase(_statlabel) EQ "(LCL97,UCL97)"   then _statlabel="97% CIs";
  else if upcase(_statlabel) EQ "(LCL98,UCL98)"   then _statlabel="98% CIs";
  else if upcase(_statlabel) EQ "(LCL99,UCL99)"   then _statlabel="99% CIs";
%mend unistatlabel;

