/*Delete all user-defined macro variables from the global symbol table*/
%macro delMacroVars;
  data vars;
    set sashelp.vmacro;
  run;

  data _null_;
    set vars;
    temp=lag(name);
    if scope='GLOBAL' and substr(name,1,3) ne 'SYS' and temp ne name then
      call execute('%symdel '||trim(left(name))||';');
  run;

%mend delMacroVars;
