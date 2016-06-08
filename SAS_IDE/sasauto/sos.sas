/*Sum of Squares*/

*Jiangtang Hu                   *;
*Jiangtanghu@gmail.com          *;
*Jiangtanghu.com/blog           *;

%macro sos(ds,group,var);

title "Sum of Squares";
ods select OverallANOVA;
proc glm data=&ds;
    class &group;
    model &var =&group  ;    
run;
quit;

title color=red "SST = SSE + SSM";
title2 color=red "Source: Corrected Total (Total Sum of Squares: SST)";
proc means data=&ds  mean css;
    var &var;
run;

ods select none ; 
ods output Summary=__Summary2;
proc means data=&ds mean css;
    class &group;
    var &var;
run;

ods select all;

title color=red "Source: Error (Within Group Variation; Error Sum of Squares: SSE)";
title3 HEIGHT=2 "The MEANS Procedure";
proc print data=__Summary2;
    var &group Nobs &var._Mean &var._CSS;
    sum &var._CSS;
run;

title color=red "Source: Model (Between Group Variation; Model Sum of Squares: SSM)";
proc means data=__summary2 mean css;
    var &var._mean;
    weight nobs;
run;
title;

proc delete data=__summary2;
run;
%mend;


%*sos(sashelp.class,sex,height);

/*

data age(drop=i);
    input grp $ @;
    do i = 1 to 4;
        input age @;
        output;
    end;
datalines;
1 22  22  22  22
2 22  22  22  22
3 22  22  22  22
;

data pulse_rates(drop=i);
    input grp $ @;
    do i = 1 to 4;
        input pulse @;
        output;
    end;
datalines;
1 64 64 64 64
2 59 59 59 59
3 70 70 70 70
;

data bp(drop=i);
    input grp $ @;
    do i = 1 to 4;
        input bp @;
        output;
    end;
datalines;
1 74 76 75 75
2 81 80 79 80
3 89 89 88 90
;

data triglyceride(drop=i);
    input grp $ @;
    do i = 1 to 4;
        input triglyceride @;
        output;
    end;
datalines;
1 85  101 68 121
2 72  130 91 99
3 141 78  91 121
;

%sos(age,grp,age);
%sos(pulse_rates,grp,pulse);
%sos(bp,grp,bp);
%sos(triglyceride,grp,triglyceride);

*/
