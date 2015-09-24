/*SASGlobalForum2011*/
/*Paper 259-2011 */
/*Choosing the Road Less Traveled: Performing Similar Tasks with either */
/*SAS®DATA Step Processing or with Base SAS®Procedures */
/*Kathryn McLawhorn, SAS Institute Inc., Cary, NC */



/*1. CALCULATING THE NUMBER OF OBSERVATIONS IN A BY GROUP*/

proc sort data=sashelp.class out=class; 
    by age; 
run; 

data count1; 
    set class; 
    by age;
    if first.age then Count=0; 
    count+1; 
    if last.age then output; 

    keep age count;
run; 

proc print data=count1 noobs; 
run;

/*dow*/
data count2;
    do count=1 by 1 until (last.age);
        set class;
        by age;
    end;
    keep age count;
run;

proc print data=count2 noobs; 
run;



/*2.COMPUTING A TOTAL FOR A BY GROUP*/
data tot; 
    set class; 
    by age; 
    if first.age then do; 
        weight_tot=0; 
    end; 
    weight_tot+weight; 
    if last.age then output; 

    keep age weight_tot;
run; 

proc print data=tot noobs; 
run; 

/*dow*/

data tot2 ; 
    do count = 1 by 1 until ( last.age ) ; 
        set class ; 
        by age ;
        weight_tot = sum (weight_tot, weight) ;
    end ;
    keep age weight_tot;
run ;

proc print data=tot2 noobs; 
run; 

/*3.COMPUTING AN AVERAGE FOR A BY GROUP */

data avg (keep=age count weight_tot weight_avg); 
    set class ; 
    by age ;
    retain weight_tot count; 
    if first.age then do; 
        weight_tot=0; 
        count=0; 
    end; 
    weight_tot + weight; 
    count + 1; 
    if last.age then do;
        weight_avg=weight_tot/count; 
        output; 
    end; 
run; 

proc print data=avg noobs;
run; 

/*dow*/

data avg2 ; 
    do count = 1 by 1 until ( last.age ) ; 
        set class ; 
        by age ;
       weight_tot = sum (weight_tot, weight) ;
    end ;
    weight_avg = weight_tot / count ; 
    keep count age weight_tot weight_avg;
run ;

proc print data=avg2 noobs;
run; 



/*4. COMPUTING A PERCENTAGE FOR A BY GROUP*/


data avg2 ; 
    do count = 1 by 1 until ( last.age ) ; 
        set class ; 
        by age ;
       weight_tot = sum (weight_tot, weight) ;
    end ;
    weight_avg = weight_tot / count ; 

    do seq = 1 by 1 until ( last.age ) ; 
        set class ; 
        by age ;
        percent=weight/weight_tot;
        output; 
    end ; 

    drop sex height;
run ;

proc print data=avg2 noobs;
run; 


