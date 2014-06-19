filename fmt "c:\formats.sas7bcat";

data fmt; 
   infile fmt lrecl=1000 truncover; 
   input line $1000.; 
run;

data _null_;
	set fmt;
   	  if _n_=1 then do;
			retain queVer;

			*ver="/(\d+)\.[\d\w]+/";
			ver="/(\d+)\.[\d\w]+\_[\d\w]+/";
			queVer  = prxparse(ver);

			if missing(queVer) then do;
			   putlog "ERROR: Invalid regexp" ver;
			   stop;
			end;
	  end;

	  queVerN  = prxmatch(queVer ,line);

	  if queVerN > 0  then do ;
	  		call PRXsubstr(queVer,line,position,length);
				version = compress(substr(line, position, length));
				output;
			
				put position= length=;
				put version=;
	  end;	


run;

