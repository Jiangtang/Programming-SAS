libname sdtm "a:\";

data co;
    set sdtm.co (obs=6 keep=coval);
    len=length(coval);
run;

/*http://www.nesug.org/Proceedings/nesug97/coders/riba.pdf*/


data out;
    set co;

    length txt1 txt2 txt3  t_txt $ 250 ;

    min = 1 ;   *minimum (MIN) number of characters per line;
    max = 200 ; * maximum (MAX)number of characters per line;

    sav_max = max ;   *MAX changes during execution;

    lentxt = length(trim(COVAL)) ; * length of original text string;

    if (lentxt lt (max+1)) then txt1 = COVAL ;
    else do until (max gt lentxt);

     tmptxt = substr(COVAL,min,max) ;

     rc = 0 ;
     do i = sav_max to 1 by -1  until (rc eq 1) ;
        rc=index(substr(t_txt,i),' ');  * scan the string backwards until a word break;
     end ;
     
     t_txt = substr(COVAL,1,i) ;

     if (length(trim(txt1)) le 1)        then txt1 = t_txt ;
     else if (length(trim(txt2)) le 1)   then txt2 = t_txt ;
     else if (length(trim(txt3)) le 1)   then txt3 = t_txt ;

     min = min((min+i-1),lentxt) ;

     if (max eq lentxt) then max + 1 ;
     else  max = min(sum(max,i),lentxt) ;
    end ;
run;


data o;
    set co;
    lentxt = length(trim(COVAL));
    if len<=200 then coval1=coval;

    if 200<len<400 then do;
        do i=200 to 1 by -1 until (rc = 1);
            rc = index(substr(coval,i), ' ');
            coval1=substr(coval,1,i);
            coval2=substr(coval,i+1);
        end;
    end;

    if 400<=len<600 then do;
        do i=200 to 1 by -1 until (rc = 1);
            rc = index(substr(coval,i), ' ');
            coval1=substr(coval,1,i);
            coval_t=substr(coval,i+1);
        end;

        do i=200 to 1 by -1 until (rc = 1);
            rc = index(substr(coval_t,i), ' ');
            coval2=substr(coval_t,1,i);
            coval3=substr(coval_t,i+1);
        end;
    end;

    L1=length(coval1);
    L2=length(coval2);
    L3=length(coval3);

    drop coval_t rc i;

run;

/*recu*/
data o;
    set co;

    do i=200 to 1 by -1 until (rc = 1);
        rc = index(substr(coval,i), ' ');
        coval1=substr(coval,1,i);
        coval_t1=substr(coval,i+1);
    end;

    do i=200 to 1 by -1 until (rc = 1);
        rc = index(substr(coval_t1,i), ' ');
        coval2=substr(coval_t1,1,i);
        coval_t2=substr(coval_t1,i+1);
    end;

    do i=200 to 1 by -1 until (rc = 1);
        rc = index(substr(coval_t2,i), ' ');
        coval3=substr(coval_t2,1,i);
        coval_t3=substr(coval_t2,i+1);
    end;

    do i=200 to 1 by -1 until (rc = 1);
        rc = index(substr(coval_t3,i), ' ');
        coval4=substr(coval_t3,1,i);
        coval_t4=substr(coval_t3,i+1);
    end;

    L1=length(coval1);
    L2=length(coval2);
    L3=length(coval3);
    L4=length(coval4);
    
    drop coval_t: rc i;
run;



/*recu -m*/

/*question to */
/*1. keep coval? or use coval1 to replace coval?*/
/*2. interface: or %doit(ds,out,var,var1-2)?*/



%macro backwards(_in=coval,_out=coval1,temp=temp1);
    do i=&len to 1 by -1 until (rc = 1);
        rc       = index(substr(&_in,i), ' ');
        &_out = substr(&_in,1,i);
        &temp    = substr(&_in,i+1);
    end;
%mend backwards;


%macro split(ds_in=,ds_out=,var_in=,len=200);

data temp;
    set &ds_in;
    len=length(&var_in);
    bin=ceil(len/&len);
    temp1=&var_in; 
run;

proc sql noprint;
    select max(bin) into:bin
    from temp
    ;
quit;

data &ds_out;
    length %do i=1 %to &bin; &var_in.&i $&len. %end; ;    
    set temp;  
 
    if len<=&len then &var_in.1=&var_in;   
    else do;
        %do j=1 %to &bin; 
            %let jj=%eval(1+&j);
            %backwards(_in=temp&j, _out=&var_in.&j,temp=temp&jj);
        %end;
    end;    
 
    drop temp: rc i len bin;
run;

proc datasets nolist;
    delete temp;
run;
quit;
%mend split;

/*test*/

%split(ds_in=co,ds_out=co2,var_in=COVAL,len=200);


