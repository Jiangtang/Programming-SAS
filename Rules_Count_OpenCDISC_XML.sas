*************************************************************************************************;
*Program    Name    : Rules_Count_OpenCDISC_XML.sas                                             *;
*Programmer Name	: Jiangtang Hu                                                              *;
*                     Jiangtanghu@gmail.com                                                     *;
*                     Jiangtanghu.com/blog                                                      *;
*                                                                                               *;
*Purpose            : Count number of rules in OpenCDISC by modules                             *;
*                                                                                               *;
*Input              : dir     - OpenCDISC software installation directory                       *;
*Output             : Frequency tables of  number of rules in OpenCDISC by modules              *;
*Usage              : %Rules_Count_OpenCDISC_XML(dir=C:\Temp\opencdisc-validator\config)        *;
*                                                                                               *;
*                                                                                               *;
*License            : public domain, ABSOLUTELY NO WARRANTY                                     *;
*Platform           : tested in WinXP SAS/Base 9.2 and Win64 SAS/Base 9.3                       *;
*Version            : V1.0                                                                      *;
*Date		        : 19Feb2012                                                                 *;
*************************************************************************************************;


%macro Rules_Count_OpenCDISC_XML(dir=C:\Temp\opencdisc-validator\config);

/*get XML files list from OpenCDISC directory*/
filename XMLList pipe "dir /B &dir\*.xml";

data XMLList;
	length XMLName $40;
	infile XMLList length=reclen;
	input XMLName $varying40. reclen;
run;

data _null_;
	set XMLList end=eof;
	II=left(put(_n_,2.));
	call symputx('XMLName'||II,compress(XMLName));
	if eof then call symputx('total',II);
run;

/*read OpenCDISC configuration files*/
%do i=1 %to &total;
	%put &&XMLName&i;

	filename module&i "&dir.\&&XMLName&i";

	data XMLName&i;
		length source $40;
		infile module&i;
		input;
		text=_infile_;
		if text = "" then delete;

		order=&i;
		source="&&XMLName&i";
		temp=catx("",scan("&&XMLName&i",2,'-'),compress(scan("&&XMLName&i",3,'-'),'xml'));
		module=substr(temp,1,length(temp)-1);
	run;

	data module&i;
		length rule_id $6;
		set XMLName&i;

		if _n_ = 1 then do;
			retain quename queCo1 queCo2;

			data="/[A-Z]{2}\d{4}/";
			comment1="/<!--/";
			comment2="/-->/";

			queName=prxparse(data);
			queCo1=prxparse(comment1);
			queCo2=prxparse(comment2);

			if missing(queName) then do;
				putlog "ERROR: Invalid regexp" data;
			end;

			if missing(queCo1) then do;
				putlog "ERROR: Invalid regexp" queCo1;
			end;

			if missing(queCo2) then do;
				putlog "ERROR: Invalid regexp" queCo2;
			end;

		end;

		queNameN=prxmatch(queName,text);
		queCo1N=prxmatch(queCo1,compress(text));
		queCo2N=prxmatch(queCo2,compress(text));

		*delete XML comments;
		*rule OD0004, OD0005, OD0007, OD0008 are commented in config-define-1.0.xml;
		if queCo1N > 0 or queCo2N > 0 then delete;

		if quenamen > 0 then do;
			rule_id=substr(text,quenamen,6);
			keep order module rule_id source;
			output;
		end;
	run;

	proc sort nodup;
		by rule_id;
	run;

%end;

data CDISC;
	set %do i=1 %to &total; module&i %end; ;

	rule_type=substr(rule_id,1,2);
run;

proc sql;
	select count(distinct rule_id) as rules_total_unique
	from cdisc
	;
quit;

proc freq data=cdisc;
	tables module*rule_type /nopercent nocol norow;
run;

%mend Rules_Count_OpenCDISC_XML;

%*Rules_Count_OpenCDISC_XML;
