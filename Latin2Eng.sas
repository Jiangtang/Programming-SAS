*******************************************************************************************************************;
*Program    Name    : Latin2Eng.sas                                                                               *;
*Programmer Name	: Jiangtang Hu                                                                                *;
*                     Jiangtanghu@gmail.com                                                                       *;
*                     Jiangtanghu.com/blog                                                                        *;
*                                                                                                                 *;
*Purpose            : Translate Latin sentence to English                                                         *;
*                                                                                                                 *;
*Input              : Input_Latin     - the Latin sentence                                                        *;
*Output             : A Cartesian combination of all seperated Latin words (word to word translation)             *;
*Usage              : %Latin2Eng(draco dormiens nunquam titillandus)                                              *;
*                                                                                                                 *;
*References         : WORDS - Version 1.97FC, by William Whitaker                                                 *;
*                     a LATIN-ENGLISH DICTIONARY PROGRAM, http://users.erols.com/whitaker/words.htm               *;
*                                                                                                                 *;
*License            : public domain, ABSOLUTELY NO WARRANTY                                                       *;
*Platform           : tested in WinXP SAS/Base 9.2                                                                *;
*Version            : V1.1                                                                                        *;
*Date		        : 08Oct2011                                                                                   *;
*******************************************************************************************************************;



/*macro to recursively creat string list  like
ff1,ff2,ff3,ff4...

test:
%put %_list(4);

*/

%macro _list(n,pre=ff);
    %if &n=1 %then &pre.1; 
 	%else %_list(%eval(&n-1)),&pre.&n; 
%mend _list;


/*core macro: from Latin to English*/

%macro Latin2Eng(Input_Latin,engine=http://lysy2.archives.nd.edu/cgi-bin/words.exe?);

data URL;
	Input_Latin="&Input_Latin";
	engine="&engine";
	
	i=1;
	do while (scan(Input_Latin,i) ne "");
		input=scan(Input_Latin,i);
		URL=compress(input);	
		output;	
		i=i+1;
	end;
run;

data _null_;
	set URL end=eof;

	II=left(put(i,2.));
	call symputx('URL'||II,URL); 
    if eof then call symputx('total',II); 
run;


%do i=1 %to &total; 
    filename f&i URL "&engine.&&URL&i";   

    data f&i; 
        length text $1024; 
        infile f&i lrecl=1024; 
        input text $; 
        text= _infile_; 

		if index(text,"<") then delete;	*need to improve;
		if index(text,"*") then delete;	*need to improve;
    run;

	data ff&i;
		set f&i end=eof;
		if eof;

		j=1;
		do while (scan(text,j,";") ne "");
			&&URL&i=scan(text,j,";");
			output;	
			j=j+1;
		end;

		drop text j;
	run;
%end;

data all;
	merge %do i=1 %to &total; ff&i %end;;
run;

proc print data=all;     
run;

proc sql;                  
  create table Cartesian as    
    select *      
    from %_list(&total)
	;              
quit;                     
                           
proc print data=Cartesian;     
run;
%mend  Latin2Eng;

%*Latin2Eng(draco dormiens nunquam titillandus)
