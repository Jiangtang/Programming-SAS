%*-------------------------------------------------------------------*; 
%* The xpt2loc macro is used to convert a transport file into local  *;
%* SAS data set representation. The parameters are:                  *;
%*                                                                   *;
%* libref=          indicates the libref where the members will be   *;
%*                  written. The default is WORK.                    *;
%* memlist=         indicates the list of members in the library     *;
%*                  that are to be converted. The default is that    *;
%*                  all members will be converted.                   *;
%* filespec=        gives a fileref (unquoted) or a file path        *;
%*                  (quoted) where the transport file resides        *;
%*                  written. There is no default.                    *;
%*                                                                   *;
%* This macro should be able to handle V5 transport files written by *;
%* the XPORT engine. It should also handle V8 extended transport     *;
%* files written by the companion loc2xpt macro.                     *;
%*-------------------------------------------------------------------*;

%macro xpt2loc(libref=work,memlist=_all_,filespec=);

%*-----bring in the common macros-----*; 
%*xptcommn; 

%*-----global macro variables used----*; 
%global singmem dcb v6comp;
/* added by TSD */
%let v6comp=0;

%*-----establish RECFM= setting (N for all but MVS, FB on MVS)-----*; 
%setdcb;

%*-----define the XPRTFLT format and informat for numeric variables--*; 
%xprtflt;

%*-----create the $MEMWANT format for the provided member list-----*; 
%make_memwant_fmt(&memlist);

 /*------------------------------------------------------------------*/
 /* This big DATA step will read through the entire transport file.  */
 /* It will determine all the metadata for the SAS data sets defined */
 /* therein, and will generate corresponding DATA step code to       */
 /* reproduce the data. The generated code will be like this:        */
 /*                                                                  */
 /* data libref.memname(type=... label=...);                         */
 /* infile fileref ... ;                                             */
 /* length x 8;                                                      */
 /* format x DATE9.;                                                 */
 /* label x='label for x';                                           */
 /* ....                                                             */
 /*                                                                  */
 /* An INPUT statement is also generated, as in:                     */
 /*                                                                  */
 /* if _n_=1 then input @&firstobs_memnnnn. @;                       */
 /* input                                                            */
 /* x XPORTFLT8.                                                     */
 /* y $ASCII8.                                                       */
 /* ...                                                              */
 /* @@;                                                              */
 /* output; if _n_=&obs_memnnnn then stop;                           */
 /* run;                                                             */
 /*                                                                  */
 /* For all systems but MVS, the INPUT statement is simply appended  */
 /* along with the proper _N_ values to indicate where to start and  */
 /* stop reading the data portion of the transport file. MVS needs   */
 /* post-processing since RECFM=N cannot be used successfully.       */
 /*------------------------------------------------------------------*/

filename inptstmt temp;
filename metadata temp;
data _null_; infile &filespec. &dcb. eof=atend;
     length type $4 memname $32 record $80;
     retain v6comp 0 memnum 0 recnum 1 col 1 type nvars;
     length name $32 format informat $50 label $256;
     length buffer $512;
     length quoted $514;

     *-----read and process records after headers-----*; 
     if type='name' then do;
        link process_name_records;
        return;
        end;
     else if type='desc' then do;
        link process_desc_records;
        return;
        end;
     else if type='labl' then do;
        link process_label_record;
        return;
        end;
     else if type='lab9' then do;
        link process_label_record9;
        return;
        end;
     else if type='data' then do;
        link process_data_record;
        type='none';
        end;

     *-----assume header or data records here, read and convert 
           from ASCII-----*; 
     l=80; link getbytes;
     buffer=input(buffer,$ascii80.);
     if      buffer=:'HEADER RECORD*******MEMBER  HEADER RECORD!!!!!!!' 
        then do;
        type='none';
        end;
     else if buffer=:'HEADER RECORD*******MEMBV8  HEADER RECORD!!!!!!!' 
        then do;
        type='none';
        end;
     else if buffer=:'HEADER RECORD*******DSCRPTR HEADER RECORD!!!!!!!' 
        then do;
        type='desc';
        end;
     else if type='skip' then return;
     else if buffer=:'HEADER RECORD*******DSCPTV8 HEADER RECORD!!!!!!!' 
        then do;
        type='desc';
        end;
     else if buffer=:'HEADER RECORD*******NAMESTR HEADER RECORD!!!!!!!' 
          or buffer=:'HEADER RECORD*******NAMSTV8 HEADER RECORD!!!!!!!' 
        then do;
        type='name';
        nvars=input(substr(buffer,53,6),6.);
        end;
     else if buffer=:'HEADER RECORD*******LABELV8 HEADER RECORD!!!!!!!' 
        then do;
        type='labl';
        n_long_labels=input(substr(buffer,49),best12.);
        retain n_long_labels; 
        end;
     else if buffer=:'HEADER RECORD*******LABELV9 HEADER RECORD!!!!!!!' 
        then do;
        type='lab9';
        n_long_labels=input(substr(buffer,49),best12.);
        retain n_long_labels; 
        end;
     else if buffer=:'HEADER RECORD*******OBS     HEADER RECORD!!!!!!!' 
          or buffer=:'HEADER RECORD*******OBSV8   HEADER RECORD!!!!!!!' 
        then do;
        retain nobs;
        if substr(buffer,49,15) ne '000000000000000' then do; 
           nobs=input(substr(buffer,49,15),15.); 
           end;
        else nobs=.; 
        type='data';
        end;
     else if buffer=:'HEADER RECORD*******LIBRARY HEADER RECORD!!!!!!!' 
        then do;
        type='head';
        v6comp=1;
        end;
     else if buffer=:'HEADER RECORD*******LIBV8   HEADER RECORD!!!!!!!' 
        then do;
        type='head';
        end;

     *-----save record in case it is the last data record-----*; 
     else lastrec=buffer; retain lastrec;
     return;

