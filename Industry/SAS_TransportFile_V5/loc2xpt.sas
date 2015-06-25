%*-------------------------------------------------------------------*;
%* Note that if this program is stored for use on IBM mainframe,     *;
%* the LRECL should be at 128. This program uses over 80-byte        *;
%* records in its SAS code.                                          *;
%*-------------------------------------------------------------------*;

%*-------------------------------------------------------------------*; 
%* The loc2xpt macro is used to convert a list of data set members   *;
%* into a transport representation. The parameters are:              *;
%*                                                                   *;
%* libref=          indicates the libref where the members reside.   *;
%*                  The default is WORK.                             *;
%* memlist=         indicates the list of members in the library     *;
%*                  that are to be converted. The default is that    *;
%*                  all members will be converted.                   *;
%* filespec=        gives a fileref (unquoted) or a file path        *;
%*                  (quoted) where the transport file will be        *;
%*                  written. There is no default.                    *;
%* format=          the format of the transport file. Possible       *;
%*                  values are: V5 (V5 transport), V8 (V8 extended   *;
%*                  transport), AUTO (determined by data), V9 (V9    *;
%*                  extended transport).                             *;
%*                                                                   *;
%* If the member name is over 8 characters, or if any variable name  *;
%* exceeds 8 characters, or has any characters that are not letters, *;
%* digits, or underscore, or if any character variable exceeds       *;
%* length 200, then a V5 transport file cannot be written. If AUTO   *;
%* is in effect then V8 will be assumed in such cases.               *;
%* Note that if the data set is V5 compliant, all variable names     *;
%* will be upcased when stored in the V5 transport file. This is     *;
%* consistent with the XPORT engine.                                 *;
%* If any format or informat name exceeds 8 characters, then V9 will *;
%* be assumed in such cases.                                         *;
%*-------------------------------------------------------------------*;
 
%macro loc2xpt(libref=work,memlist=_all_,filespec=,format=auto);

%*-----bring in the common macros-----*; 
%*xptcommn; 

%*-----global macro variables used----*; 
%global singmem dcb v6comp;

%*-----establish RECFM= setting (N for all but MVS, FB on MVS)-----*; 
%setdcb;

%*-----define the XPRTFLT format and informat for numeric variables-----*; 
%xprtflt;

%*-----create the $MEMWANT format for the provided member list-----*; 
%make_memwant_fmt(&memlist);

%*-----get metadata for all members of the specified library-----*; 
proc contents data=&libref.._all_ noprint
              out=_data_(keep=libname memname memtype type length name
                              typemem memlabel
                              label format formatl formatd just
                              informat informl informd npos varnum);
     run;
%let detail=%sysfunc(getoption(_LAST_));

%*---------------------------------------------------------------*; 
%* Here we read the metadata and choose all observations for our *;
%* selected members. If the variable name or member name is over *;
%* 8 characters or the length of any variable is over 200        *; 
%* then the data set cannot be exported as a V6 transport file.  *;
%* We set v6comp to 1 if V6 compatible and 0 if not.             *; 
%*---------------------------------------------------------------*; 

data &detail; set &detail end=eof; by memname notsorted;
     retain v6comp '1' v8comp '1' want;
     if first.memname then do;
        want = memtype='DATA' and put(upcase(memname),$memwant.)='Y';
        if want and
           (verify(trim(upcase(memname)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_') ne 0 or
            length(memname)>8)
           then v6comp='0';
        end;
     if want then do;
        if v6comp='1' and
           (verify(trim(upcase(name   )),'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_') ne 0 or
            length(name)>8 or length>200)
              then v6comp='0';
        if v8comp='1' then do; 
           if length(format) > 8 or length(informat) > 8
              then v8comp='0'; 
           if type=2 then do; 
              if (index(format,'$')=0 and length(format) >= 8) or 
                 (index(informat,'$')=0 and length(informat) >= 8) 
                 then v8comp='0';  
              end;
           end;
        if v8comp ne '1' then v6comp='0'; 
        output;
        end;
     if eof then do;
        %if %upcase(&format)=V8 or %upcase(&format)=V9 %then %do;
        v6comp='0';
        %end;
        %if %upcase(&format)=V6 %then %do; 
        if v6comp='0' then do; 
           put 'FORMAT=V6 was specified but the data set is not compatible with V6.'; 
           abort; 
           end;
        %end;
        %if %upcase(&format)=V8 %then %do; 
        if v8comp='0' then do; 
           put 'FORMAT=V8 was specified but the data set is not compatible with V8.'; 
           abort; 
           end;
        %end;
        call symput('v6comp',v6comp);
        end;
     drop v6comp;
     run;

%*-----be sure variables are in the proper order-----*; 
proc sort; by memname varnum; run;

%*-----write out the initial library header records-----*; 
data _null_; file &filespec. &dcb.;
     length record $80;
     %if &v6comp %then %do;
     record='HEADER RECORD*******LIBRARY HEADER RECORD!!!!!!!000000000000000000000000000000';
     %end; %else %do;
     record='HEADER RECORD*******LIBV8   HEADER RECORD!!!!!!!000000000000000000000000000000';
     %end;
     put record $ascii80.;
     length sysscp $8;
     sysscp=repeat('00'x,7);
     substr(sysscp,1,min(length("&sysscp."),8))="&sysscp.";
     dt = datetime();
     record='SAS     SAS     SASLIB  9.1     ';
     substr(record,33,8)=sysscp;
     substr(record,65,16)=put(dt,datetime16.);
     put record $ascii80.;
     record=put(dt,datetime16.);
     put record $ascii80.;
     run;

 /*---------------------------------------------------------------*/
 /* This DATA step will generate SAS code consisting of a         */
 /* %writemem macro invocation for each desired member. The macro */
 /* will be responsible for appending the proper data into the    */
 /* transport file.                                               */
 /*---------------------------------------------------------------*/

filename sascode2 temp;
data _null_; set &detail.; by memname;
     file sascode2;
     length firstobs $12;
     length dslabel $82;
     retain firstobs;
     if first.memname then firstobs=left(put(_n_,best12.));
     if last.memname;
     name=memname;
     %make_nliteral; 
     if length(memlabel)=0 then dslabel='" "';
     else do;
        l=length(memlabel)-length(compress(memlabel,'"'));
        dslabel=putc(memlabel,'$quote',length(memlabel)+l*2+2);
        end;
     command='%writemem('||"&filespec."||','||"&detail."||','||
                  trim(libname)||'.'||trim(nliteral)||','||
                  trim(typemem)||','||trim(dslabel)||','||
                  trim(firstobs)||','||trim(left(put(_n_,best12.)))||');';
     put command;
     run;

%*-----read in the generated SAS code, then clear the file-----*; 
%include sascode2; run;
filename sascode2 clear;

%*-----delete our metadata data set now that we are done with it-----*;
proc delete data=&detail.; run;
%mend loc2xpt;

