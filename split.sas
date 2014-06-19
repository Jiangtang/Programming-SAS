
%macro backwards(var_in=coval,var_out=coval1,temp=temp1);
    do i=&len to 1 by -1 until (rc = 1);
        rc       = index(substr(&var_in,i), ' ');
        &var_out = substr(&var_in,1,i);
        &temp    = substr(&var_in,i+1);
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
            %backwards(var_in=temp&j, var_out=&var_in.&j,temp=temp&jj);
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
