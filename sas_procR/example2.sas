
%include "C:\test\Proc_R.sas"; *****or replace c:\test with the your own path*******;
%Proc_R(SAS2R=,R2SAS=);
cards4;

setwd("c:/test")
x<- seq(1,25,0.5)
w<- 1 + x/2
y<- x+w*rnorm(x)
dum<- data.frame(x,y,w)
fm<- lm(y~x,data=dum)
summary(fm)
fm1<- lm(y~x,data=dum, weight=1/w^2)
summary(fm1)
lrf<- loess(y~x,dum)
plot(x,y)
lines(spline(x,fitted(lrf)),col=2)
abline(0,1,lty=3,col=3)
abline(fm,col=4)
abline(fm1,lty=4,col=5)

;;;;
%quit;
