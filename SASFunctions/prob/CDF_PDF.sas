


/*
http://blogs.sas.com/content/iml/2011/10/19/four-essential-functions-for-statistical-programmers.html

PDF function: This function is the probability density function. 
	It returns the probability density at a given point for a variety of distributions. 
	(For discrete distribution, the PDF function evaluates the probability mass function.)

CDF function: This function is the cumulative distribution function. 
	The CDF returns the probability that an observation from the specified distribution 
	is less than or equal to a particular value. 
	For continuous distributions, this is the area under the PDF up to a certain point.

QUANTILE function: This function is closely related to the CDF function,
	but solves an inverse problem. Given a probability, P, it returns the smallest value, q, 
	for which CDF(q) is greater than or equal to P.



To calculate probablities for discrete distributions, use
	PDF('distribution', parameters);

To calcualte P(X <= x), use 
	CDF('distribution', parameters);

*/



data _null_;
	* Assume X ~ B(15,0.2), P(X = 3);
	*binomial PDF('BINOMIAL',k,p,n);
	binom = PDF('BINOMIAL',3,0.2,15);

	* X ~ Poisson, lambda= 2, P(X= 3);
	*Poisson PDF('POISSON',k,lambda);
	poisson = PDF('POISSON',3,2);

	*Assume that X ~Normal(4, 1.2), Calculate P(X <= 3);
	*Normal CDF('NORMAL',k,mu,standard deviation);
	normal = CDF('NORMAL',3,4,1.2);

	*Assume that X ~Uniform over [1,2], Calculate P(X < 1.4) ;
	*Uniform CDF('UNIFORM',k,a,b);
	uniform = CDF('UNIFORM',1.4,1,2);

	*X ~ Exponential, lambda=2, P(X = 3);
	*Exponential CDF('EXPONENTIAL',k,1/lambda);
	exponential = CDF('EXPONENTIAL',3,0.5);

	put _all_;
run;

/* PROBNORM computes normal probabilities
It computes the probability that a standard normal r.v. is less than (or equal to) 
a certain value.  So SAS gives us P(Z < value), whereas Table IV in the book gives 
us P(0 < Z < value)

Suppose our random variable Z is standard normal 



*/


data _null_;
	
	*the probability Z is between 0 and 1.24;
	normp1 = probnorm(1.24) - probnorm(0);
	
	*the probability Z is greater than 1.24;
	normp2 = 1 - probnorm(1.24);

	*the probability Z is less than 1.24;
	normp3 = probnorm(1.24);

	*the probability Z is between -0.54 and 0;
	normp4 = probnorm(0) - probnorm(-0.54);

	*the probability Z is less than -0.54;
	normp5 = probnorm(-0.54);

	* the probability Z is between -1.75 and -0.79;
	normp6 = probnorm(-0.79) - probnorm(-1.75);

	*the probability Z is between -0.79 and 1.16;
	normp7 = probnorm(1.16) - probnorm(-0.79);

/*
  What if X is normal with mean 266 and standard deviation 16 (like the pregnancy 
 example in class)?  If you're clever, you can let SAS standardize for you, 
 as the eighth example here will show: 
 8. What is the probability X is between 260 and 280? 
	*/

	normp8 = probnorm((280-266)/16) - probnorm((260-266)/16);

	put _all_;
run;



/*
With continuous random variables, and often with discrete random variables, we want to
compute probabilities like P(3 < X <= 10) or P(.02 < hatp < .075). For such problems, a
cumulative distribution function (CDF) is much more useful than a PDF


. Let’s return to the binomial case, this time with n = 25 and p = 0.45.
We’ll be interested in computing
P(10 < X <= 20). One way to do this is to add P(X = 11) +P(X = 12) +· · ·+P(X = 20).1
We can do this via the pdf function.
Note that X = 10 is not included, since the inequality has 10 < X.

Another way to write this problem is
P(10 < X <= 20) = P(X <= 20) - P(X <= 10).

The CDF at x returns P(X <= x),


To answer our problem we can either use
0.14189 + 0.15831 + · · · + 0.00126 or 0.99993 - 0.38426.

*/

data binom3;
do i = 0 to 25 by 1;
binompdf = pdf('binomial', i, 0.45, 25);
binomcdf = cdf('binomial', i, 0.45, 25);
output binom3;
end;
RUN;
proc print data = binom3;
run;



data;
   
   p1 = 1 - cdf('NORMAL', 2.75 , 0 , 1 ); /* The probability that a standard normal RV (or Z value) is greater than 2.75 */

   p2 = 1 - cdf('NORMAL', 310 , 266 , 16); /* The probability that a normal random variable with mean 
                          266 and standard deviation 16 is greater than 310 */

   z = quantile('NORMAL', .90 , 0 , 1 ); /* The 90th percentile of the standard normal distribution */

   x = quantile('NORMAL', .90 , 266 , 16); /* The 90th percentile of the normal distribution with mean 
                          266 and standard deviation 16 */

run;


/*
1.1 Calculating the binomial coefficients
To evaluate binomial coefficients, you need the factorial function:
FACT(5);
which computes 5!. So, you can compute the binomial coefficients 5!/(3!(5 - 3)!) with
FACT(5)/(FACT(3)*FACT(5-3));
Calculating binomial coefficients is a common task, and there is a SAS command specifically for
doing so:
COMB(5,3);
does the exact same thing as the longer way listed above.







*/

/*p(X>=23)*/
data;
 p1 =1- cdf('BINOMIAL', 23, 0.75 , 25 ) + PDF('BINOMIAL', 23, 0.75 , 25 );
put p1=;
run;


data;
 p1 =1- cdf('BINOMIAL', 22, 0.75 , 25 ) ;
put p1=;
run;
