%macro US_holiday(year);
data holi;
    fdoy=mdy(1,1,&year);  
    if &year <= 2006 then do;
    fdo_apr=intnx('month',fdoy,3);
    dst_beg=intnx('week.1',fdo_apr,(weekday(fdo_apr) ne 1));
    fdo_oct=intnx('month',fdoy,9);
    dst_end=intnx('week.1',fdo_oct,(weekday(fdo_oct) in (6,7))+4);
  end;
                                         
  else do;  
    fdo_mar=intnx('month',fdoy,2);
    dst_beg=intnx('week.1',fdo_mar, (weekday(fdo_mar) in (2,3,4,5,6,7))+1);
    fdo_nov=intnx('month',fdoy,10);
    dst_end=intnx('week.1',fdo_nov,(weekday(fdo_nov) ne 1));
  end; 
run;                                                                                                  
                                                                                                      
data holid; 
    set holi;                                                                                         
                                                                                                      
    holiday="Martin Luther King Day"; 
    worddat=intnx('week.2',fdoy,(weekday(fdoy) ne 2)+2);
    output;                                                                                             

    holiday="President's Day ";                                                                       
    worddat=intnx('week.2',intnx('month',fdoy,1),(weekday(intnx('month',fdoy,1)) ne 2)+2); 
    output;

    holiday="Memorial Day";                                                                           
    worddat=intnx('week.2',intnx('month',fdoy,4),(weekday(intnx('month',fdoy,4)) in (1,7))+4);
    output;                                                                                            

    holiday="Independence Day";
    worddat=mdy(7,4,&year); 
    output;                                                                                            
    
    holiday="Labor Day";                                                                              
    worddat=intnx('week.2',intnx('month',fdoy,8),(weekday(intnx('month',fdoy,8)) ne 2));  
    output;                                                                                            

    holiday="Columbus Day";                                                                           
    worddat=intnx('week.2',intnx('month',fdoy,9),(weekday(intnx('month',fdoy,9)) ne 2)+1);  
    output;  

    holiday="Election Day";                                                                           
    worddat=intnx('week.3',intnx('month',fdoy,10),1); 
    output;   
                                                                                                      
    holiday="Veteran's Day";                                                                          
    worddat=mdy(11,11,&year);
    output;
                                                                                                      
    holiday="Thanksgiving Day";                                                                       
    worddat=intnx('week.5',intnx('month',fdoy,10),(weekday(intnx('month',fdoy,10)) ne 5)+3);  
    output;
                                                                                                      
    holiday="Christmas Day";                                                                          
    worddat=mdy(12,25,&year);
    output;                                                                  
  ;                                                                                                                                     
run;

data holiday&year;
    set holid;
    year="&year";
    format worddat ddmmyy10.;
	keep year holiday worddat;
run;

%mend US_holiday;