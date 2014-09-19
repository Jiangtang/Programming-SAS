%macro menu_cust;

/*
 * Title:   Menu command customization report
 * Purpose: Report SAS Explorer menu commands found in SASUSER that differ from those in SASHELP
 * Author:  Richard A. DeVenezia
 * Date:    feb05
 *
 * Notes:   Some commands in SASUSER may have different action names,
 *          this information is not reported.
 */

filename xS catalog 'work.explorer.system.source' lrecl=500;
filename xU catalog 'work.explorer.user.source' lrecl=500;

proc registry export=xS startat='CORE\EXPLORER\MENUS' usesashelp;
proc registry export=xU startat='CORE\EXPLORER\MENUS' ;

run;

data xS;
  infile xS;
  input;

  length path line $500;
  line = _infile_;

  retain path;
  if line =: '[' then path = line;

  if line ne '' and line ne: '#';

  drop p;
  p = index(line,'=');
  if p then do;
    action  = substr(line,1,p-1);
    command = substr(line,p+1);
  end;
run;
filename xS;

data xU;
  infile xU;
  input;

  length path line $500;
  line = _infile_;

  retain path;
  if line =: '[' then path = line;

  if line ne '' and line ne: '#';

  drop p;
  p = index(line,'=');
  if p then do;
    action  = substr(line,1,p-1);
    command = substr(line,p+1);
  end;
run;
filename xU;

proc sort data=xS; by path command;
proc sort data=xU; by path command;
run;

data deltaCommand;
  merge xS(in=system) xU(in=user) end=end;
  by path command;

  if user and not system then do;
    count+1;
    output;
  end;

  if end and count < 1 then do;
    path = 'No customizations found.';
    action = 'None';
    command = 'No customizations found.';
    output;
  end;
run;

proc sort;
  by path action;
run;


filename _temp1_ temp;

ods html style=sasweb body="%sysfunc(pathname(_temp1_)).html";
ods escapechar = '^';

title  '^R/HTML"<HR>"SAS Explorer :: Action Command customizations in SASUSER registry';
title2 "- %sysfunc(pathname(SASUSER))";
footnote "Registry data that differs from SASHELP";

options nocenter;

proc print noobs data=deltaCommand ;
  by path;
  var action command;
run;


title;
footnote;

filename _temp1_;
%mend menu_cust;
