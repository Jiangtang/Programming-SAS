
/*
http://support.sas.com/resources/papers/proceedings09/076-2009.pdf
 	Harry Droogendyk

*/

%macro list_sasautos(help,work=Y);

	%if &help = ? or %upcase(&help) = HELP %then %do;
	%put;
	%put;
	%put %nrstr(%list_sasautos(work=Y););
	%put;
	%put %nrstr(Lists the .sas files and catalog source/macro objects found within directories surfaced by:);
	%put %nrstr( - getoption('sasautos') - SASAUTOS altered by options statement);
	%put %nrstr( - pathname('sasautos') - config file SASAUTOS definition);
	%put %nrstr( - filerefs / catalogs found within SASAUTOS definitions);
	%put %nrstr( - pathname(getoption('sasmstore')) - compiled macros.);
	%put ;
	%put %nrstr(If &work=Y ( default ), compiled macros from the WORK library will be included 	as well.);
	%put ;
	%put %nrstr(NOTE: Not every .sas / source module found within these directories is );
	%put %nrstr(NOTE: NECESSARILY a macro definition. %list_sasautos does NOT open up );
	%put %nrstr(NOTE: objects to verify the presence of the required %macro statement.);
	%put ;
	%put %nrstr(In addition to the OUTPUT report ( use ODS for fancier report formats ), );
	%put %nrstr(results are also available in the WORK._LIST_SASAUTOS dataset.);
	%put;
	%goto exit;
	%end;
	
	/*
	work.sasmacr and the sasmacr catalog found at the SASMSTORE location
	are the first searched. If &WORK=Y, grab the path info for the work
	directory. If the SASMSTORE option is set, surface the path information
	for that library. We'll include at the front of the concatenation since
	reflects the search order SAS uses.
	*/
	
	
	%if %upcase(&work) = Y and %sysfunc(cexist(work.sasmacr)) %then
		%let work_lib = %unquote(%str(%')%sysfunc(pathname(work))%str(%'));
	%else
		%local work_lib;
		
	%let sasmstore = %sysfunc(getoption(sasmstore));
	
	%if &sasmstore ne %str() %then %do;
		%let sasmstore = %sysfunc(pathname(&sasmstore));
		%if %bquote(&sasmstore) ne %str() %then
		%let sasmstore = %unquote(%str(%')&sasmstore%str(%'));
	%end;
	
	data _list_sasautos ( keep = path member order type catalog );
	
	if substr(upcase("&sysscp"),1,3) = 'WIN' then
		s = '\';
	else
		s = '/';
		
	length 	pathname	sasautos $32000
			path chunk	option $2000
			member $200
			catalog $32
			type $8
	;
	
	label   path = 'O/S Path'
			member = 'Macro / Filename'
			type = 'Object Type'
			catalog = 'Catalog Name'
			order = 'Resolution Order'
	;
	catalog = ' '; /* to avoid not initialized msg */
	option = compress(getoption('sasautos'),'()'); /* get SASAUTOS option value */
	
	/*
	Grab space-delimited SASAUTOS definitions. Entries that are file system paths will be
	captured and file references, SASAUTOS and catalog references will be expanded.
	*/
	
	do i = 1 to &sysmaxlong until ( scanq(option,i,' ') = ' ' );
	
		chunk = compress(scanq(option,i,' '),"'");
		
		if indexc(chunk,':/\') then do; /* if path delimiters found, pass straight in */
			sasautos = catx(' ', sasautos, chunk );
		end; 
		else do; /* no path delimiters found, expand the entry to the path level */
			pathname = compress(pathname(chunk),'()');
			
			if pathname > ' ' then do;
			
				if pathname =: '..' then do; /* catalog libname starts with .. */
				
					cat_pathname = substr(pathname,3); /* skip over two dots */
					/* Since we have catalog name, insert it in the path
					with surrounding single quotes */
					path = pathname(scan(trim(cat_pathname),1,'.')) || s ||
					scan(trim(cat_pathname),2,'.') || '.SAS7BCAT';
					sasautos = catx(' ', sasautos, "'"||trim(path)||"'" );
				end; 
				else do; * must have SASAUTOS or a file reference,
					SASAUTOS paths start with a single quote ;
					if left(pathname) =: "'" then
					sasautos = catx(' ', sasautos, compress(pathname,'()')); /* sasautos */
					else
					sasautos = catx(' ', sasautos, "'"||trim(pathname)||"'"); /* fileref */
				end;
			end;
		end;
	end;
	
	
	/*
	If we're going after WORK and COMPILED STORED macros, add their paths at
	the front since that's the search order SAS uses
	*/
	sasautos = left("&work_lib &sasmstore " || translate(sasautos,"'",'"'));
	put / 'Processing: ' option= // sasautos= ;
	cat = 0;
	order = 0;


	/*
	Chew through the fleshed out list of paths / catalogs. We added quotes to
	paths in some cases so we could use the scanq below. However, we want to
	remove them before we use the path
	*/
	
	do i = 1 to &sysmaxlong until ( scanq(sasautos,i,' ') = ' ' );
		path = compress(scanq(sasautos,i,' '),"'");
		
		/*
		Where the fileref pointed to a SAS catalog, we have specified the SAS7BCAT suffix to
		ensure we pick up only the specified catalog at this path. Since we're processing
		catalogs in more than one spot, we're using a common routine
		*/
		
		if scan(path,-1,'.') = 'SAS7BCAT' then do;
			member = scan(path,-1,s);
			path = substr(path,1,length(path)-length(member)-1);
			link do_cat; /* catalog identified via fileref */
		end; 
		else do; /* if it ain't a catalog, it must be a directory */
		problem = filename('dir',trim(path)); /* create a fileref pointing to dir */
		
		if problem then do;
			put 'Cannot open filename for ' path;
		end; 
		else do;
		d = dopen('dir'); /* open the directory */
		if d then do; /* directory successsfully open? */
		num = dnum(d); /* number of files in directory */
		do _i = 1 to num; /* loop through files in directory */
		member = dread(d,_i); /* get next filename in directory */
		/*
		Try to append the member name to the end of the path and open it
		as a directory, if that's successful, we don't want it,
		ie. we only want real files
		*/
		dir_test_file = filename('dir_test',cats(path,s,member));
		if dir_test_file then continue; * cannot assign filename, iterate loop ;
		dtf = dopen('dir_test');
		if dtf then do;
		rc = dclose(dtf);
		continue; * file opened as a sub-directory, iterate loop ;
		end;
		if upcase(scan(member,-1,'.')) = 'SAS7BCAT' then do;
		link do_cat; /* found a catalog in the directory, deal with it */
		end; else do;
		if upcase(scan(member,-1,'.')) = 'SAS' then do; /* .sas member ? */
		order + 1;
		type = '.sas';
		output;
		end;
		end;
		end;
		rc = dclose(d); /* close the directory we've opened */
		end;
		end;
		end;
	end;
	
	call symputx('no_of_cats',cat); /* save the number of catalogs found for macro loop below
	*/


	return;
	
	/*
	This code is specified here and LINKed to from two different places. NOT
	using sashelp.vcatalog because it just got toooooo complicated because I don’t
	have the libname. Gets complicated with compiled macros. We’re getting catalog
	details in the following step.
	*/
	
	do_cat:
	cat + 1;
	order + 1;
	call symput ('path'||put(cat,3.-l),trim(path));
	call symput ('cat'||put(cat,3.-l),substr(member,1,length(member)-9)); * take off .sas7bcat;
	call symputx('order'||put(cat,3.-l),order);
	return;
	run;
	
	/*
	Now unpack the contents of the macro/source catalogs, working our way
	through the macro variables created in the previous step. Routing
	source/macro contents of the catalog to an OUT dataset.
	*/
	
	%do i = 1 %to &no_of_cats;
	%put Processing catalog &&cat&i in &&path&i;
	libname _c "&&path&i";
	proc catalog catalog = _c.&&cat&i;
	contents out = _cat_contents ( keep = memname name type
	where = ( type in ( 'SOURCE', 'MACRO' ) ));
	quit;
	/* Any catalog entries found that we’re interested in? */
	data _null_;
	if 0 then set _cat_contents nobs = nobs ;
	call symputx('_cat_contents_nobs',nobs);
	stop;
	run;
	%if &_cat_contents_nobs > 0 %then %do;
	/* Flesh out the details */
	data _cat_contents;
	set _cat_contents ( rename = ( name = member memname = catalog ));
	length path $2000;
	path = "&&path&i";
	catalog = "&&cat&i";
	order = &&order&i;
	type = lowcase(type); * prefer lowercase ;
	run;
	/* Append to those we've found already */
	proc append base = _list_sasautos
	data = _cat_contents force;
	run;
	%end;
	libname _c clear;
	%end;
	/* It's possible that duplicate paths are in the SASAUTOS definition, weed out dups here */


	proc sort data = _list_sasautos;
		by path member order;
	run;
	
	/* Sorted by "order" so we'll keep the earliest one found in concatenation */
	proc sort data = _list_sasautos nodupkey ;
		by path member;
	run;
	
	/* Sort the list by member name and the order the macro was found */
	proc sort data = _list_sasautos;
		by member order;	
	run;
	
	proc print data=_list_sasautos noobs ;
		var order member path type catalog ;
		format _character_;
	run;


%exit:

%mend list_sasautos;


%list_sasautos(work=Y)
