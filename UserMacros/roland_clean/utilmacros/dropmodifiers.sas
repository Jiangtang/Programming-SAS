/*<pre><b>
/ Program   : dropmodifiers.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 11-Jun-2013
/ Purpose   : In-datastep macro to remove the dataset modifiers from a variable
/             that contains single or multiple dataset names with possible
/             modifiers.
/ SubMacros : none
/ Notes     : Use this to strip out modifiers so you can identify datasets so
/             that you can run checks on them like check that they exist in
/             dictionary.tables . The result gets written back into the source
/             variable.
/ Usage     : data test;
/               set dset(keep=sourcedata domain);
/               %dropmodifiers(sourcedata);
/               *- now process the pure dataset names in sourcedata -;
/               put sourcedata=;
/             run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) Variable containing dataset names with modifiers
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  11Jun13         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: dropmodifiers v1.0;

%macro dropmodifiers(str);
  *- non-greedy replace stuff in double quotes with "§" -;
  &str=prxchange('s/".*?"/"§"/',-1,&str);
  *- non-greedy replace stuff in single quotes with '§' -;
  &str=prxchange("s/'.*?'/'§'/",-1,&str);
  *- repeat until we have no more left round brackets   -;
  do while(index(&str,'('));
    *- Non-greedy replace stuff inside "( )" that does  -;
    *- not include a left round bracket with null.      -;
    &str=prxchange('s/\([^\(]*?\)//',-1,&str);
  end;
%mend dropmodifiers;
