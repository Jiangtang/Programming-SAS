/*http://support.sas.com/kb/48/582.html*/

/*Create data set of valid magazine names.*/
data mags;
input title $char30.;
datalines;
Science 
Discover
Nature Today
Journal of Medicine
Outside
;
run;

/*Create data set of articles with magazine name.  Some of the magazine names are not quite correct.*/
data articles;
infile datalines dlm=',';
input magtitle :$30. article :$30.;
datalines;
Science, Bears
Sciene, Cats
Sciences, Dogs
Discovery, Stars
Discover, Planets
Outdoors, Hiking
;

/*Generate two output data sets: MATCH if the magazine names are an exact match and */
/*CLOSE if the distance between the magazine names is within the value we have set.*/

/*First, we read in all the correct magazine titles from the MAGS data set into an array.*/
/*Then we read through each observation in the data set ARTICLES.  If the magazine names*/
/*are an exact match, we output to MATCH and stop checking for a magazine.  If COMPLEV returns*/
/*a distance of less than or equal to 5 (chosen arbitrarily to get matches we consider*/
/*"close enough"), then the observation is written to the CLOSE data set.*/

data match (keep = magtitle article) 
close (keep=distance magtitle possible_mag article);
array mags[5] $20 _temporary_;
do until (done);
	set mags end=done;
	count+1;
	mags[count] = title;
end;

do until (checkdone);
	set articles end=checkdone;
	do i = 1 to dim(mags);
		distance = complev(magtitle, mags[i],'iln');
		if distance=0 then do;
			output match;
/*			leave;*/
		end;

		else if distance <= 5 then do;
			possible_mag = mags[i];
			output close;
		end;
	end;
end;
/*stop;*/
run;
