/*attrc: Returns the value of a character attribute for a SAS data set.*/

proc sort data=sashelp.class out=class;
    by sex age;
run;

data _null_;
   dsid=open("class", "i");   

   MODE=attrc(dsid, "MODE");
   CHARSET=attrc(dsid, "CHARSET");
   DATAREP=attrc(dsid, "DATAREP");
   ENGINE=attrc(dsid, "ENGINE");

   TYPE=attrc(dsid, "TYPE");
   LIB=attrc(dsid, "LIB");
   MEM=attrc(dsid, "MEM");
   MTYPE=attrc(dsid, "MTYPE");
   LABEL=attrc(dsid, "LABEL");

   COMPRESS=attrc(dsid, "COMPRESS");
   ENCRYPT=attrc(dsid, "ENCRYPT");

   SORTEDBY=attrc(dsid, "SORTEDBY");
   SORTLVL=attrc(dsid, "SORTLVL");
   SORTSEQ=attrc(dsid, "SORTSEQ");
   
   rc=close(dsid);

   put (_all_) (=/);
run;

/*attrn: Returns the value of a numeric attribute for a SAS data set.*/

data _null_;
   dsid=open("class", "i");   

   ALTERPW=attrn(dsid, "ALTERPW");
   PW=attrn(dsid, "PW");
   READPW=attrn(dsid, "READPW");
   WRITEPW=attrn(dsid, "WRITEPW");
   ARAND=attrn(dsid, "ARAND"); *RANDOM;
   ARWU=attrn(dsid, "ARWU");
   AUDIT=attrn(dsid, "AUDIT");
   AUDIT_DATA=attrn(dsid, "AUDIT_DATA");
   AUDIT_BEFORE=attrn(dsid, "AUDIT_BEFORE");
   AUDIT_ERROR=attrn(dsid, "AUDIT_ERROR");

   ANOBS=attrn(dsid, "ANOBS");
   NOBS=attrn(dsid, "NOBS");
   NLOBS=attrn(dsid, "NLOBS");
   NLOBSF=attrn(dsid, "NLOBSF");
   ANY=attrn(dsid, "ANY"); *VAROBS;
   NVARS=attrn(dsid, "NVARS");   
  
   CRDTE=attrn(dsid, "CRDTE");
   MODTE=attrn(dsid, "MODTE");
   ICONST=attrn(dsid, "ICONST");  
   INDEX=attrn(dsid, "INDEX");
   ISINDEX=attrn(dsid, "ISINDEX");
   ISSUBSET=attrn(dsid, "ISSUBSET");

   LRECL=attrn(dsid, "LRECL");
   LRID=attrn(dsid, "LRID");

   MAXGEN=attrn(dsid, "MAXGEN");
   NEXTGEN=attrn(dsid, "NEXTGEN");
   MAXRC=attrn(dsid, "MAXRC");
   
   NDEL=attrn(dsid, "NDEL");
   
   RADIX=attrn(dsid, "RADIX");
   
   REUSE=attrn(dsid, "REUSE");
   TAPE=attrn(dsid, "TAPE");
   WHSTMT=attrn(dsid, "WHSTMT");
 
   rc=close(dsid);

   put (_all_) (=/);
run;


/* #7
VARFMT  	Returns the format that is assigned to a SAS data set variable.
VARINFMT  	Returns the informat that is assigned to a SAS data set variable.
VARLABEL  	Returns the label that is assigned to a SAS data set variable.
VARLEN  	Returns the length of a SAS data set variable.
VARNAME  	Returns the name of a SAS data set variable.
VARNUM  	Returns the number of a variable's position in a SAS data set.
VARTYPE  	Returns the data type of a SAS data set variable.

*/
data vars;
   length name $ 8 type $ 1 
          format informat $ 10 label $ 40;   
   dsid=open("class", "i");
   if dsid then do;
       num=attrn(dsid, "nvars");
       do i=1 to num;
          name=varname(dsid, i);
          type=vartype(dsid, i);
          format=varfmt(dsid, i);
          informat=varinfmt(dsid, i);
          label=varlabel(dsid, i);
          length=varlen(dsid, i);
          position=varnum(dsid, name);
           put (_all_) (=/);
          output;
       end;  

/*       drop dsid i num rc;*/
   end;
   else put "ERROR: input dataset does NOT exist";

   rc=close(dsid);
   
run;


/*
fetch
getvarc
curobs
*/

data len;
    dsid=open('class','i');
    n=attrn(dsid,'nvars');
    *>> Find the length of all values in char variables;
    do while(fetch(dsid)=0);
         do i=1 to n;
             if (vartype(dsid,i)='C') then do;
                 varname=varname(dsid, i);
                 value=getvarc(dsid,i);
                 length=length(left(trim(value)));
                  obsnum=curobs(dsid);
                 output;
             end;
         end;
    end;
    rc=close(dsid);

    keep varname value length obsnum;
run;
