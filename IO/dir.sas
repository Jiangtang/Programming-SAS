/*http://www.wuss.org/proceedings12/55.pdf*/

data yfiles; 
 
 keep filename; 
 
 length fref $8 filename $80; 
 rc = filename(fref, 'c:\'); 
 if rc = 0 then 
 do; 
 did = dopen(fref); 
 rc = filename(fref); 
 end; 
 else 
 do; 
 length msg $200.; 
 msg = sysmsg(); 
 put msg=; 
 did = .; 
 end; 
 
 if did <= 0 
 then 
 putlog 'ERR' 'OR: Unable to open directory.'; 
 
 dnum = dnum(did); 
 
 do i = 1 to dnum; 
 filename = dread(did, i); 
 /* If this entry is a file, then output. */ 
 fid = mopen(did, filename); 
 if fid > 0 
 then 
 output; 
 end; 
 
 rc = dclose(did); 
 
 run; 
 
 proc print data=yfiles; 
 run; 


/*-r*/
 data dirs_found (compress=no); 
 length Root $120.; 
 root = "C:\Users\jhu.D-WISE\Documents\GitHub"; 
 output; 
run; 
 
data 
 dirs_found /* Updated list of directories searched */ 
 files_found (compress=no); /* Names of files found. */ 
 
 keep Path FileName FileType; 
 
 length fref $8 Filename $120 FileType $16; 
 
 /* Read the name of a directory to search. */ 
 modify dirs_found; 
 
 /* Make a copy of the name, because we might reset root. */ 
 Path = root; 
 
 /* For the use and meaning of the FILENAME, DOPEN, DREAD, MOPEN, and */ 
 /* DCLOSE functions, see the SAS OnlineDocs. */ 
 
 rc = filename(fref, path); 
 
 if rc = 0 then 
 do; 
 did = dopen(fref); 
 rc = filename(fref); 
 end; 
 else 
 do; 
 length msg $200.; 
 msg = sysmsg(); 
 putlog msg=; 
 did = .; 
 end; 
 if did <= 0 
 then 
 do; 
 putlog 'ERR' 'OR: Unable to open ' Path=; 
 return; 
 end; 
 
 dnum = dnum(did); 
 
 do i = 1 to dnum; 
 filename = dread(did, i); 
 fid = mopen(did, filename); 
 /* It's not explicitly documented, but the SAS online */ 
 /* examples show that a return value of 0 from mopen */ 
 /* means a directory name, and anything else means */ 
 /* a file name. */ 
 if fid > 0 
 then 
 do; 
 /* FileType is everything after the last dot. If */ 
 /* no dot, then no extension. */ 
 FileType = prxchange('s/.*\.{1,1}(.*)/$1/', 1, filename); 
 if filename = filetype then filetype = ' '; 
 output files_found; 
 end; 
 else 
 do; 
 /* A directory name was found; calculate the complete */ 
 /* path, and add it to the dirs_found data set, */ 
 /* where it will be read in the next iteration of this */ 
 /* data step. */ 
 root = catt(path, "\", filename); 
 output dirs_found; 
 end; 
 end; 
 
 rc = dclose(did); 
 
run; 
 
proc print data=dirs_found; 
run; 
 
proc print data=files_found; 
run; 
