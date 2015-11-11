%macro char2num(dsn,out=out);

  %let list=;
  %let type=;
  %let dsid=%sysfunc(open(&dsn));
  %let cnt=%sysfunc(attrn(&dsid,nvars));
   %do i = 1 %to &cnt;
    %let list=&list %sysfunc(varname(&dsid,&i));
    %let type=&type %sysfunc(vartype(&dsid,&i));
   %end;
  %let rc=%sysfunc(close(&dsid));

  data &out(drop=
    %do i = 1 %to &cnt;
     %let temp=%scan(&list,&i);
       _&temp
    %end;);
   set &dsn(rename=(
    %do i = 1 %to &cnt;
     %let temp=%scan(&list,&i);
       &temp=_&temp
    %end;));
    %do j = 1 %to &cnt;
     %let temp=%scan(&list,&j);
   /** Change C to N for numeric to character conversion  **/
     %if %scan(&type,&j) = C %then %do;
   /** Also change INPUT to PUT for numeric to character  **/
      &temp=input(_&temp,8.);
     %end;
     %else %do;
      &temp=_&temp;
     %end;
    %end;
  run;

%mend char2num;

%char2num(sashelp.class)

/** Verify conversion has been made **/
proc contents data=out;
run;
