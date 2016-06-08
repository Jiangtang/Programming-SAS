%macro ut_libname(libref=,path=,drive=,options=,rc=librc,readonly=_default_,
 debug=0);

%local libname_rc;

%put;

%let &rc =;

%if %bquote(&libref) = %then %do;
  %put UERROR: libref not specified;
  %goto endmac;
%end;

%if &debug %then %do;
  %bquote(* libname &libref BASE "&path" &options;)
%end;

%let libname_rc = %sysfunc(libname(&libref,&path,base,&options));

%put %sysfunc(sysmsg());
%let &rc = &libname_rc;

libname &libref list;

%endmac:
%mend;
