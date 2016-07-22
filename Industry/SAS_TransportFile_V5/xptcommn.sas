%*-------------------------------------------------------------------*; 
%* These are the common macros used by the xpt2loc and loc2xpt       *;
%* macros.                                                           *;
%*-------------------------------------------------------------------*; 

%*-------------------------------------------------------------------*; 
%* The file attributes for MVS are RECFM=FB LRECL=80 but RECFM=N for *;
%* all other platforms.                                              *;
%*-------------------------------------------------------------------*; 

%macro setdcb;
%global dcb;
%if &sysscp=OS %then %do;
%let dcb=recfm=fb lrecl=80;
%end; %else %do;
%let dcb=recfm=n;
%end;
%mend;

%*-------------------------------------------------------------------*; 
%* The make_nliteral macro contains the necessary DATA step code to  *;
%* create an nliteral from name. If the trimmed name has anything    *;
%* non-alphanumeric (other than underscore) then it needs to be      *;
%* made into an nliteral. We want to use single quotes for the       *;
%* nliteral since there may be amper or pct in the name and a double *;
%* quote would allow for expansion which we do not want. Any single  *;
%* quotes in the name need to be escaped with an extra single quote. *;
%*-------------------------------------------------------------------*; 

%macro make_nliteral; 
length nliteral $67;
l=length(name); 
if verify(trim(upcase(name)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_') 
   then do;
   j=1; nliteral="'"; 
   do ii=1 to l; 
      j+1;
      substr(nliteral,j,1)=substr(name,ii,1); 
      if substr(name,ii,1)="'" then do; 
         j+1; 
         substr(nliteral,j,1)="'"; 
         end;
      end;
   j+1; substr(nliteral,j,2)="'n"; 
   end;
else nliteral=name; 
%mend make_nliteral; 

%*-------------------------------------------------------------------*; 
%* The make_memwant_fmt macro will create a format from the list     *;
%* of desired members. This format can then be used with a PUT       *;
%* function for easy determination of the member being wanted.       *;
%* This code is made more complex because embedded blanks are        *;
%* possible so the SCAN function cannot be used.                     *;
%*-------------------------------------------------------------------*; 
 
%macro make_memwant_fmt(memlist);
%global singmem;
data cntlin;
     fmtname='$memwant'; label='Y'; hlo=' ';  
     length start $32; start=' ';
 
%let l=%length(&memlist);
%let quote=;
%let memname=;
%let escape=0;
%let endlit=0;
%let j=0;
%do i=1 %to &l;
    %let c=%qsubstr(&memlist,&i,1);
        %if (&c=%str(%") or &c=%str(%')) %then %do;
        %if &escape %then %do;
            %let escape=0;
            %let append=0;
            %end;
        %else %if %length(&quote)=0 %then %do;
            %let quote=&c;
                        %let append=0;
                        %end;
                %else %if &c ne &quote %then %do;
                    %let append=1;
                        %end;
                %else %if %qsubstr(&memlist,%eval(&i+1),1)=&c %then %do;
                        %let escape=1;
                        %let append=1;
                    %end;
                %else %do;
                    %let append=0;
                        %let quote=;
                        %if &i ne &l and 
                            %upcase(%qsubstr(&memlist,%eval(&i+1),1))=N
                            %then %let endlit=1;
                        %end;
                %end;
    %else %if &endlit %then %do;
            %let endlit=0;
                %let append=0;
                %end;
        %else %let append=1;
        %if &append %then %do;
            %let j=%eval(&j+1);
        %let memname=&memname&c;
                %end;
 
        %if (%length(%trim(&memname)) ne 0 and 
             %length(%trim(&c))=0 and 
             %length(&quote)=0) or &i=&l %then %do;
            %let ll=%length(%trim(&memname));
                %if %upcase(&memname)=_ALL_ %then %do;
                    hlo='O'; output;
                    %end;
            %else %do;
                start=upcase(left("&memname.")); output;
                        %end;
                %let j=0;
                %let memname=;
            %end;
    %end;
run;
proc sort nodupkey; by start hlo; run;
proc format cntlin=cntlin; run;
proc delete data=cntlin; run;
%mend make_memwant_fmt;

%*-------------------------------------------------------------------*; 
%* This macro generates the XPRTFLT format and informat. These are   *;
%* necessary because the transport representation of floating point  *;
%* numbers is different than what S370FRB produces for missing       *;
%* values. For standard missing, S370FRB produces '8000...'x while   *;
%* transport produces '2E00....'x. The ASCII representation of the   *;
%* missing value character is used. So this format/informat handles  *;
%* the exceptions and uses S370FRB as OTHER=.                        *; 
%*-------------------------------------------------------------------*; 

%macro xprtflt;
proc format;
     value xprtflt
._ ='5F00000000000000'x
.  ='2E00000000000000'x
.A ='4100000000000000'x
.B ='4200000000000000'x
.C ='4300000000000000'x
.D ='4400000000000000'x
.E ='4500000000000000'x
.F ='4600000000000000'x
.G ='4700000000000000'x
.H ='4800000000000000'x
.I ='4900000000000000'x
.J ='4A00000000000000'x
.K ='4B00000000000000'x
.L ='4C00000000000000'x
.M ='4D00000000000000'x
.N ='4E00000000000000'x
.O ='4F00000000000000'x
.P ='5000000000000000'x
.Q ='5100000000000000'x
.R ='5200000000000000'x
.S ='5300000000000000'x
.T ='5400000000000000'x
.U ='5500000000000000'x
.V ='5600000000000000'x
.W ='5700000000000000'x
.X ='5800000000000000'x
.Y ='5900000000000000'x
.Z ='5A00000000000000'x
other=(|s370frb8.|);
     invalue xprtflt
'5F00000000000000'x=._
'2E00000000000000'x=.
'4100000000000000'x=.A
'4200000000000000'x=.B
'4300000000000000'x=.C
'4400000000000000'x=.D
'4500000000000000'x=.E
'4600000000000000'x=.F
'4700000000000000'x=.G
'4800000000000000'x=.H
'4900000000000000'x=.I
'4A00000000000000'x=.J
'4B00000000000000'x=.K
'4C00000000000000'x=.L
'4D00000000000000'x=.M
'4E00000000000000'x=.N
'4F00000000000000'x=.O
'5000000000000000'x=.P
'5100000000000000'x=.Q
'5200000000000000'x=.R
'5300000000000000'x=.S
'5400000000000000'x=.T
'5500000000000000'x=.U
'5600000000000000'x=.V
'5700000000000000'x=.W
'5800000000000000'x=.X
'5900000000000000'x=.Y
'5A00000000000000'x=.Z
other=(|s370frb8.|);
%mend;

%*-------------------------------------------------------------------*; 
%* The writemem macro is called for each member to be written out in *;
%* transport format. The macro produces DATA step code that will in  *;
%* in turn produce the transport file. The V6COMP macro variable is  *;
%* 1 if a V5 format transport file is to be written. Note that the   *;
%* label argument will come in as quoted but type will not.          *;
%*-------------------------------------------------------------------*; 

%macro writemem(fileref,dirdata,dataset,type,label,firstobs,obs);
%global v6comp;
filename sascode temp;

*-----write the header records-----*; 
data _null_;
     file &fileref. &dcb mod column=c;
     length memname $32 record $80;
     l=length("&dataset."); 
     i=index("&dataset.",'.'); 
     if l>=4 and substr("&dataset.",l-2,2)="'n" then do; 
        nliteral=substr("&dataset.",i+1); 
        memname=tranwrd(substr(nliteral,2,length(nliteral)-3),"''","'"); 
        end;
     else memname=substr("&dataset.",i+1); 
     length sysscp $8;
     dt = datetime();
     sysscp=repeat('00'x,7);
     substr(sysscp,1,min(length("&sysscp."),8))="&sysscp.";
%if &v6comp %then %do;
     record='HEADER RECORD*******MEMBER  HEADER RECORD!!!!!!!000000000000000001600000000140';
     put record $ascii80.;
     record='HEADER RECORD*******DSCRPTR HEADER RECORD!!!!!!!000000000000000000000000000000';
     put record $ascii80.;
     record='SAS     '||substr(memname,1,8)||'SASDATA 9.1      '||substr(sysscp,1,8);
     substr(record,65,16)=put(dt,datetime16.);
     put record $ascii80.;
%end; %else %do;
     record='HEADER RECORD*******MEMBV8  HEADER RECORD!!!!!!!000000000000000001600000000140';
     put record $ascii80.;
     record='HEADER RECORD*******DSCPTV8 HEADER RECORD!!!!!!!000000000000000000000000000000';
     put record $ascii80.;
     l = length(memname);
     record='SAS     '||substr(memname,1,32)||'SASDATA 9.1     '||substr(sysscp,1,8)||put(dt,datetime16.);
     put record $ascii80.;
%end;
     record=put(dt,datetime16.);
     substr(record,33,40)=&label;
     substr(record,73,8)="&type";
     put record $ascii80.;
     nvars=&obs-&firstobs+1;
%if &v6comp %then %do;
     record='HEADER RECORD*******NAMESTR HEADER RECORD!!!!!!!0000'||put(nvars,z6.)||'00000000000000000000';
     put record $ascii80.;
%end; %else %do;
     record='HEADER RECORD*******NAMSTV8 HEADER RECORD!!!!!!!0000'||put(nvars,z6.)||'00000000000000000000';
     put record $ascii80.;
%end;
     run;

%*-------------------------------------------------------------------*; 
%* Here the namestrs are written out. Each namestr is 160 bytes.     *;
%* A 160-byte buffer is populated with the proper binary data and    *;
%* the putbytes link routine is called to emit the data. This would  *;
%* not be necessary with RECFM=N but MVS needs to use this approach  *;
%* since RECFM=N does not appear functional. Note that for V5        *;
%* transport files that varname is upcased, and all length 2 numeric *;
%* variables are emitted as length 3. For V8 transport files, the    *;
%* 32-character name is added to the end of the namestr and only     *;
%* 20 bytes of zeros are emitted. This allows for the same structure *;
%* size. If after all namestrs are emitted, we are not on an 80-byte *;
%* boundary, we pad with ASCII blanks to 80 bytes.                   *;
%*-------------------------------------------------------------------*; 

data _null_; set &dirdata(firstobs=&firstobs obs=&obs) end=eof;
     file &fileref. &dcb.  mod;
     if type=1 then just=0;
     if type=2 then do; 
        if format ne ' ' and format ne :'$' then format='$'||format;
        if informat ne ' ' and informat ne :'$' then informat='$'||informat;
        end;
     label_len = length(label);
     fmtname_len = length(format);  
     infmtname_len = length(informat); 
     retain n_labels_over_40 n_fmtnames_over_8 
            n_infmtnames_over_8 n_extra_recs_needed 0;
     n_labels_over_40    + (label_len > 40); 
     n_fmtnames_over_8   + (fmtname_len > 8);
     n_infmtnames_over_8 + (infmtname_len > 8); 
     n_extra_recs_needed + (  label_len > 40 
                           or fmtname_len > 8 
                           or infmtname_len > 8);
     length buffer $160;
     pos=1;
%if &v6comp %then %do;
     name=upcase(name); 
     if type=1 and length=2 then length=3; 
%end;
     substr(buffer,pos,2)=put(type,s370fpib2.);    pos+2; 
     substr(buffer,pos,2)='0000'x;                 pos+2; 
     substr(buffer,pos,2)=put(length,s370fpib2.);  pos+2; 
     substr(buffer,pos,2)=put(_n_,s370fpib2.);     pos+2; 
     substr(buffer,pos,8)=put(name,$ascii8.);      pos+8; 
     substr(buffer,pos,40)=put(label,$ascii40.);   pos+40;
     substr(buffer,pos,8)=put(format,$ascii8.);    pos+8; 
     substr(buffer,pos,2)=put(formatl,s370fpib2.); pos+2; 
     substr(buffer,pos,2)=put(formatd,s370fpib2.); pos+2; 
     substr(buffer,pos,2)=put(just,s370fpib2.);    pos+2; 
     substr(buffer,pos,2)='0000'x;                 pos+2; 
     substr(buffer,pos,8)=put(informat,$ascii8.);  pos+8; 
     substr(buffer,pos,2)=put(informl,s370fpib2.); pos+2; 
     substr(buffer,pos,2)=put(informd,s370fpib2.); pos+2; 
     substr(buffer,pos,4)=put(npos,s370fpib4.);    pos+4; 
%if &v6comp %then %do;
     substr(buffer,pos,52)=repeat('00'x,51);       pos+52; 
%end; %else %do; 
     substr(buffer,pos,32)=put(name,$ascii32.);    pos+32; 
     substr(buffer,pos,2)=put(label_len,s370fpib2.); pos+2;
     substr(buffer,pos,2)=put(fmtname_len,s370fpib2.); pos+2;
     substr(buffer,pos,2)=put(infmtname_len,s370fpib2.); pos+2;
     substr(buffer,pos,14)=repeat('00'x,13);       pos+14;
%end; 
     pos=pos-1; 

     *-----emit the namestr-----*; 
     l=pos; link putbytes; bytes_written+pos; 
     retain maxlen 0;
     maxlen=max(maxlen,length); 
     if eof;

     *-----save the max length for MVS use-----*; 
     call symput('maxlen',trim(left(put(maxlen,best12.)))); 

     *-----have label/format/informat section indicator-----*;
     call symput('n_labels_over_40',
                  trim(left(put(n_labels_over_40,best12.))));
     call symput('n_fmtnames_over_8',
                  trim(left(put(n_fmtnames_over_8,best12.))));
     call symput('n_infmtnames_over_8',
                  trim(left(put(n_infmtnames_over_8,best12.))));
     call symput('n_extra_recs_needed',
                  trim(left(put(n_extra_recs_needed,best12.))));

     if n_fmtnames_over_8 + n_infmtnames_over_8 
        then extra_record_type='LABELV9'; 
     else extra_record_type='LABELV8'; 
     call symput("extra_record_type",extra_record_type); 

     *-----pad with blanks after last namestr if needed-----*;
     l=mod(bytes_written,80); 
     if l>0 then do; 
        l=80-l; 
        buffer=repeat('20'x,l-1);
        link putbytes; 
        end;
     return;

     *-----putbytes link routine (no prefix for variables needed)-----*; 
%putbytes();
     return;     
     run;

%*-------------------------------------------------------------------*; 
%* Here the optional long label/format/informat section is written.  *;
%*-------------------------------------------------------------------*; 

%if &n_extra_recs_needed and not &v6comp %then %do; 
data _null_;
     file &fileref. &dcb mod;
     record='HEADER RECORD*******'||"&extra_record_type."||' HEADER RECORD!!!!!!!'||
            "&n_extra_recs_needed"; 
     put record $ascii80.; 
     run;
data _null_; 
     length format informat $50; 
     set &dirdata(firstobs=&firstobs obs=&obs 
                  keep=label name type format formatl formatd 
                                       informat informl informd)
         end=eof;
     file &fileref. &dcb.  mod;
     length buffer $324; 
     label_len = length(label); 
     if type=2 then do; 
        if format ne ' ' and format ne :'$' then format='$'||format;
        if informat ne ' ' and informat ne :'$' then informat='$'||informat;
        end;
     fmtname_len = length(format); 
     if fmtname_len > 8 then do; 
        if formatl ne 0 
           then format=trim(format)||left(put(formatl,best12.));
        format=trim(format)||'.';
        if formatd ne 0 
           then format=trim(format)||left(put(formatd,best12.));
        fmtname_len = length(format);
        end;
     infmtname_len = length(informat); 
     if infmtname_len > 8 then do; 
        if informl ne 0 
           then informat=trim(informat)||left(put(informl,best12.));
        informat=trim(informat)||'.';
        if informd ne 0 
           then informat=trim(informat)||left(put(informd,best12.));
        infmtname_len = length(informat);
        end;

     if label_len > 40 or fmtname_len > 8 or infmtname_len > 8 then do; 
        name_len = length(name); 
        if "&extra_record_type"="LABELV8" then do; 
            buffer = put(_n_,s370fpib2.)       ||
                     put(name_len,s370fpib2.)  ||
                     put(label_len,s370fpib2.) ||
                     substr(name,1,name_len)   ||
                     label; 
            l = 6 + name_len + label_len; 
            end;
        else if "&extra_record_type"="LABELV9" then do; 
            buffer = put(_n_,s370fpib2.)       ||
                     put(name_len,s370fpib2.)  ||
                     put(label_len,s370fpib2.) ||
                     put(fmtname_len,s370fpib2.)||
                     put(infmtname_len,s370fpib2.)||
                     substr(name,1,name_len)   ||
                     trim(label)||trim(format)||trim(informat); 
            l = 10 + name_len + label_len + fmtname_len + infmtname_len;
            end;
        bytes_written+l; 
        link putbytes; 
        end;
     if eof; 

     *-----pad with blanks after last label if needed-----*;
     l=mod(bytes_written,80); 
     if l>0 then do; 
        l=80-l; 
        buffer=repeat('20'x,l-1);
        link putbytes; 
        end;
     return;

     *-----putbytes link routine (no prefix for variables needed)-----*; 
%putbytes();
     return;     
     run;
%end;

%*-------------------------------------------------------------------*; 
%* Here the single OBS/OBSV8 record is written. OBSV8 contains the   *;
%* observation count.                                                *;
%*-------------------------------------------------------------------*; 

data _null_;
     file &fileref. &dcb mod;
     nobsc=put(nobs,15.);
     call symput('nobsc',nobsc); 
     %if &v6comp %then %do; 
     record='HEADER RECORD*******OBS     HEADER RECORD!!!!!!!'||
            repeat('0',29);
     %end; %else %do; 
     record='HEADER RECORD*******OBSV8   HEADER RECORD!!!!!!!'||nobsc;
     %end;
     put record $ascii80.; 
     stop;
     set &dataset nobs=nobs;
     run;

%*-------------------------------------------------------------------*; 
%* Begin to write the SAS code.                                      *;
%*-------------------------------------------------------------------*; 

data _null_; file sascode;
     put "data _null_; set &dataset.;";
     put "file &fileref. &dcb. mod;";
     put 'put';
     run;

%*-------------------------------------------------------------------*; 
%* The SAS code for each variable appears here. We have a PUT        *;
%* statement using the XPRTFLT or $ASCII format with the proper      *;
%* length. We have blank-padding code if the nobs*lrecl is not an    *;
%* exact multiple of 80.                                             *;
%*-------------------------------------------------------------------*; 

data _null_; set &dirdata(firstobs=&firstobs obs=&obs) end=eof; 
     file sascode mod;
     %make_nliteral; 
     put nliteral @;
%if &v6comp %then %do; 
     if type=1 and length=2 then length=3; 
%end;
     if type=1 then put 'XPRTFLT' length 1. '.';
     else put '$ASCII' length z5. '.';
     lrecl+length; 
     if eof; 
     put '@@;'; 
     put "if _n_=&nobsc. then do;";
     i = mod(&nobsc * lrecl,80); 
     if i>0 then do; 
        i=80-i; 
        put "put " i "*'20'x;"; 
        end;
     put "stop;"; 
     put "end;"; 
     put "run;";
     run;

/*-------------------------------------------------------------------*/
/* For MVS only, we post-process the PUT statement so that the       */
/* the PUTBYTES link routine is used. This is necessary since RECFM=N*/
/* does not appear functional for MVS. Instead the code that is      */
/* written is of the form                                            */
/*                                                                   */
/* length buffer $n;                                                 */
/* l=varlen; substr(buffer,1,l)=put(x,xprtfltl.); link putbytes;     */
/*                                                                   */
/* The PUTBYTES link routine uses l and buffer and other variables,  */
/* and in order to avoid namespace collision, a prefix is added      */
/* (nonsense prefix goobly).                                         */
/*-------------------------------------------------------------------*/ 

%if &sysscp=OS %then %do;
filename mvscode temp;
data _null_; infile sascode length=l; file mvscode;
     retain replace 0;
     if _n_=1 then put '%let p=goobly;'; 
     input @; input @1 record $varying80. l;
     if record='put' then do;
        replace=1;
        maxlen=symget('maxlen');
        put 'length &p.buffer $' maxlen ';';
        return;
        end;
     if replace and record='@@;' then do;
        replace=0;
        return;
        end;
     if record='run;' then do;
        put '%putbytes(&p);';
        put 'run;'; 
        end;
     if not replace then do;
        put record;
        return;
        end;
     format=scan(record,-1,' ');
     if format=:'XPRTFLT' then do; 
        length=input(substr(format,8,1),1.);
        end;
     else do; 
        length=input(substr(format,7,5),5.);
        end;
     name=substr(record,1,length(record)-length(format)); 
     put '&p.l=' length ';' ;
     put 'substr(&p.buffer,1,&p.l)= put(' name ',' format ');'; 
     put 'link putbytes;'; 
     run;
filename sascode clear; 
filename sascode temp; 
data _null_; infile mvscode; file sascode; input; put _infile_; run;
filename mvscode clear;
%end;

%*-----the code can now be executed-----*; 
%include sascode; run;
filename sascode clear;
%mend writemem;


%*-------------------------------------------------------------------*; 
%* The getbytes and putbytes link routines allow for streaming of    *;
%* data and emitting/reading data in 80-byte chunks. A prefix is     *;
%* allowed for all local variables (plus buffer and l) so that there *;
%* will be no namespace collision.                                   *;
%*-------------------------------------------------------------------*; 

%macro getbytes(p);
getbytes:;
     retain &p.col 1;
     &p.buffer=' '; &p.loc=1;
     length &p.record $80;
     do while(&p.l>0);
        if &p.col>80 then do;
           &p.col=1;
           end;
        &p.partl=max(0,min(80-&p.col+1,&p.l));
        input &p.record $varying80. &p.partl @@;
        substr(&p.buffer,&p.loc,&p.partl)=&p.record;
        &p.loc+&p.partl;
        &p.col+&p.partl;
        &p.l=&p.l-&p.partl;
        end;
     drop &p.col &p.buffer &p.loc &p.record &p.l &p.partl;
     return;
%mend getbytes;

%macro putbytes(p);
putbytes:;
     retain &p.col 1;
     &p.loc=1;
     length &p.record $80;
     do while(&p.l>0);
        if &p.col>80 then do;
           &p.col=1;
           end;
        &p.partl=max(0,min(80-&p.col+1,&p.l));
        &p.record=substr(&p.buffer,&p.loc,&p.partl);
        put &p.record $varying80. &p.partl @@;
        &p.loc+&p.partl;
        &p.col+&p.partl;
        &p.l=&p.l-&p.partl;
        end;
     drop &p.col &p.buffer &p.loc &p.record &p.l &p.partl;
     return;
%mend putbytes;

%macro xptcommn; 
* just need to define this to avoid a warning message;
%mend; 

