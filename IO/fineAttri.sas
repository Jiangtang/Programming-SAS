/** Macro technique **/
%macro FileAttribs(filename);                                                                                                           
  %local rc fid fidc;                                                                                                                   
  %local Bytes CreateDT ModifyDT;                                                                                                       
   %let rc=%sysfunc(filename(onefile,&filename));                                                                                       
   %let fid=%sysfunc(fopen(&onefile));                                                                                                  
   %let Bytes=%sysfunc(finfo(&fid,File Size (bytes)));                                                                                  
   %let CreateDT=%sysfunc(finfo(&fid,Create Time));                                                                                     
   %let ModifyDT=%sysfunc(finfo(&fid,Last Modified));                                                                                   
   %let fidc=%sysfunc(fclose(&fid));                                                                                                    
   %let rc=%sysfunc(filename(onefile));                                                                                                 
    %put NOTE: File size of &filename is &Bytes bytes;                                                                                  
    %put NOTE- Created &CreateDT;                                                                                                       
    %put NOTE- Last modified &ModifyDT;                                                                                                 
%mend FileAttribs;                                                                                                                      
   
/** Just pass in the path and file name **/                                                                                                                                     
%FileAttribs(c:\aaa.txt)


/** Non-macro technique **/
filename fileref 'c:\aaa.txt';
data a;
  infile fileref truncover;
  fid=fopen('fileref');
  Bytes=finfo(fid,'File Size (bytes)');                                                                                  
  crdate=finfo(fid,'Create Time');
  moddate=finfo(fid,'Last Modified');
  input var1 $20.;
run;
proc print;
run;

/*Retrieve file size, create time, and last modified date of an external file
http://support.sas.com/kb/40/934.html
*/