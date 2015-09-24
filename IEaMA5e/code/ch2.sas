libname ot "C:\Users\jhu\Documents\GitHub\Programming-SAS\IEaMA5e\data";

%let lib=ot;




/*
example 2.3: ceo salary and return on equity
*/

proc corr data=&lib..ceosal1;
 var salary roe;
run;


proc sgplot data = &lib..ceosal1;
   reg y=salary x=roe;
run;


proc reg data=&lib..ceosal1;
	model salary = roe;
quit;






proc reg DATA=&lib..ceosal1;
     MODEL salary=roe / stb clb;
     OUTPUT OUT=OUTREG1 P=PREDICT R=RESID RSTUDENT=RSTUDENT COOKD=COOKD;
run;quit;
title "Checking Residuals for Normality";
proc univariate data=outreg1 PLOT NORMAL;
     var RSTUDENT;
	 histogram / normal;
	 qqplot / normal(mu=est sigma=est);
run;






/*Example 2.4: Wage and Education*/

proc reg data=&lib..WAGE1;
	model wage = educ;
quit;


/*Example 2.5: Voting Outcomes and Campaign Expenditures*/

proc reg data=&lib..VOTE1;
	model votea = shareA;
quit;


/*Example 2.6: CEO Salary and Return on Equity*/
 

proc reg data=&lib..ceosal1;
	model salary = roe;
	output out=ceo 
		p=salaryhat
		r=uhat
		;
quit;

proc print data=ceo(firstobs=1 obs=15);
	var roe salary salaryhat uhat;
run;



/*Example 2.7: Wage and Education*/


proc reg data=&lib..WAGE1;
	model wage = educ;
quit;


/*Example 2.8: CEO Salary and Return on Equity*/


proc reg data=&lib..ceosal1;
	model salary = roe;
quit;


/*Example 2.9: Voting Outcomes and Campaign Expenditures*/

proc reg data=&lib..VOTE1;
	model votea = shareA;
quit;


/*Example 2.10: A Log Wage Equation*/


proc reg data=&lib..WAGE1;
	model lwage = educ;
quit;




/*iml???*/

proc iml; 
    use &lib..ceosal1; 
    read all var {"salary" "roe"} into ceosal1;
    close &lib..ceosal1; 

	y=ceosal1[,1];  /*salary*/
	x=ceosal1[,2];  /*roe*/

	b=inv(t(x)*x)*t(x)*y;
	yhat=x*b;
	r=y-yhat;
	sse=ssq(r);
	dfe=nrow(x)-ncol(x);
	mse=sse/dfe;
 
	start regress;                  /* 定义模块开始 */
		xpxi=inv(t(x)*x);         /* 矩阵X'X的逆 */
		beta=xpxi*(t(x)*y);       /* 参数估计 */
		yhat=x*beta;              /* 预测值 */
		resid=y-yhat;              /* 残差 */
		sse=ssq(resid);              /* SSE  */
		n=nrow(x);                 /* 观测值数  */
		dfe=nrow(x)-ncol(x);         /* 误差自由度DF */
		mse=sse/dfe;                  /* MSE  */
		cssy=ssq(y-sum(y)/n);         /* 校正平方和  */
		rsquare=(cssy-sse)/cssy;      /* RSQUARE  */
		print,"Regression Results",  sse dfe mse rsquare;
		stdb=sqrt(vecdiag(xpxi)*mse); /* 参数估计的标准差 */
		t=beta/stdb;                  /* 参数的t检验 */
		prob=1-probf(t#t,1,dfe);      /* p-值 */
		print,"Parameter Estimates",,  beta stdb t prob;
		print,y yhat resid;
	finish regress;                  /* 模块结束 */

	reset noprint;   
	 
	run regress;                     /* 执行REGRESS 模块 */
	reset print;             /* 打开自动打印 */

quit;


/*?*/
proc iml; 
    use &lib..ceosal1; 
    read all var {"salary" "roe"} into ceosal1;
    close &lib..ceosal1; 

	y=ceosal1[,1];  /*salary*/
	x=ceosal1[,2];  /*roe*/
b = inv(x`*x) * x`*y;
print b;

quit;
