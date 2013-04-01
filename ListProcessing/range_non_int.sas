
/*
%put %range_non_int(start = 1 , end = 5 , by = .25 ) ;

http://support.sas.com/kb/37/536.html
modified by Jiangtang Hu (jiangtanghu.com)

*/

%macro range_non_int( start= , end= , by= ) ;
    %local list;

    %do i = 1 %to %eval(%sysfunc( ceil( %sysevalf( ( &end - &start ) / &by ) ) ) +1) ;
       %let value=%sysevalf( ( &start - &by ) + ( &by * &i ) ) ;
       %if &value <=&end %then %do;
           %let list=&list. &value;
       %end;
    %end ;
    &list
%mend range_non_int ;