*-----we hit this point if at EOF of the entire transport file-----*; 
atend:;
     eof=1;
     link fobslobs;
     return;

 /*------------------------------------------------------------------*/
 /* We come to this point when we have hit either EOF or a new       */
 /* MEMBER record. We create a &firstobs_memnnnn macro variable      */
 /* (where nnnn=member number) containing the byte offset to the     */
 /* beginning of the data portion. Also &obs_memnnnn is created to   */
 /* indicate the byte offset where to stop. The observation count    */
 /* is stored in the OBSV8 record and that is used to compute the    */
 /* offset. However, the V5 transport files do not have an obs count */
 /* so we have to backtrack from the last record and look for the    */
 /* last observation have something other than all blanks. This is   */
 /* only necessary for observation lrecl < 80. Note that a design    */
 /* shortcoming for V5 transport is that a legitimate observation    */
 /* with all blanks will be discarded.                               */
 /* The &maxlen_memnnnn macro variable is also created, containing   */
 /* the maximum length of any variable. This is used by MVS in       */
 /* post-processing.                                                 */
 /*------------------------------------------------------------------*/
 
fobslobs:;
     call symput('firstobs_mem'||put(memnum,z4.),
                 trim(left(put((firstobs-1)*80+1,best12.))));
     if eof then recnum+1;
     if nobs=. then do; 
        nobs=floor((recnum-2-firstobs+1)*80 / lrecl);
        if lrecl<80 then do; 
           j=mod(nobs*lrecl,80);
           if j=0 then j=80;
           do j=j+1-lrecl to 1 by -lrecl;
              piece=substr(lastrec,j,lrecl); 
              if substr(lastrec,j,lrecl) ne ' '
                 then leave;
              else nobs=nobs-1;
              end;
           end;
        end;
     call symput('obs_mem'||put(memnum,z4.),
                 trim(left(put(nobs,best12.))));
     call symput('maxlen_mem'||put(memnum,z4.),
                 trim(left(put(maxlen,best12.))));
     return;

 /*------------------------------------------------------------------*/
 /* The getbytes routine expects to read l bytes from the input      */
 /* stream. It sets recnum to the current record number. It allows   */
 /* for streaming between records. This code is really not necessary */
 /* with recfm=n, but used here to simplify usage on MVS, where      */
 /* recfm=n does not appear to be properly functional with transport */
 /* files.                                                           */
 /*------------------------------------------------------------------*/

getbytes:;
     buffer=' '; loc=1;
     length record $80;
     l2=l;
     do while(l2>0);
        if col>80 then do;
           recnum+1;
           col=1;
           end;
        partl=max(0,min(80-col+1,l2));
        input record $varying80. partl @@;
        substr(buffer,loc,partl)=record;
        loc+partl;
        col+partl;
        l2=l2-partl;
        end;
 
     return;

