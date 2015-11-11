/* ---------------------------------------------------------------------------------
   IMPORTANT! READ THIS CAREFULLY!

   This code assumes that the SASPairs directory (folder) and all its subdirectories
   (folders) have been downloaded and uncompressed (unzipped) in your SASUSER
   directory. If the SASPairs directory is located somewhere else, then DO NOT
   SUBMIT THIS CODE!

   If the downloaded SASPairs directory and its subdirectories are not located in
   the SASUSER directory, then you can do one of two things:
   (1) move the SASPairs directory into the SASUSER directory and then run this
       code.
   (2) perform a manual installation (see the pdf document "Installing SASPairs"
       at http://psych.colorado.edu/SASPairs for instructions)
 
   If you are uncertain where your SASUSER directory is located, then select the
   following line, submit it to SAS, and look at the SAS Log.
   %put My SASUSER Directory is %sysfunc(pathname(sasuser));
  --------------------------------------------------------------------------------- */

%macro saspairs_install;
	%saspairs_setup_autoexec;
	%saspairs_install_datasets;
	%saspairs_install_GUIcat;
%mend saspairs_install;

%macro saspairs_setup_autoexec;
%* ----------------------------------------------------------------
	Appends libname statements and adds SASPairs_Macros
	to a users autoexec.sas file
	If autoexec.sas is not present, then it creates one
	NOTE: This works with Unix, Linux and Windows but it may not
		  work with other operating systems, and certainly will not
		  work with any OS that does not use a / or a \ to
		  delimit directories.
   ----------------------------------------------------------------
	%* check if sas used an autoexec.sas file;
	%let autox = %str(%sysfunc(getoption(autoexec)));
	%if %quote(&autox) ne %then %do;
		%put NOTE: Current autoexec.sas = &autox;
		%put NOTE: SASPairs initialization commands will be appended to this file.;
	%end;
	%else %do;
		%* create the autoexec.sas file;
		%let autox = %str(autoexec.sas);
		data _null_;
			file 'autoexec.sas';
			today = date();
			put '/* --- file ' "&autox" ' created on ' today date9. ' --- */' ;
		run;
		%put NOTE: file &autox created.;
	%end;

	%* find the location of the SASUSER directory;
	%let root = %sysfunc(pathname(sasuser));
	%put NOTE: SASUSER directory is:;
	%put &root;

	%* get the operating system to set the delimiter for directories;
	%if &sysscp = WIN %then %let delim = \;
	%else %let delim = /;

	%let sproot = SASPairs;
	%let sproot = &root&delim&sproot;
	%put NOTE: libname saspairs will be assigned to directory:;
	%put &sproot;

	%let temp = SASPairs_IML_Source;
	%let spimlsrc = %str(&sproot&delim&temp);
	%put NOTE: libname spimlsrc will be assigned to directory:;
	%put &spimlsrc;

	%let temp = SASPairs_MDS_Library;
	%let spmdslib = %str(&sproot&delim&temp);
	%put NOTE: libname spmdslib will be assigned to directory:;
	%put &spmdslib;

	%let temp = SASPairs_Sproject;
	%let sproject = %str(&sproot&delim&temp);
	%put NOTE: libname sproject will be assigned to directory:;
	%put &sproject;

	%let temp = SASPairs_OtherStuff;
	%let spothstf = %str(&sproot&delim&temp);
	%put NOTE: libname spothstf will be assigned to directory:;
	%put &spothstf;

	%let temp = SASPairs_GUI;
	%let spguilib = %str(&sproot&delim&temp);
	%put NOTE: libname spguilib will be assigned to directory:;
	%put &spguilib;

	%let temp = SASPairs_GUI_Help;
	%let spguihlp = %str(&spguilib&delim&temp);
	%put NOTE: libname spguihlp will be assigned to directory:;
	%put &spguihlp;

	%let current_sasautos = %sysfunc(getoption(sasautos));
	%put NOTE: current SASAUTOS directories:;
	%put &current_sasautos;
	%* fix up the case where SASAUTOS is enclosed in parentheses;
	%let test1 = %substr(&current_sasautos, 1, 1);
	%let test1 = %str("&test1");	
	%let test2 = %str(%();
	%let test2 = %str("&test2");
	%if &test1 = &test2 %then
		%let current_sasautos = %substr(&current_sasautos, 2, %length(&current_sasautos)-2);

	%let temp = SASPairs_Macros;
	%let new_sasautos = %str(&sproot&delim&temp);
	%put NOTE: the following directory will be added to the SASAUTOS path:;
	%put &new_sasautos;

	%* open autoexec.sas to append libname commands;
	%let filrf = auto;
	%let rc  = %sysfunc(filename(filrf, &autox));
	%let fid = %sysfunc(fopen(&filrf,A));

	%let temp = %str(* --- the following lines were added by macro saspairs_setup_autoexec on &sysdate --- *);
	%let slash = %str(/);
	%let temp = &slash&temp&slash;
	%let rc = %sysfunc(fput(&fid,&temp));
	%let rc = %sysfunc(fappend(&fid));

	%let sproot = %str(libname saspairs "&sproot";);
	%appendit (&fid, &sproot);

	%let spimlsrc = %str(libname spimlsrc "&spimlsrc";);
	%appendit (&fid, &spimlsrc);

	%let spmdslib = %str(libname spmdslib "&spmdslib" ;);
	%appendit (&fid, &spmdslib);

	%let sproject = %str(libname sproject "&sproject" ;);
	%appendit (&fid, &sproject);

	%let spothstf = %str(libname spothstf "&spothstf" ;);
	%appendit (&fid, &spothstf);

	%let spguilib = %str(libname spguilib "&spguilib" ;);
	%appendit (&fid, &spguilib);

	%let spguihlp = %str(libname spguihlp "&spguihlp" ;);
	%appendit (&fid, &spguihlp);

	%let temp = %str(options SASAUTOS=(&current_sasautos, "&new_sasautos"););
	%appendit (&fid, &temp);

	%let temp = %str(options mautosource;);
	%appendit (&fid, &temp);

	%* SASEXE_File and SPSSEXE_File;
	%batch_commands (&fid);

	%let temp = %str(* --- end of lines added by macro saspairs_setup_autoexec on &sysdate --- *);
	%let slash = %str(/);
	%let temp = &slash&temp&slash;
	%let rc = %sysfunc(fput(&fid,&temp));
	%let rc = %sysfunc(fappend(&fid));

	%* close the data set and remove the fileref;
	%let rc = %sysfunc(fclose(&fid));
	%let rc = %sysfunc(filename(filrf));
	%put NOTE: Lines appended to &autox;

	%* create file SPSSJob1.spp for converting SPSS .sav files to SPSS .por files;
	%if &sysscp = WIN %then %spss_windows_setup;

%mend saspairs_setup_autoexec;

%macro appendit (fid, command);
	%* appends a command to the autoexec.sas file;
	%let rc = %sysfunc(fput(&fid,&command));
	%let rc = %sysfunc(fappend(&fid));
	%* execute the command;
	&command
%mend appendit;

%macro saspairs_nwords (string);
	%* calculates the number of words in a string;
	%local word;
	%let count = 1;
	%let word = %qscan(&string, &count, %str( ));
	%do %while (&word ne);
		%let count = %eval(&count + 1);
		%let word = %qscan(&string, &count, %str( ));
	%end;
	%let count = %eval(&count - 1);
	&count
%mend;

%macro batch_commands (fid);
	%* add lines to autoexec.sas for macro variables SASEXE_File and SPSSEXE_File;
	%if &sysscp = WIN %then %do;
		%let cmd=;
		%if %sysfunc(fileexist(C:\Program Files\SAS\SAS 9.1\sas.exe)) = 1 %then %do;
				%let SASEXE_File = C:\Program Files\SAS\SAS 9.1\sas.exe;
				%let cmd = %nrstr(%let SASEXE_File = C:\Program Files\SAS\SAS 9.1\sas.exe;);
				%appendit2 (&fid, &cmd);
			%end;
		%else %if %sysfunc(fileexist(C:\Program Files\SAS Institute\SAS\V8\sas.exe)) = 1 %then %do;
				%let SASEXE_File = C:\Program Files\SAS Institute\SAS\V8\sas.exe;
				%let cmd = %nrstr(%let SASEXE_File = C:\Program Files\SAS Institute\SAS\V8\sas.exe;);
				%appendit2 (&fid, &cmd);
			%end;

		%if %sysfunc(fileexist(C:\Program Files\SPSS\spssprod.exe)) = 1 %then %do;
			%let SPSSEXE_File = C:\Program Files\SPSS\spssprod.exe;
			%let cmd = %nrstr(%let SPSSEXE_File = C:\Program Files\SPSS\spssprod.exe;);
			%appendit2 (&fid, &cmd);
		%end;
	%end;

	%else %do;
		%let SASEXE_File = sas;
		%let cmd = %nrstr(%let SASEXE_File = sas;);
		%appendit2 (&fid, &cmd);
		%let SPSSEXE_File = spss;
		%let cmd = %nrstr(%let SPSSEXE_File = spss;);
		%appendit2 (&fid, &cmd);
	%end;
%mend;

%macro appendit2 (fid, command);                                                                                                                               
	%let rc = %sysfunc(fput(&fid,&command));
	%let rc = %sysfunc(fappend(&fid));
%mend;

%macro spss_windows_setup;
	%let delim=\;
	%let dot=%str(.); 
    %let temp = %sysfunc(pathname(SPROJECT));
	%let temp2 = %str(SPSSJob1.spp);
	%let thisfile = &temp&delim&temp2;
	%let temp= temp;
	%let fid = %sysfunc(filename(temp, &thisfile));                                                                                                          
    %let fid = %sysfunc(fopen(temp, O));                                                                                                            

    %let temp = %str(*Creator/owner: ) %sysfunc(sysget(USERNAME))&dot; %appendit2(&fid, &temp);                                                                          
    %let temp = %str(*Date: 9/17/2004.);              %appendit2(&fid, &temp); 
    %let temp = ;                                     %appendit2(&fid, &temp); 
    %let temp = %str(SET MXCELLS=AUTOMATIC .);        %appendit2(&fid, &temp); 
    %let temp = %str(INCLUDE FILE=);
	%let temp2 = %sysfunc(pathname(SPROJECT));
	%let temp3 = %str(\SPSStoSAS.sps);
	%let temp = &temp"&temp2&temp3"&dot;              %appendit2(&fid, &temp);
    %let temp = ;                                     %appendit2(&fid, &temp); 
    %let temp = %str(*Comments:.);                    %appendit2(&fid, &temp); 
    %let temp = %str(* .);                            %appendit2(&fid, &temp);
    %let temp = ;                                     %appendit2(&fid, &temp); 
    %let temp = %str(*Output Folder: )&temp2&dot;     %appendit2(&fid, &temp); 
    %let temp = %str(*Export Chart Format: JPEG File.);   %appendit2(&fid, &temp); 
    %let temp = %str(*Exported File Format: 0.);          %appendit2(&fid, &temp); 
    %let temp = %str(*Export Objects: 3.);                %appendit2(&fid, &temp); 
    %let temp = %str(*Output Type: 0.);                   %appendit2(&fid, &temp); 
    %let temp = %str(*Print output on completion: Off.);  %appendit2(&fid, &temp); 
    %let temp = ;                                         %appendit2(&fid, &temp); 
    %let temp = %str(*PublishToWeb Cfg GUID: .);          %appendit2(&fid, &temp); 
    %let temp = %str(*PublishToWeb Objects: 6.);          %appendit2(&fid, &temp); 
    %let temp = %str(*PublishToWeb Table: 1.);            %appendit2(&fid, &temp); 
    %let temp = %str(*PublishToWeb UsrID: .);             %appendit2(&fid, &temp); 
    %let temp = %str(*PublishToWeb Authetication: .);     %appendit2(&fid, &temp); 
    %let temp = ;                                         %appendit2(&fid, &temp); 
    %let fid = %sysfunc(fclose(&fid));
	%let temp = temp;
	%let temp2 =; 
    %let rc = %sysfunc(filename(temp, &temp2));
%mend;

%macro saspairs_includeit (sppath, file, dotsas, dotdat);
	%* sets the name of the .dat file and executes the .sas file
		to create SAS data sets from the files in SASPairs_OtherStuff;
	%let infilename = &sppath&file&dotdat;
	%let includefile = &sppath&file&dotsas;
	%include "&includefile";
%mend saspairs_includeit;

%macro saspairs_install_datasets;
%* ----------------------------------------------------------------
	Installs SAS datasets in SAS Libraries spimlsrc, spmdslib,
		spothstf, and spguihlp
	NOTE: This works with Unix, Linux and Windows but it may not
		  work with other operating systems, and certainly will not
		  work with any OS that does not use a / or a \ to
		  delimit directories.
   ----------------------------------------------------------------;

	%* find the location of the SASUSER directory;
	%let root = %sysfunc(pathname(sasuser));

	%* get the operating system to set the delimiter for directories;
	%* also get the infile command for the correct system to read in
	   tab delimited data sets;
	%if &sysscp = WIN %then
		%let delim = \;
	%else
		%let delim = /;

	%let sproot = SASPairs;
	%let dotsas = %str(.sas);
	%let dotdat = %str(.dat);

	%* data sets from directory SASPairs_IML_Source;
	%let temp = SASPairs_IML_Source;
	%let sppath = &root&delim&sproot&delim&temp&delim;
	%let filelist = %str(default_matrices reserved_matrix_names testuser_datasets);
	%let nfiles = %saspairs_nwords(&filelist);
	%do i = 1 %to &nfiles;
		%let thisfile = %scan(&filelist, &i, %str( ));
		%saspairs_includeit (&sppath, &thisfile, &dotsas, &dotdat);
	%end;

	%* data sets from directory SASPairs_OtherStuff;
	%let temp = SASPairs_OtherStuff;
	%let sppath = &root&delim&sproot&delim&temp&delim;
	%let filelist = %str(aspire kay_phillips2 marcie_chambers nmtwins relationship_data_sets
                         twindata1 wutwins);
	%let nfiles = %saspairs_nwords(&filelist);
	%do i = 1 %to &nfiles;
		%let thisfile = %scan(&filelist, &i, %str( ));
		%saspairs_includeit (&sppath, &thisfile, &dotsas, &dotdat);
	%end;

	%* TYPE=CORR data set for twindata1;
	%let temp = %str(twindata1_type_eq_corr.sas);
	%let includefile = &sppath&temp;
	%include "&includefile";

	%* data sets from directory SASPairs_GUI_Help;
	%let temp = SASPairs_GUI;
	%let sppath = &root&delim&sproot&delim&temp&delim;
	%let temp = SASPairs_GUI_Help;
	%let sppath = &sppath&delim&temp&delim;
	%let temp = %str(GUIHelp_Datasets.sas);
	%let includefile = &sppath&delim&temp;
	%include "&includefile";

	%* data sets from SASPairs_MDS_Library;
	%let temp = SASPairs_MDS_Library;
	%let mdsdir = &root&delim&sproot&delim&temp;
	%* assign the fileref;
	%let mdslib = mdslib;
	%let rc = %sysfunc(filename(mdslib, &mdsdir));
	%* open the directory and get the number of members;
	%let did = %sysfunc(dopen(&mdslib));
	%let nmembers=%sysfunc(dnum(&did));
	%* loop over directory members, select .sas files and execute them;
	%do i=1 %to &nmembers;
		%let thisfile = %sysfunc(dread(&did,&i));
		%let fl = %eval(%length(&thisfile) - 2);
		%if %upcase(%substr(&thisfile, &fl, 3)) = SAS %then %do;
			%let includefile = &mdsdir&delim&thisfile;
			%include "&includefile";
		%end;
	%end;

	%* close the directory and remove the fileref;
	%let rc=%sysfunc(dclose(&did));
	%let rc=%sysfunc(filename(mdslib));

%mend saspairs_install_datasets;

%macro saspairs_install_GUIcat;
%* --- install the GUI catalog;

	%* find the location of the SASUSER directory;
	%let root = %sysfunc(pathname(sasuser));

	%* get the operating system to set the delimiter for directories;
	%if &sysscp = WIN %then
		%let delim = \;
	%else
		%let delim = /;

	%let temp = SASPairs;
	%let xptfile = &root&delim&temp&delim;
	%let temp = SASPairs_GUI;
	%let xptfile = &xptfile&temp&delim;
	%let temp = spguicat.xpt;
	%let xptfile = &xptfile&temp;

	%* --- assign the fileref;
	%let thisfile = xptfile;
	%let rc = %sysfunc(filename(thisfile, &xptfile));

	%* --- code for CIMPORT;
	PROC CIMPORT
    	CATALOG=spguilib.spguicat
    	NEW
    	INFILE=xptfile;
	RUN;

	%* --- remove the fileref;
	%let rc=%sysfunc(filename(thisfile));
%mend;

* --- execute the macros;
%saspairs_install;
