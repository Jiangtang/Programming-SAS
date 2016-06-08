%macro ut_mkdir(directory,drive);
%local os in_sdd;
%ut_os(verbose=0)
%if ^ %sysfunc(fileexist(&directory)) %then %do;
  %if &os = win %then %do;
    x "&drive:";
    x "mkdir &directory";
  %end;
  %else %if &os = unix %then %do;
    x "mkdir -p &directory";
  %end;
  %else %put operating system not supported os=&os sysscp=&sysscp;
%end;
%mend;
