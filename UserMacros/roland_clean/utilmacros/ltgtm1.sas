/*<pre><b>
/ Program   : ltgtm1.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : In-datastep macro to turn a text numeric value into a numeric
/             value and handle "<" and ">" signs preceding and adjust the value
/             according to a rule (method 1).
/ SubMacros : none
/ Notes     : The numeric adjustment done where values beging with "<" or ">"
/             may not be the "standard" method for your site. You should
/             ascertain whether a standard method already exists for handling
/             this situation and use that method unless you have special cause
/             to use this macro. This should be used in a data step.
/
/             This macro name ends with "m1" to singify "method 1". If you want
/             to implement a different algorithm then create extra macros with
/             different method ending numbers.
/
/             The essence of the algorithm used here is to add one or subtract
/             one from the value for a '>' or '<' sign respectively but to take
/             into account the number of decimal places in the orginal text 
/             value. <1 will be set to 0.9 and >0 will be set to 0.1 .
/
/ Usage     : %ltgtm1(textvar,numvar);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ textvar           (pos) Text variable containing number
/ numvar            (pos) Numeric variable to contain result
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/ rrb  28Sep08         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: ltgtm1 v1.0;

%macro ltgtm1(textvar,numvar);

  *- set up working variable -;
  length _tempstr $ 20 _sign $ 1;

  *- left-align original text and place into temporary variable -;
  _tempstr=compress(&textvar,' ');

  *- set preceding sign to blank -;
  _sign=' ';

  *- set sign if required and remove from source -;
  if substr(_tempstr,1,1) in ('<','>') then do;
    _sign=substr(_tempstr,1,1);
    _tempstr=substr(_tempstr,2);
  end;

  *- chop off spurious trailing characters -;
  if verify(_tempstr,'0123456789.,')>1 
    then _tempstr=substr(_tempstr,1,verify(_tempstr,'0123456789.,')-1);

  *- count number of decimal points -;
  if scan(_tempstr,2,'.')=' ' then _dp=0;
  else _dp=length(scan(_tempstr,2,'.'));

  *- set to numeric value -;
  &numvar=input(_tempstr,comma20.);

  *- treat for "<" sign -;
  if _sign='<' then do;
    if _dp=0 and &numvar in (1,0) then &numvar=&numvar-0.1;
    else &numvar=&numvar-10**-_dp;
  end;

  *- treat for ">" sign -;
  else if _sign='>' then do;
    if _dp=0 and &numvar in (0,-1) then &numvar=&numvar+0.1;
    else &numvar=&numvar+10**-_dp;
  end;

  *- drop temporary variables -;
  drop _dp _sign _tempstr;

%mend ltgtm1;
