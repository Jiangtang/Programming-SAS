/*0. save macro to local catalog
macro should have /store option
%macro grep(librf,string) /store;
*/

libname macros  "C:\Users\jhu\Programming-SAS"; 
options mstored sasmstore=macros ; 


%inc "C:\Users\jhu\Programming-SAS\CheckLog.sas";

%inc "C:\Users\jhu\Programming-SAS\FullTextSearch.sas";


/*1.	list all macro programs stored in the catalog SASMACR*/

proc catalog catalog=macros.sasmacr;   
    contents; 
quit;

/*delete macro from catalog list*/


PROC SQL;   
  SELECT * FROM 
  DICTIONARY.CATALOGS WHERE MEMNAME IN ('SASMACR');  
Quit; 

/*2. reference the stored macro catalog

to autoexec.sas?
*/

/*
libname macros  "C:\Users\jhu\Programming-SAS"; 
options mstored sasmstore=macros ; 

*/

options nomprint nomlogic nosymbolgen nonotes;
%grep(sashelp,John)
options ;

%checklog;
