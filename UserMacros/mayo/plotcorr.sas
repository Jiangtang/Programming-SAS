  /*------------------------------------------------------------------*
   | MACRO NAME  : plotcorr
   | SHORT DESC  : Produce scatterplot with correlation / regression
   |               results below the plot
   *------------------------------------------------------------------*
   | CREATED BY  : Bergstralh, Erik              (04/09/2004 16:38)
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | TO PRODUCE Y*X SCATTER PLOT WITH CORRELATION AND
   |  REGRESSION DATA APPENDED AT THE BOTTOM OF THE PAGE.
   |  THE MACRO CAN USE EITHER PLOT OR GPLOT.  FOR GPLOT
   |  THE GRAPH CAN OPTIONALLY INCLUDE THE REGRESSION LINE
   |  OF Y ON X ALONG WITH CONFIDENCE LIMITS FOR EITHER
   |  MEAN Y OR INDIVIDUAL PREDICTED Y'S.
   |
   |  DATE WRITTEN: 2/09/89
   |                9/18/89, MODIFIED FOOTNOTE STMTS
   |                9/03/93  Corrected documentation for YAXIS & XAXIS
   |                7/20/07  Allowed for var length>8
   |
   |  MACRO CALL:    %PLOTCORR(DATA=,YVAR=,XVAR=,YAXIS=,XAXIS=,
   |                           PTYPE=,LINE=,PLTDATA=);
   |
   |  PARAMETERS:   DATA=INPUT DATA SET CONTAINING Y & X VARS.
   |
   |                YVAR=VARIABLE TO PLOT ON VERTICAL AXIS.
   |
   |                XVAR=VARIABLE TO PLOT ON HORIZONTAL AXIS.
   |
   |                YAXIS=VAXIS, VREF AND VMINOR OPTIONS FROM PROC
   |                      PLOT OR GPLOT.  THESE MUST BE ENCLOSED IN
   |                      DOUBLE QUOTES IF USED.  FOR EXAMPLE,
   |                         YAXIS="VAXIS=10 TO 20 BY 1 VREF=15  VMINOR=1".
   |
   |                XAXIS=HAXIS, HREF AND HMINOR OPTIONS FROM PROC
   |                      PLOT OR GPLOT.
   |
   |
   |                *** THE FOLLOWING PARAMETERS APPLY ONLY FOR GPLOTS**
   |
   |                PTYPE=TYPE OF PLOT.  THIS MUST BE SET TO 'GPLOT'
   |                      IF ONE DESIRES A GRAPHICS PLOT, ELSE LEAVE
   |                      IT BLANK FOR A STANDARD LINE PRINTER PLOT.
   |
   |                LINE=ALLOWS ONE TO INCLUDE THE REGRESSION LINE ON
   |                     THE PLOT ALONG WITH CONFIDENCE LIMITS IF
   |                     DESIRED.  THIS IS ONLY APPLICABLE FOR GPLOT.
   |                     SEE PAGE 69 OF THE SAS/GRAPH USERS GUIDE(V5)
   |                     FOR DETAILS.  EXAMPLES ARE:
   |                             LINE=RL       LINEAR REGN LINE ONLY.
   |                             LINE=RLCLM95  LINEAR REGN WITH CONF.
   |                                           LIMITS(95%) FOR MEAN Y.
   |                             LINE=RLCLI95  LINEAR REGN WITH CONF.
   |                                           LIMITS(95%) FOR INDIVID.
   |                                           PREDICTED VALUES OF Y.
   |
   |                PLTDATA=OUTPUT GRAPHICS CATALOG FOR SAVING THE GPLOT
   |                       GRAPH.
   |
   |
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Bergstralh, Erik              (07/20/2007 12:00)
   |
   | Update to all variables of length >8
   *------------------------------------------------------------------*
   | MODIFIED BY : Bergstralh, Erik              (07/30/2007 14:41)
   |
   | Allow for variable lengths>8.
   |
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Bergstralh, Eric              (08/28/2008 15:53)
   |
   | Restore user footnotes. Declare maro vars as local.
   *------------------------------------------------------------------*
   | OPERATING SYSTEM COMPATIBILITY
   |
   | UNIX SAS v8   :   YES
   | UNIX SAS v9   :   YES
   | MVS SAS v8    :
   | MVS SAS v9    :
   | PC SAS v8     :
   | PC SAS v9     :
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | Located at the bottom of the code.
   |
   |
   |
   |
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
 
%MACRO PLOTCORR(DATA=,YVAR=,XVAR=,YAXIS=,XAXIS=,
   PTYPE=,LINE=,PLTDATA=WORK);
 
   *** assign new macro vars as local ***;
   %local  nuse mny mnx sdy sdx mdy mdx miy may mix max
       rho prho b a seb sea syx rsq rhos prhos;
 
   ***** Save current footnotes -- reset later *****;
  proc sql ;
    create table work._f as select * from dictionary.titles
     where type='F';
    reset noprint;
   quit;
  ***** How many footnotes are being used? *****;
  proc sql;
   reset noprint;
   select nobs into :F from dictionary.tables
   where libname="WORK" & memname="_F";
 quit;
  ***** Store footnotes in macro variables *****;
  %LET FOOTNOTE1= ; /* Initialize at least one footnote */
  data _null_;
    set _f;
    %IF (&F>=1) %THEN %DO I=1 %TO &F;
       if number=&I then call symput("FOOTNOTE&I", trim(left(text)));
       %END;
   run;
