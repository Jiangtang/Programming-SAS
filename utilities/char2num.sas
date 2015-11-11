/*
http://www.nesug.org/Proceedings/nesug10/ff/ff01.pdf	


http://www.sascommunity.org/wiki/Convert_All_Variables_to_Opposite_Type
http://www.sascommunity.org/wiki/Convert_Character_Variables_to_Numeric
http://www.sascommunity.org/wiki/Convert_Numeric_Variables_to_Character

https://communities.sas.com/message/144692
http://support.sas.com/kb/40/700.html

*/


%macro char2num(inputlib=work, /* libref for input data set */ 
 inputdsn=, /* name of input data set */ 
 outputlib=work, /* libref for output data set */ 
 outputdsn=, /* name of output data set */ 
 excludevars=); /* variables to exclude */ 
 
proc sql noprint; 
select name into :charvars separated by ' ' 
from dictionary.columns 
where libname=upcase("&inputlib") and memname=upcase("&inputdsn") and type="char" 
 and not indexw(upcase("&excludevars"),upcase(name)); 
quit; 
 
%let ncharvars=%sysfunc(countw(&charvars)); 
 
data _null_; 
set &inputlib..&inputdsn end=lastobs; 
array charvars{*} &charvars; 
array charvals{&ncharvars}; 
do i=1 to &ncharvars; 
 if input(charvars{i},?? best12.)=. and charvars{i} ne ' ' then charvals{i}+1; 
end; 
if lastobs then do; 
 length varlist $ 32767; 
 do j=1 to &ncharvars; 
 if charvals{j}=. then varlist=catx(' ',varlist,vname(charvars{j})); 
 end; 
 call symputx('varlist',varlist); 
end; 
run; 
 
%let nvars=%sysfunc(countw(&varlist)); 
 
data temp; 
set &inputlib..&inputdsn; 
array charx{&nvars} &varlist; 
array x{&nvars} ; 
do i=1 to &nvars; 
 x{i}=input(charx{i},best12.); 
end; 
drop &varlist i; 
 
%do i=1 %to &nvars; 
 rename x&i = %scan(&varlist,&i) ; 
%end; 
 
run; 
proc sql noprint; 
 
select name into :orderlist separated by ' ' 
from dictionary.columns 
where libname=upcase("&inputlib") and memname=upcase("&inputdsn") 
order by varnum; 
 
select catx(' ','label',name,'=',quote(trim(label)),';') 
 into :labels separated by ' ' 
from dictionary.columns 
where libname=upcase("&inputlib") and memname=upcase("&inputdsn") and 
 indexw(upcase("&varlist"),upcase(name)); 
 
quit; 
 
data &outputlib..&outputdsn; 
retain &orderlist; 
set temp; 
&labels 
run; 
 
%mend char2num; 

%char2num(inputdsn=earnings, /* read WORK.EARNINGS */ 
 outputdsn=earningsC, /* write WORK.EARNINGSC */ 
 excludevars=id) /* do not convert ID */