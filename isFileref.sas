%macro isFileref(fileref);
    %let fileref=%upcase(&fileref);
    %if %length(&fileref)>8 %then
       %put &fileref: The fileref must be 8 characters or less.;
    %else %do;
       %let first=ABCDEFGHIJKLMNOPQRSTUVWXYZ_;
       %let all=&first.1234567890;
       %let chk_1st=%verify(%substr(&fileref,1,1),&first);
       %let chk_rest=%verify(&fileref,&all);
       %if &chk_rest>0 %then
          %put &fileref: The fileref cannot contain
              "%substr(&fileref,&chk_rest,1)".;
       %if &chk_1st>0 %then
          %put &fileref: The first character cannot be
              "%substr(&fileref,1,1)".;
       %if (&chk_1st or &chk_rest)=0  %then
          %put &fileref is a valid fileref.;
    %end;
 %mend isFileref;

/*checks a string to verify that it is a valid fileref
http://support.sas.com/documentation/cdl/en/mcrolref/62978/HTML/default/viewer.htm#p131qnuj9o3t15n1vd6pblyrs4ui.htm

%isFileref(file1)
%isFileref(1file)
%isFileref(filename1)
%isFileref(file$)
*/