**********************************************;
 
  DATA __A; SET &DATA(KEEP= &YVAR &XVAR );
   __Y=&YVAR;
   __X=&XVAR;
   IF __Y=. OR __X=. THEN DO; __Y=.; __X=.; END; **IF ONE IS MISSING
                                                   SET BOTH TO BLANK;
  PROC UNIVARIATE NOPRINT; VAR __Y __X;
   OUTPUT OUT=__B N=N MEAN=MEAN_Y MEAN_X STD=SD_Y SD_X
   MEDIAN=MED_Y MED_X MIN=MIN_Y MIN_X MAX=MAX_Y MAX_X;
  DATA _NULL_; SET __B;
   _YA=SYMGET('YAXIS');
   _XA=SYMGET('XAXIS');
   _YA=COMPRESS(_YA,'"');
   _XA=COMPRESS(_XA,'"');
   CALL SYMPUT('YAXIS',_YA);
   CALL SYMPUT('XAXIS',_XA);
   CALL SYMPUT('NUSE',PUT(N,6.) );
   CALL SYMPUT('MNY',PUT(MEAN_Y,BEST8.) );
   CALL SYMPUT('MNX',PUT(MEAN_X,BEST8.) );
   CALL SYMPUT('SDY',PUT(SD_Y,BEST8.) );
   CALL SYMPUT('SDX',PUT(SD_X,BEST8.) );
   CALL SYMPUT('MDY',PUT(MED_Y,BEST8.) );
   CALL SYMPUT('MDX',PUT(MED_X,BEST8.) );
   CALL SYMPUT('MIY',PUT(MIN_Y,BEST8.) );
   CALL SYMPUT('MAY',LEFT(PUT(MAX_Y,BEST8.)) );
   CALL SYMPUT('MIX',PUT(MIN_X,BEST8.) );
   CALL SYMPUT('MAX',LEFT(PUT(MAX_X,BEST8.)) );
  PROC CORR NOPRINT OUTP=__P OUTS=__S DATA=__A; VAR __Y; WITH __X;
  DATA __C; SET __P(IN=INP) __S(IN=INS); IF _N_=1 THEN SET __B;
   IF _TYPE_='CORR';                 ** First obs. is Pearson corr(__Y);
                                     ** 2nd obs. is Spearman corr(__Y);
   T= __Y*SQRT( (N-2)/(1-__Y**2) );  ** T statistic for test of r=0;
   DF=N-2;                           ** Degrees of freedom for T;
   R=ROUND(__Y,.0001);               ** r=corr. coeff. rounded;
   P=( 1-PROBT(ABS(T),DF) )*2;       ** p-value for test of r=0;
   P=ROUND(P, .0001);
   IF INP THEN DO;                   ** Regression stats;
       S2Y=(N-1)*SD_Y**2;                 **  Corrected ss for y;
       S2X=(N-1)*SD_X**2;                 **  Corrreted ss for x;
       RSQ=__Y**2;                        **  R-square;
       B=__Y*SD_Y/SD_X;                   **  Slope;
       A=MEAN_Y-B*MEAN_X;                 **  Intercept;
       RMSE=SQRT(((1-RSQ)*S2Y)/(N-2));    **  Square root MSE or Sy.x;
       SEB=RMSE*SQRT(1/S2X);              **  Est. SE slope;
       SEA=RMSE*SQRT(1/N + MEAN_X**2/S2X);**  Est. SE intercept;
       CALL SYMPUT('RHO',PUT(R,6.4   ) );
       CALL SYMPUT('PRHO',PUT(P,5.4  ) );
       CALL SYMPUT('B',PUT(B,BEST8.) );
       CALL SYMPUT('A',PUT(A,BEST8.) );
       CALL SYMPUT('SEB',PUT(SEB,BEST8.) );
       CALL SYMPUT('SEA',PUT(SEA,BEST8.) );
       CALL SYMPUT('SYX',PUT(RMSE,BEST8.) );
       CALL SYMPUT('RSQ',PUT(RSQ,5.4) );
   END;
   IF INS THEN DO;
       CALL SYMPUT('RHOS',PUT(R,6.4 ) );
       CALL SYMPUT('PRHOS',PUT(P,5.4) );
   END;
 %IF %UPCASE(&PTYPE)=GPLOT %THEN %DO;
  SYMBOL1 C=RED  V=PLUS I=&LINE;
  PROC GPLOT DATA=__A GOUT=&PLTDATA;
    PLOT &YVAR*&XVAR / &YAXIS &XAXIS;
 %END;
 %ELSE %DO;
  PROC  PLOT DATA=__A;
    PLOT &YVAR*&XVAR / &YAXIS &XAXIS;
 %END;
 %macro ftn(fn); footnote&fn .j=l .h=.7  %mend  ftn;
 %ftn(1) "DESC. STATS(N=&NUSE):   Mean      Std      Median      Range";
 %ftn(2) "        &YVAR(Y)    &MNY &SDY &MDY &MIY => &MAY             ";
 %ftn(3) "        &XVAR(X)    &MNX &SDX &MDX &MIX => &MAX             ";
 %ftn(4) "CORRELATIONS:       Pearson=&RHO(P=&PRHO)  Spearman=&RHOS(P=&PRHOS)";
 %ftn(5) "REGRESSION(Y=A+BX):  S(Y.X)=&SYX          Rsquare=&RSQ";
 %ftn(6) "                     A(SE)=&A(&SEA)  B(SE)=&B(&SEB) ";
  RUN; quit;
  ***** Restore the previous footnotes *****;
  footnote1;
  %IF (&F>=1) %THEN %DO I=1 %TO &F;
   footnote&I "&&FOOTNOTE&I";
  %END;
 
  PROC datasets; DELETE __A __B __C __P __S;  quit;
 %MEND PLOTCORR;
 /*
goptions device=apple;
footnote1 "xxxx"; footnote2 "2222";
data one;
    do x23456789=1 to 50;
      y23456789=x23456789 + rannor(37375);
    output;
    end;
 proc print data=one;
 %plotcorr(data=one,yvar=y23456789,
                    xvar=x23456789,
     ptype=gplot,line=rlci95,pltdata=graf);run;
 proc print data=one;
run;
  */
 
 
 
 
 
 
 