make_nliteral:; 
     %make_nliteral;
     return; 

 /*------------------------------------------------------------------*/
 /* At this point we read all the variable descriptors. They are     */
 /* streamed together. 140 bytes for each. The V8 namestr uses 32    */
 /* bytes at the end to hold a long variable name. The name is       */
 /* converted to an n-literal if it contains characters other than   */
 /* alphanumeric chars, underscore, or trailing blanks. All of the   */
 /* LENGTH, FORMAT, INFORMAT, and LABEL statements are generated.    */
 /* The XPRTFLT informat is used for informatting. The S370FRB       */
 /* informat would be sufficient, except that missing values are     */
 /* stored using the ASCII character as the mantissa. S370FRB uses   */
 /* different characters.                                            */
 /*------------------------------------------------------------------*/

process_name_records:;
     namedata=0;
     lrecl=0; retain lrecl;
     maxlen=0; retain maxlen;
     do i=1 to nvars;
        l=140;link getbytes;
        namedata+l;
        pos=1;
        vartype  = input(substr(buffer,pos, 2),s370fpib2.); pos+4;
        length   = input(substr(buffer,pos, 2),s370fpib2.); pos+4;
        name     = input(substr(buffer,pos, 8),$ascii8.  ); pos+8;
        label    = input(substr(buffer,pos,40),$ascii40.);  pos+40;
        format   = input(substr(buffer,pos, 8),$ascii8.);   pos+8;
        formatl  = input(substr(buffer,pos, 2),s370fpib2.); pos+2;
        formatd  = input(substr(buffer,pos, 2),s370fpib2.); pos+2;
        just     = input(substr(buffer,pos, 2),s370fpib2.); pos+4;
        informat = input(substr(buffer,pos, 8),$ascii8.);   pos+8;
        informl  = input(substr(buffer,pos, 2),s370fpib2.); pos+2;
        informd  = input(substr(buffer,pos, 2),s370fpib2.); pos+2;

                                                            pos+4; 
        if label = ' ' then label_len = 0; 
        else label_len = length(label);
        fmtname_len = 0;
        infmtname_len = 0;
        if not v6comp then do;
           name     = input(substr(buffer,pos, 32),$ascii32.);pos+32;
           label_len = input(substr(buffer,pos,2),s370fpib2.); pos+2;
           fmtname_len = input(substr(buffer,pos,2),s370fpib2.); pos+2; 
           infmtname_len = input(substr(buffer,pos,2),s370fpib2.); pos+2; 
           end;
        if vartype=2 then c='$'; else c=' ';
        maxlen=max(maxlen,length);
        link make_nliteral; 
        file metadata;
        l=length; 
        if vartype=1 and l=2 and "&sysscp." ne "OS" then l=3;
        put 'length ' nliteral +1 c l ';';
        if fmtname_len <= 8 and (format ne ' ' or formatl ne 0 or formatd ne 0) then do;
           if vartype=2 and format ne :'$' then format='$'||format;
           if formatl ne 0 
              then format=trim(format)||left(put(formatl,best12.));
           format=trim(format)||'.';
           if formatd ne 0 
              then format=trim(format)||left(put(formatd,best12.));
           put 'format' +1 nliteral +1 format ';';
           end;
        if infmtname_len <= 8 and (informat ne ' ' or informl ne 0 or informd ne 0) then do;
           if vartype=2 and informat ne :'$' 
              then informat='$'||informat;
           if informl ne 0 
              then informat=trim(informat)||left(put(informl,best12.));
           informat=trim(informat)||'.';
           if informd ne 0  
              then informat=trim(informat)||left(put(informd,best12.));
           put 'informat' +1 nliteral +1 informat ';';
           end;

        %if &v6comp %then %do; 
        if label_len then link quote_label; 
        %end; %else %do; 
        if 0<label_len<=40 then link quote_label; 
        %end;

        *-----write the code for the INPUT statement-----*; 
        file inptstmt;
        put nliteral @;
        if vartype=1 then put 'XPRTFLT' length 1. '.';
        else put '$ASCII' length z5. '.';
        lrecl+length;
        end;

     *-----read the trailing blanks after the last namestr if present-*; 
     l=mod(namedata,80);
     if l>0 then do;
        l=80-l;
        link getbytes;
        end;
     type='none';
     return;

