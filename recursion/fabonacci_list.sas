%macro f(_1,_2,L);%if &L>0 %then &_1 , %f(&_2,%eval(&_1+&_2),%eval(&L-1));
%mend;
%put %f(0,1,4);

%macro f0(_1,_2); &_1 %f0(&_2,%eval(&_1+&_2))
%mend;
%put %f0(0,1);