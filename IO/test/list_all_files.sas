/*http://support.sas.com/techsup/notes/v8/25/074.html*/

%macro drive(dir,ext);                                                                                                                  
                                                                                                                                        
  %let filrf=mydir;                                                                                                                      
                                                                                                                                        
  /* Assigns the fileref of mydir to the directory and opens the directory */                                                                    
  %let rc=%sysfunc(filename(filrf,&dir));                                                                                                
  %let did=%sysfunc(dopen(&filrf));                                                                                                      
                                                                                                                                        
  /* Returns the number of members in the directory */                                                                   
  %let memcnt=%sysfunc(dnum(&did));                                                                                                      
                                                                                                                                        
   /* Loops through entire directory */                                                                                                  
   %do i = 1 %to &memcnt;                                                                                                                
    
     /* Returns the extension from each file */                                                                                                                                    
     %let name=%qscan(%qsysfunc(dread(&did,&i)),-1,.);                                                                                   
                                                                                                                                        
     /* Checks to see if file contains an extension */                                                                                     
     %if %qupcase(%qsysfunc(dread(&did,&i))) ne %qupcase(&name) %then %do;                                                                  
                                                                                                                                        
     /* Checks to see if the extension matches the parameter value */                                                                      
     /* If condition is true prints the full name to the log       */                                                                      
      %if (%superq(ext) ne and %qupcase(&name) = %qupcase(&ext)) or                                                                       
         (%superq(ext) = and %superq(name) ne) %then %do;                                                                                     
         %put %qsysfunc(dread(&did,&i));                  
      %end;                                                                               
     %end;                                                                                                                               
   %end;                                                                                                                                 
                                                                                                                                        
  /* Closes the directory */                                                                                                            
  %let rc=%sysfunc(dclose(&did));                                                                                                        
                                                                                                                                        
%mend drive;                                                                                                                            
                                                                                                                                        
/* First parameter is the directory of where your files are stored. */                                                                
/* Second parameter is the extension you are looking for.           */                                                                
/* Leave 2nd paramater blank if you want a list of all the files.   */                                                                
%drive(dir=%str(C:\Users\jhu));
