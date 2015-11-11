  /*------------------------------------------------------------------*
   | MACRO NAME  : mccc
   | SHORT DESC  : Computes Lin's concordance correlation coefficient
   |               (CCC) for any number of raters
   *------------------------------------------------------------------*
   | CREATED BY  : Dierkhising, Ross             (07/18/2006  9:35)
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | This macro computes Lin's concordance correlation coefficient (CCC) in
   | the case of multiple raters, but can also handle only two raters.  The
   | CCC can be intereted as the agreement between continuous measurements
   | about a 45 degree line.  It computes an unbiased estimate of the
   | concordance correlation, while Lin's estimate in his original paper has
   | been shown to be biased.  The CCC is also the intraclass correlation
   | coefficient (ICC) in the case of a mixed model: random subjects and
   | fixed raters with no interaction.  The CCC in this macro takes into
   | account the rater to rater variability, so it truly measures agreement.
   | The classic Shrout and Fleiss ICC in this scenario does not take into
   | account rater variability, so is actually a measure of rater
   | consistency, not agreement.  One can obtain an adjusted ccc by including
   | relevant subject covariates, which will be treated as fixed effects in
   | the model.
   |
   *------------------------------------------------------------------*
   | OPERATING SYSTEM COMPATIBILITY
   |
   | UNIX SAS v8   :   YES
   | UNIX SAS v9   :   YES
   | MVS SAS v8    :   YES
   | MVS SAS v9    :   YES
   | PC SAS v8     :   YES
   | PC SAS v9     :   YES
   *------------------------------------------------------------------*
   | MACRO CALL
   |
   | %mccc    (
   |            data= ,
   |            id= ,
   |            ratervars= ,
   |            contcov= ,
   |            classcov= ,
   |            alpha= ,
   |            label=
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : data
   | Default   :
   | Type      : Dataset Name
   | Purpose   : dataset name
   |
   | Name      : id
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : id variable indicating unique observations
   |
   | Name      : ratervars
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : list of variables containing rater values (one variable per rater)
   |
   | Name      : alpha
   | Default   :
   | Type      : Number (Single)
   | Purpose   : type I error level for confidence intervals
   |
   *------------------------------------------------------------------*
   | OPTIONAL PARAMETERS
   |
   | Name      : contcov
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : continuous covariates to include in the mixed model to get an adjusted
   |             ccc
   |
   | Name      : classcov
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : Classification variables to include in the mixed model to get an
   |             adjusted ccc
   |
   | Name      : label
   | Default   :
   | Type      : Text
   | Purpose   : Label for output dataset.  Can be used in cases of multiple macro calls
   |             where you want to set multiple output datasets together, so each
   |             dataset has a label.
   |
   *------------------------------------------------------------------*
   | RETURNED INFORMATION
   |
   | The macro outputs mixed model results, variance component estimates,
   | the ccc estimate with its standard error, and two confidence intervals,
   | one based on asymptotic normality of the ccc estimate, the other based
   | on asymptotic normality of Fisher's Z transformation of the ccc
   | estimate.  The output is stored in the dataset _ccc in the work
   | directory.
   *------------------------------------------------------------------*
   | ADDITIONAL NOTES
   |
   | The macro assumes each observation is unique in the input dataset, with
   | one column per rater.  It also assumes each rater rates each
   | subject exactly once.
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | %mccc(data=set1,ratervars=rater1 rater2 rater3,alpha=.05,label=first agreement estimate);
   |
   *------------------------------------------------------------------*
   | REFERENCES
   |
   | Carrasco JL, Jover L. Estimating the generalized concordance correlation
   | coefficient through variance components. Biometrics 59:849-858, 2003.
   |
   | Shrout PE, Fleiss JL. Intraclass correlations: uses in assessing rater
   | reliability. Psychological Bulletin 86:420-428, 1979.
   |
   | Lin L. A concordance correlation coefficient to evaluate reproducibility.
   | Biometrics 45:255-268, 1989.
   *------------------------------------------------------------------*
   | Copyright 2006 Mayo Clinic College of Medicine.
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
 
%macro mccc(data,id,ratervars,contcov,classcov,alpha,label);
 
* transposing dataset to have multiple observations per id;
* proc mixed needs it in this form;
 
proc sort data=&data;
 by &id;
run;
 
proc transpose data=&data out=_tdata prefix=resp;
 var &ratervars;
 by &id;
run;
 
* adding covariates to the transposed dataset;
 
data _cov;
 set &data;
 keep &id &contcov &classcov;
run;
 
data _tdata;
 merge _tdata _cov;
 by &id;
run;
 
* creating rater variable and renaming the response variable;
 
data _tdata;
 set _tdata;
 by &id;
 retain rater(0);
 if first.&id=1 then rater=1;
    else rater=rater+1;
 rename resp1=resp;
run;
 
* fitting the mixed model - random subjects, fixed raters, any covariates;
 
ods listing exclude classlevels;
ods output covparms=_varcomp asycov=_varcompcov dimensions=_dim;
proc mixed data=_tdata method=reml asycov;
 class &id rater &classcov;
 model resp = rater &contcov &classcov;
 random int / subject=&id type=vc;
run;
 
* assigning variance components for subjects and error to macro vars;
 
data _null_;
 set _varcomp;
 if covparm='Intercept' then call symput('sig2sub',trim(left(estimate)));
 if covparm='Residual' then call symput('sig2err',trim(left(estimate)));
run;
 
* assigning covariance estimates of variance components to macro vars;
 
data _null_;
 set _varcompcov;
 if covparm='Intercept' then call symput('varsig2sub',trim(left(covp1)));
 if covparm='Intercept' then call symput('covsuberr',trim(left(covp2)));
 if covparm='Residual' then call symput('varsig2err',trim(left(covp2)));
run;
 
data _null_;
 set _dim;
 
 * n is number of subjects;
 if descr='Subjects' then call symput('n',trim(left(value)));
 
 * k is number of raters;
 if descr='Max Obs Per Subject' then call symput('k',trim(left(value)));
run;
 
* computing estimate of variability due to raters - a sum of squares;
 
proc means data=_tdata mean nway noprint;
 class rater;
 var resp;
 output out=_ratmeans mean=mean;
run;
 
proc transpose data=_ratmeans out=_ratmeans prefix=mean;
 var mean;
run;
 
* computing sum of squared differences of observed rater means;
 
data _ratsumsqrs;
 set _ratmeans;
 sumdiff2=0;  * initializing sum;
 array ratmean {&k} mean1-mean&k;
 do i=1 to (&k-1);
  do j=(i+1) to &k;
   sumdiff2=sumdiff2+(ratmean{i}-ratmean{j})**2;
  end;
 end;
run;
 
 
* estimate of sum of squares of rater means - sigma-squared raters;
* estimate of the variance of sigma-squared raters;
 
data _ratsumsqrs;
 set _ratsumsqrs;
 
 * sigma-squared raters assumes each rater rates each subject once;
 sig2rat=((1/(&k*(&k-1)))*sumdiff2) - (&sig2err/&n);
 
 * variance of sigma-squared raters assumes each rater rates each subject
   once;
 varsig2rat=( (8*&sig2err)/(&n*(&k**2)*((&k-1)**2))*sumdiff2 )
            + (&varsig2err/(&n**2));
run;
 
data _null_;
 set _ratsumsqrs;
 call symput('sig2rat',trim(left(sig2rat)));
 call symput('varsig2rat',trim(left(varsig2rat)));
run;
 
* covariance of subject sum of squares and rater variance;
* assumes each rater rates each subject once;
%let covsubrat=%sysevalf((1/(&k*&n))*&varsig2err);
 
* covariance of subject sum of squares and error variance;
* assumes each rater rates each subject once;
%let covraterr=%sysevalf((-1/&n)*&varsig2err);
 
* estimate of ccc;
%let ccc=%sysevalf(&sig2sub/(&sig2sub+&sig2rat+&sig2err));
 
* estimated variance of ccc;
 
%let varccc=%sysevalf( ( ((1-&ccc)**2*&varsig2sub)
                        +(&ccc**2*(&varsig2rat+&varsig2err+2*&covraterr))
                        -(2*(1-&ccc)*&ccc*(&covsubrat+&covsuberr)) )
                       / (&sig2sub+&sig2rat+&sig2err)**2
                     );
 
* lower and upper endpoints of CI based on ccc;
 
%let lowerccc=%sysevalf(&ccc-%sysfunc(probit(1-&alpha/2))*%sysfunc(sqrt(&varccc)));
%let upperccc=%sysevalf(&ccc+%sysfunc(probit(1-&alpha/2))*%sysfunc(sqrt(&varccc)));
 
 
* Fishers z-transformation of ccc;
 
%let zccc=%sysevalf(.5*%sysfunc(log((1+&ccc)/(1-&ccc))));
 
* estimated variance of Fishers z-transformation of ccc;
 
%let varzccc=%sysevalf(&varccc/((1+&ccc)**2*(1-&ccc)**2));
 
* lower and upper endpoints for Fishers z-transformation of ccc;
 
%let lowerzccc=%sysevalf(&zccc-%sysfunc(probit(1-&alpha/2))*%sysfunc(sqrt(&varzccc)));
%let upperzccc=%sysevalf(&zccc+%sysfunc(probit(1-&alpha/2))*%sysfunc(sqrt(&varzccc)));
 
* lower and upper endpoints for ccc based on Fishers z-transformation;
 
%let lowercccz=%sysevalf((%sysfunc(exp(2*&lowerzccc))-1) / (1+%sysfunc(exp(2*&lowerzccc))));
%let uppercccz=%sysevalf((%sysfunc(exp(2*&upperzccc))-1) / (1+%sysfunc(exp(2*&upperzccc))));
 
* confidence level of intervals for output;
 
%let cilevel=%sysevalf(100*(1-&alpha));
 
* asymptotic standard error of CCC for output;
 
%let cccstderr=%sysevalf(%sysfunc(sqrt(&varccc)));
 
 
* rounding values for printing;
* also creating macro variables containing format information for the
  variances since we do not know how many digits will be before the
  decimal point;
 
data _rnd;
 
 * assuming variances take up no more than 250 spaces;
 length chsig2sub chsig2rat chsig2err $250;
 
 n=&n; * assigning macro vars to numeric vars;
 k=&k;
 sig2sub=&sig2sub;
 sig2rat=&sig2rat;
 sig2err=&sig2err;
 ccc=&ccc;
 cccstderr=&cccstderr;
 lowerccc=&lowerccc;
 upperccc=&upperccc;
 lowercccz=&lowercccz;
 uppercccz=&uppercccz;
 
 sig2sub=round(sig2sub,.001);  * rounding numeric values;
 sig2rat=round(sig2rat,.001);
 sig2err=round(sig2err,.001);
 ccc=round(ccc,.001);
 cccstderr=round(cccstderr,.001);
 lowerccc=round(lowerccc,.001);
 upperccc=round(upperccc,.001);
 lowercccz=round(lowercccz,.001);
 uppercccz=round(uppercccz,.001);
 
 * defining formats for variance components on the fly;
 
 chsig2sub=left(sig2sub);  * character vars left justified;
 chsig2rat=left(sig2rat);
 chsig2err=left(sig2err);
 
 dsig2sub=index(chsig2sub,'.');  * which spot decimal point is in;
 dsig2rat=index(chsig2rat,'.');
 dsig2err=index(chsig2err,'.');
 
 lsig2sub=dsig2sub-1;  * number of digits to the left of decimal point;
 lsig2rat=dsig2rat-1;
 lsig2err=dsig2err-1;
 
 tsig2sub=lsig2sub+4; * total number of spaces to print variances;
 tsig2rat=lsig2rat+4;
 tsig2err=lsig2err+4;
 
 fsig2sub=tsig2sub || '.3';  * concatenating text for final formats;
 fsig2rat=tsig2rat || '.3';
 fsig2err=tsig2err || '.3';
 
 call symput('fsig2sub',trim(left(fsig2sub)));  * final formats;
 call symput('fsig2rat',trim(left(fsig2rat)));
 call symput('fsig2err',trim(left(fsig2err)));
 
run;
 
 
* printing out results;
 
data _null_;
 set _rnd;
 file print;
 put ///
     @5 'Concordance Correlation Coefficient (CCC)' ///
     @5 'Number of subjects:' @55 n /
     @5 'Number of raters:' @55 k //
     @5 'Estimated subject variance:' @55 sig2sub &fsig2sub /
     @5 'Estimated rater variability (sum of squares):' @55 sig2rat &fsig2rat /
     @5 'Estimated error variance:' @55 sig2err &fsig2err //
     @5 'CCC:' @55 ccc 5.3 /
     @5 'Asymptotic standard error:' @55 cccstderr 5.3 //
     @5 "&cilevel" '% Confidence Intervals' /
     @5 'Asymptotic interval:' @55 '(' lowerccc 5.3 ', ' upperccc 5.3 ')' /
     @5 "Asymptotic Fisher's Z interval:" @55 '(' lowercccz 5.3 ', ' uppercccz 5.3 ')';
run;
 
 
* output dataset;
 
data _label;  * dataset containing label for the final output dataset;
 label="&label";
run;
 
data _ccc;  * making label appear first when printing;
 merge _label _rnd;
run;
 
data _ccc;
 set _ccc;
 keep label n k sig2sub sig2rat sig2err ccc cccstderr lowerccc upperccc
      lowercccz uppercccz;
 label label='dataset label'
       n='number of subjects'
       k='number of raters'
       sig2sub='subject variance'
       sig2rat='rater variability'
       sig2err='error variance'
       ccc='Concordance Correlation Coefficient (CCC)'
       cccstderr='standard error of CCC'
       lowerccc='lower endpoint of asymptotic CI'
       upperccc='upper endpoint of asymptotic CI'
       lowercccz="lower endpoint of asymptotic Fisher's Z CI"
       uppercccz="upper endpoint of asymptotic Fisher's Z CI";
run;
 
 
* deleting datasets created by the macro - only keeping output dataset;
 
proc datasets;
 delete _tdata _cov _varcomp _varcompcov _dim _ratmeans _ratsumsqrs _rnd
        _label;
quit;
 
 
%mend mccc;
 
 
