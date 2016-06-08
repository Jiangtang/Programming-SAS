proc format;
 value $ gender 'F'='Female' 'M'='Male';
data income(label='Annual Income');
 input name $ street $ income  gender $;
 format income dollar11.2 gender gender.;
 label name='Last Name, First Name'
 street='Address'
 income='Annual Income'
 gender='Gender';
 cards;
Leverling Hazel  54789 F
Peacock  Broadway 4565 F
Smith  Mars 86685 M
Buchanan   Drive 23567 M
Suyama   Ave 65778 M
King  Main 45654 M
Callahan  8th 134656 F
Dodsworth  Pleasant  5433 F
Davolio  Peanut  57654 F
;

data ex1;
 dsid=open('income','i');
 n_obs=attrn(dsid,'nobs');
 n_vars=attrn(dsid,'nvars');
dslabel=attrc(dsid,'label');
rc=close(dsid);
run;
proc print;run;



data ex2;
dsid=open('income','i');
n=attrn(dsid,'nvars');
*>> Find the length of the longest variables;
maxlen=0;
do while(fetch(dsid)=0);
 do i=1 to n;
 if (vartype(dsid,i)='C') then do;
 value=getvarc(dsid,i);
 newlen=length(left(trim(value)));
 if newlen>maxlen then do;
 maxlen=newlen;
 end;
 end;
 end;
end;
*>> Find the obs. number, var. name and var.value of the longest length;
first=.;
rc=rewind(dsid);
do while(fetch(dsid)=0);
 do i=1 to n;
 if (vartype(dsid,i)='C') then do;
 value=getvarc(dsid,i);
 newlen=length(left(trim(value)));
 if newlen=maxlen then do;
 varname=varname(dsid,i);
 obsnum=curobs(dsid);
 if first=. then first=note(dsid);
 output;
 end;
 end;
 end;
end;
*>> Find the obs. number of first and last obs. with longest length;
rc=point(dsid,first);
rc=fetch(dsid);
*rc=dropnote(dsid, note);
call symput('firstobs',put(curobs(dsid),3.));
rc=fetchobs(dsid,obsnum);
call symput('lastobs',put(curobs(dsid),3.));
keep obsnum varname value maxlen;
/*rc=close(dsid);*/
run;
proc print;run;
%put _users_;
