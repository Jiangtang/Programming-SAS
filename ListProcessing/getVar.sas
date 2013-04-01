/*
Purpose: return the list of variables in a data set

Examples:
    %put %getVar(%str(sashelp.class));
    %put %getVar(%str(sashelp.class),n);
    %put %getVar(%str(sashelp.class),N);
    %put %getVar(%str(sashelp.class),c);
    %put %getVar(%str(sashelp.class),C);

Credits:
    Source code by Arthur Carpenter, Storing and Using a List of Values in a Macro Variable
         http://www2.sas.com/proceedings/sugi30/028-30.pdf
    Authored by Michael Bramley
    Jiangtang Hu (2013, Jiangtanghu.com) adds variable type (N, C) options.
*/


%macro getVar(dset,type) ; 
   %local varlist ; 
    %let fid = %sysfunc(open(&dset)) ; 
    %if &fid %then %do ; 
        %do i=1 %to %sysfunc(attrn(&fid,nvars)) ; 
            %if %upcase(&type) = N %then %do;
                %if %sysfunc(vartype(&fid,&i)) = N %then
                    %let varlist= &varlist %sysfunc(varname(&fid,&i));
            %end;
            %else %if %upcase(&type) = C %then %do;
                %if %sysfunc(vartype(&fid,&i)) = C %then
                    %let varlist= &varlist %sysfunc(varname(&fid,&i));
            %end;
            %else
                %let varlist= &varlist %sysfunc(varname(&fid,&i)); 
        %end ; 
        %let fid = %sysfunc(close(&fid)) ; 
    %end ; 
    &varlist 
%mend getVar ;


