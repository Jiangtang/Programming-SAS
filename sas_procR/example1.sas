data test;
  do x=1 to 4;
     array a[4] a1-a4;
	 do i=1 to 4;
        a[i]=rannor(100);
	 end;
	 output;
 end;
	 drop i x;
run;

%include "c:\test\Proc_R.sas"; *****or replace c:\test with the your own path*******;

%Proc_R(SAS2R=test,R2SAS=);
cards4;
setwd("c:/test")
testm<- as.matrix(test)
eigen(testm)

;;;;
%quit;
