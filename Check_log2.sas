/*

filename macs "C:\Documents and Settings\shumphreys\My Documents\Programs\Macros"; 
options sasautos=(sasautos macs) 

*/


%macro logcheck; 
***********************************************************************************; 
*             ALLOW USER TO SPECIFY REQUIRED INFORMATION                           *; 
***********************************************************************************; 
%let dir=; 


%window dir irow=10 rows=10 icolumn=10 columns=85 color=orange 
   #1 @10 "Please specify the directory to check, then hit ENTER key " 
   #2 @10 "(e.g. TLG or CDISC\SDTM or CDISC\ADAM) "  
   #4 @10 "&root.\Output\ " 
   +3 dir 10 required=yes attr=(underline); 
%display dir blank; 


************************************************************************************; 
* first of all get list of all log files in directory *; 
filename nams pipe %unquote(%str(%'dir "&root.\Output\Logs\&dir.\&ver." /B /a:-d /ON %')); 

data fnums(keep=fname);   
   infile nams missover pad length=len;  
   input @01 line $varying200. len eof; 
  if index(upcase(line),'.LOG'); 
   fname=strip(line); 
run;        
    
proc sql noprint; 
  select count(distinct fname), fname 
   into : fnum, 
        : fname separated by '*' 
    from fnums; 
quit;  

%put &fname &fnum; 

%do i=1 %to &fnum; 
%let fnami=%scan(%scan(&fname,&i,*),1,%str(.log)); 
%let fnam&i=%scan(%scan(&fname,&i,*),1,%str(.log)); 
filename onef "&root.\Output\Logs\&dir.\&ver.\&fnami..log"; 

* next bring in each file in turn to sas dset and read log for err ors warn ings etc *; 
data &fnami.(keep=type message filenam where=(message ne '')); 
retain noerr 0; 
  length line message $200. filenam type $50; 
  infile onef pad length=len missover end=eof; 
  input @01 line $varying200. len; 
   filenam="&fnami..log"; 
   if index(line,'ERROR') then do; 
     message=strip(line); 
  type='ERR'||'OR'; 
  noerr+1; 
   end; 
   if index(line,'WARNING') then do; 
     message=strip(line); 
  type='WARN'||'ING'; 
  noerr+1; 
   end; 
   if index(line,'uninitialized') then do; 
     message=strip(line); 
  type='UNINIT'||'IALIZED'; 
  noerr+1; 
   end; 
   if index(line,'invalid') then do; 
     message=strip(line); 
  type='INV'||'ALID'; 
  noerr+1; 
   end; 
if index(line,'repeats of') then do; 
     message=strip(line); 
  type='MERGE STATEMENT WITH REP'||'EATS OF BY VARIABLES'; 
  noerr+1; 
   end; 
   if index(line,'converted to numeric') then do; 
     message=strip(line); 
  type='CONVER'||'TED TO NUMERIC'; 
  noerr+1; 
   end; 
   if index(line,'Input data set is empty') then do; 
     message=strip(line); 
  type='INPUT DATA'||'SET IS EMPTY'; 
  noerr+1; 
   end; 
   if index(line,'no observations') then do; 
     message=strip(line); 
  type='DATA SET WITH NO'||'OBSERVATIONS'; 
  noerr+1; 
   end; 
   if index(line,'is unknown') then do; 
     message=strip(line); 
  type='FORMAT IS'||'UNKNOWN'; 
  noerr+1; 
   end; 
   if index(line,'one W.D') then do; 
     message=strip(line); 
  type='AT LEAST ONE'||'WD FORMAT WAS TOO SMALL'; 
  noerr+1; 
   end; 
if eof then do; 
  if noerr=0 then do; 
    message='NO MESSAGES OF CONCERN IN LOG'; 
 type='NONE'; 
  end; 
end; 
run; 
%end; 


* put all together *; 
data repall; 
  set &fnam1 
       %do j=2 %to &fnum; &&fnam&j %end;; 
run; 

proc sql; 
  create table rep as 
   select count(message) as message_no, type, filenam 
    from repall 
   group by filenam, type; 
quit; 

data rep1; 
  set rep; 
   if type='NONE' then message_no=.; 
   comm=''; 
run; 

* create summary report of log messages *; 
ods listing close; 
options nonumber; 
ods escapechar="^"; 
ods rtf file="&root.\Output\Logs\&dir.\&ver.\log_report.rtf"; 
title1 "Summary of Log Messages for Directory &root.\Output\Logs\&dir.\&ver."; 
title2 "Report Run Date: &sysdate9. &systime"; 
title3 " "; 
footnote1 j=r "^{pageof}"; 
options missing=' '; 

proc report data=rep1 nowd headskip headline missing formchar(2)='_' spacing=2 split='~'; 
column filenam type message_no; 
define filenam    /  order "FILENAME" width=20 left flow; 
define type       /  order "MESSAGE TYPE" width=30 left flow; 
define message_no /        "NUMBER OF REPORTED MESSAGES" width=40 left flow; 
break after filenam / skip; 
run; 

title1 "Detailed Breakdown of Log Messages"; 

proc report data=repall nowd headskip headline missing formchar(2)='_' spacing=2 split='~'; 
column filenam type message comm; 
define filenam    /  order "FILENAME" width=20 left flow; 
define type       /        "MESSAGE TYPE" width=20 left flow; 
define message    /        "MESSAGE"  
                           style (column) = [cellwidth =7 in just = left]; 
define comm       /        "USER COMMENT" 
                           style (column) = [cellwidth =1 in just = left]; 
break after filenam / skip; 
run; 

options missing='-'; 
title;footnote; 
ods rtf close; 
ods listing; 
%mend logcheck; 


%let root=A:\test;
%logcheck

   
 
