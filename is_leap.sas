/*
http://en.wikipedia.org/wiki/Leap_year
http://support.microsoft.com/kb/214019

*/

data a;
	do year=1900 to 2013;
		output;
	end;
	;
run;

data b;
	set a;
	*year = 1900;
	is_leap = (mod(year,4) = 0) and 
	          (
				(mod(year,100) ^= 0) or (mod(year,400) = 0) 
			  );
/*	put is_leap=;*/

	if mod(year,4) = 0 then do;   
	    if mod(year,100) = 0 then do;           
	        if mod(year,400) = 0 then leap=1;
	        else leap=0;
		end;
	    else leap=1;
	end;
	else leap=0;
/*	put leap=;*/
	
	if bor(band(mod(year,4) = 0,mod(year,100) ^= 0),mod(year,400) = 0) then lea=1;
	else lea=0;
run;

data c;
	set b;
	if is_leap ^= leap or leap ^= lea;
run;