quote_label:; 
        /*-----------------------------------------------------------*/
        /* We want to have the label quoted for the LABEL statement. */
        /* The $QUOTE format quotes things like we want, but if you  */
        /* use $QUOTE40. it will retain the trailing blanks, which   */
        /* we don't want. So we find out how many embedded " chars   */
        /* there are and compute the proper length for $QUOTE and    */
        /* use the PUTC function to produce a quoted label.          */
        /*-----------------------------------------------------------*/

        if label ne ' ' then do; 
           l=length(label);
           l2=l-length(compress(label,'"'));
           quoted=putc(label,'$quote',l+2+l2*2);
           put 'label' +1 nliteral '=' quoted ';';
           end;
        return;

 /*------------------------------------------------------------------*/
 /* Here the member descriptor records are read (160 bytes of data). */
 /* The memname is read, which is 8 bytes for V5 and 32 for V8. We   */
 /* see if the member is one we want to convert. If so we extract    */
 /* the data set label and data set type. Note that LRECL=32767 is   */
 /* used for non-MVS since RECFM=N needs an indicator of maximum     */
 /* buffer size or it uses 256, which will be too small in some      */
 /* cases. The INPUT statement is started, using &first_memnnnn      */ 
 /* which will be defined by time the INPUT statement is actually    */
 /* executed.                                                        */
 /*------------------------------------------------------------------*/

process_desc_records:;
     if memnum>0 then link fobslobs;
     l=160; link getbytes;
     if v6comp then do;
        memname=input(substr(buffer,9,8),$ascii8.);
        end;
     else do;
        memname=input(substr(buffer,9,32),$ascii32.);
        end;
     if put(upcase(memname),$memwant.) ne 'Y' then do;
        type='skip';
        return;
        end;
     length dslabel $82;
     dslabel=input(substr(buffer,113,40),$ascii40.);
     dstype=input(substr(buffer,153,8),$ascii8.);
     memnum+1;
     file metadata;
     put "data &libref.." memname @;
     if dstype ne ' ' or dslabel ne ' ' then do;
        put '(' @;
        l=length(dslabel);
        if l>0 then do;
           dslabel=put(dslabel,$quote.);
           put 'label=' dslabel @;
           end;
        put ')' @;
        end;
     put ";"; 
     put "infile &filespec. &dcb." @; 
%if &sysscp ne OS %then %do; 
     put ' lrecl=32767 ';
%end;
     put ';'; 
     put '     if _n_=1 then input @&firstobs_mem' memnum z4. '@;';
     file inptstmt;
     put 'input';
     type='none';
     return;

process_label_record:;
     labeldata=0;
     do i=1 to n_long_labels; 
        l=6; labeldata+6; link getbytes; 
        varnum=input(substr(buffer,1,2),s370fpib2.); 
        name_len=input(substr(buffer,3,2),s370fpib2.); 
        label_len=input(substr(buffer,5,2),s370fpib2.); 
        l=name_len+label_len; labeldata+l; link getbytes; 
        name=substr(buffer,1,name_len); 
        label=substr(buffer,name_len+1,label_len); 
        link make_nliteral; 
        file metadata; 
        link quote_label; 
        end;

     *-----read the trailing blanks after the last label if present-*; 
     l=mod(labeldata,80);
     if l>0 then do;
        l=80-l;
        link getbytes;
        end;
     type='none';
     return;

process_label_record9:;
     labeldata=0;
     do i=1 to n_long_labels; 
        l=10; labeldata+10; link getbytes; 
        varnum=input(substr(buffer,1,2),s370fpib2.); 
        name_len=input(substr(buffer,3,2),s370fpib2.); 
        label_len=input(substr(buffer,5,2),s370fpib2.); 
        fmtname_len=input(substr(buffer,7,2),s370fpib2.); 
        infmtname_len=input(substr(buffer,9,2),s370fpib2.); 
        l=name_len+label_len+fmtname_len+infmtname_len; 
        labeldata+l; link getbytes; 
        name=substr(buffer,1,name_len); 
        label=substr(buffer,name_len+1,label_len); 
        format=substr(buffer,name_len+label_len+1,fmtname_len); 
        informat=substr(buffer,name_len+label_len+fmtname_len+1,infmtname_len); 
        link make_nliteral; 
        file metadata; 
        if label ne ' ' then link quote_label; 
        if format ne ' ' then put 'format' +1 nliteral +1 format ';';
        if informat ne ' ' then put 'informat' +1 nliteral +1 informat ';';
        end;

     *-----read the trailing blanks after the last label if present-*; 
     l=mod(labeldata,80);
     if l>0 then do;
        l=80-l;
        link getbytes;
        end;
     type='none';
     return;

 /*------------------------------------------------------------------*/
 /* We get to this point if the OBS record is read. We save where    */
 /* we are for firstobs. We also generate the remaining code after   */
 /* the INPUT statement.                                             */
 /*------------------------------------------------------------------*/

