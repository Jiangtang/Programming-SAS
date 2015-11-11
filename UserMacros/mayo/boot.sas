  /*------------------------------------------------------------------*
   | MACRO NAME  : boot
   | SHORT DESC  : Selects bootstrap samples
   *------------------------------------------------------------------*
   | CREATED BY  : Bergstralh, Erik              (03/23/2004 12:41)
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | Macro for selecting bootstrap samples
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Bergstralh, Eric              (08/28/2008 15:39)
   |
   | Added input parameter checks. Deleteted created datasets.
   *------------------------------------------------------------------*
   | OPERATING SYSTEM COMPATIBILITY
   |
   | UNIX SAS v8   :   YES
   | UNIX SAS v9   :
   | MVS SAS v8    :
   | MVS SAS v9    :
   | PC SAS v8     :
   | PC SAS v9     :
   *------------------------------------------------------------------*
   | MACRO CALL
   |
   | %boot    (
   |            data= ,
   |            X= ,
   |            N= ,
   |            samples= ,
   |            seed= ,
   |            outdata=
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : data
   | Default   :
   | Type      : Dataset Name
   | Purpose   : name of input dataset
   |
   | Name      : X
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : variable on which the bootstrap samples are to be drawn
   |
   | Name      : N
   | Default   :
   | Type      : Number (Single)
   | Purpose   : sample size for the bootstrap samples
   |
   | Name      : samples
   | Default   :
   | Type      : Number (Single)
   | Purpose   : number of bootstrap samples(with replacement) to be drawn
   |             from the variable x
   |
   | Name      : seed
   | Default   :
   | Type      : Number (Single)
   | Purpose   : initial seed for RANUNI function
   |
   | Name      : outdata
   | Default   :
   | Type      : Dataset Name
   | Purpose   : name of the output dataset containing the bootstrap
   |             samples.  There is one observation for each sample with
   |             the n members of the sample contained in the variables
   |             BS&x.1-BS&x.N .
   |
   *------------------------------------------------------------------*
   | RETURNED INFORMATION
   |
   | SAS dataset containing the bootstrap samples.  There is one observation
   | for each sample with the n members of the sample contained in the
   | variables BS&x.1-BS&x.N .
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | DATA NORM;
   |  DO K=1 TO 50;
   |   Z=NORMAL(7593661);
   |   E_Z=EXP(Z);
   |   OUTPUT;
   |  END;
   | PROC PRINT;
   | PROC UNIVARIATE FREQ NORMAL PLOT; VAR Z E_Z;
   |  OPTIONS MACROGEN MPRINT;
   | %BOOT(data=norm,x=z,n=50,samples=500,seed=57573,outdata=BSTRAP);
   |
   *------------------------------------------------------------------*
   | Copyright 2008 Mayo Clinic College of Medicine.
   |
   | This program is free software; you can redistribute it and/or
   | modify it under the terms of the GNU General Public License as
   | published by the Free Software Foundation; either version 2 of
   | the License, or (at your option) any later version.
   |
   | This program is distributed in the hope that it will be useful,
   | but WITHOUT ANY WARRANTY; without even the implied warranty of
   | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   | General Public License for more details.
   *------------------------------------------------------------------*/
 
%MACRO Boot(Data=,X=,N=,Samples=,Seed=,Outdata=);
 
   %let ERRORFLG=0;
   %if &X= %then %do;
       %put ERROR: The parameter X is missing;
       %let ERRORFLG=1;
   %end;
   %if &N= %then %do;
       %put ERROR: The parameter N is missing;
       %let ERRORFLG=1;
   %end;
   %if &samples= %then %do;
       %put ERROR: The parameter SAMPLES is missing;
       %let ERRORFLG=1;
   %end;
   %if &seed= %then %do;
       %put ERROR: The parameter SEED is missing;
       %let ERRORFLG=1;
   %end;
   %if &outdata= %then %do;
       %put ERROR: The parameter OUTDATA is missing;
       %let ERRORFLG=1;
   %end;
   %IF &ERRORFLG=1 %THEN %DO;
     %put ERROR: Macro BOOT not run;
     %go to exit;
   %end;
 
  DATA _BOOT; SET &DATA; KEEP &X;
  PROC TRANSPOSE data=_boot PREFIX=&X OUT=_TBOOT; VAR &X;
  DATA &OUTDATA; SET _TBOOT;
   KEEP SAMPLE_N BS&X.1-BS&X.&N;
   ARRAY X (*) &X.1-&X.&N;
   ARRAY BSX (*) BS&X.1-BS&X.&N;
   DO I=1 TO &SAMPLES;
     SAMPLE_N=I;
     DO J=1 TO &N;  * J IS INDICATOR FOR THE BOOTSTRAP ARRAY;
       K= INT(ranuni(&seed)*&N) +1; *K INDICATES WHICH ELEMENT IN THE X
                                 ARRAY WILL BE SELECTED;
       BSX(J)=X(K);
     END;
     OUTPUT;  *OUTPUT ONE OBSERVATION PER BOOTSTRAP SAMPLE;
   END;
   proc datasets; delete _boot _tboot;run;
   %exit:
  run;quit;
 %MEND BOOT;
 
  /* **example;
 data norm;
 DO K=1 TO 50;
      Z=NORMAL(7593661);
      E_Z=EXP(Z);
      OUTPUT;
 END;
 PROC PRINT;
 %BOOT(data=norm,x=z,n=50,samples=500,seed=57573,outdata=BSTRAP);
 proc print data=bstrap (obs=50);var sample_n bsz1-bsz50; run;
     */
 
 