process_data_record:;
     file metadata;
     put '/* INPUT STATEMENT HERE */';
     file inptstmt;
     put '@@;';
     put '     output; if _n_=&obs_mem' memnum z4. ' then stop;';
     put 'run;';
     firstobs=recnum+1; retain firstobs; 
     return;
     run;
 
 /*------------------------------------------------------------------*/
 /* Here we interleave the metadata and input statements. The text   */
 /* INPUT STATEMENT HERE in the metadata section indicates the       */
 /* code from the INPUT statement is to be brought in until 'run;'   */
 /* is seen.                                                         */
 /*------------------------------------------------------------------*/

filename sascode temp;
data _null_; file sascode;
     retain frominput 0;
     if frominput then infile inptstmt;
     else infile metadata;
     input;
     if _infile_='/* INPUT STATEMENT HERE */' then do;
        frominput=1;
        return;
        end;
     put _infile_;
     if _infile_='run;' then do;
        frominput=0;
        end;
     run;
filename metadata clear; 
filename inptstmt clear; 

 /*------------------------------------------------------------------*/
 /* On MVS, we can't use RECFM=N and stream input. Instead we have   */
 /* to use a link routine to stream in our bytes of data. So here    */
 /* we post-process the INPUT statement and change it to use         */
 /* a link to getbytes. The getbytes link routine uses several       */
 /* local variables that we don't want to collide with the names of  */
 /* the actual input variables, so we have all local variables       */
 /* prefixed with a silly name 'goobly' so that we won't collide.    */
 /*                                                                  */
 /* This code                                                        */
 /*                                                                  */
 /* if _n_=1 then input @&firstobs_memnnnn. @;                       */
 /* input                                                            */
 /* x XPORTFLT8.                                                     */
 /* y $ASCII8.                                                       */
 /* ...                                                              */
 /* @@;                                                              */
 /* output; if _n_=&obs_memnnnn then stop;                           */
 /*                                                                  */
 /* becomes                                                          */
 /*                                                                  */
 /* infile ... firstobs=n recfm=fb lrecl=80;                         */
 /* l=8; link getbytes; x=input(buffer,XPORTFLT8.);                  */
 /* l=8; link getbytes; y=input(buffer,$ASCII8.);                    */
 /* output; if _n_=&obs_memnnnn then stop;                           */
 /*                                                                  */
 /* where n is determined from &firstobs_memnnnn.                    */
 /*------------------------------------------------------------------*/
 
%if &sysscp=OS %then %do;
filename mvscode temp;
data _null_; infile sascode length=l; file mvscode;
     retain replace 0;
     input @; input @1 record $varying80. l;
     if not replace and record=:'infile' then do;
        input @; input @1 next $varying80. l;
        macname=scan(next,2,'&@');
        memnum=substr(macname,length(macname)-3,4);
        firstobs=(input(symget(macname),best12.)-1)/80 + 1;
        i=length(record);
        substr(record,i)=' firstobs='||
                         trim(left(put(firstobs,best12.)))||';';
        put record;
        maxlen=symget('maxlen_mem'||memnum);
        put 'length &p.buffer $' maxlen ';';
        return;
        end;
     if record='input' then do;
        replace=1;
        return;
        end;
     if replace and record='@@;' then do;
        replace=0;
        return;
        end;
     if record='run;' then do;
        put '%getbytes(&p);';
        end;
     if not replace then do;
        put record;
        return;
        end;
     informat=scan(record,-1,' ');
     if informat=:'XPRTFLT' then do; 
        length=input(substr(informat,8,1),1.);
        end;
     else do; 
        length=input(substr(informat,7,5),5.);
        end;
     name=substr(record,1,length(record)-length(informat)); 
     put '&p.l=' length '; link getbytes;' @;
     put name '= input(&p.buffer,' informat ');';
     run;
filename sascode clear; 
filename sascode temp;
data _null_; infile mvscode; file sascode; 
     input; put _infile_; 
     run;
filename mvscode clear;
%let p=goobly;
%end;

 *-----execute the generated code-----*; 
%include sascode; run;
filename sascode clear;
%mend xpt2loc;
 

