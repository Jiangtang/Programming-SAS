%macro silly(parm = );
 %put ==> &parm;
%mend silly;


data list;
 do i = 0 to 999;
   parm = "var"||put(i, z3.);
   output;
 end;
run;

data _null_;
 set list;
 call execute('%silly(parm = '||parm||')');
run;


/**/
/**/


/*1 basic*/
/*1-1*/
data example;
  test="It works!";
  call execute('proc print;run;');
run;

/*1-2*/

%macro testing;
  proc print;run;
%mend;

data example;
  test='It works!';
  call execute('%testing');
run;

/*2. generate code based on data set values*/

/*2-1 create proc format from dataset*/
libname orion "C:\Users\jhu\Box Sync\SAS\webLiveCourse\Course Data\Workshop_all\OrionStar\orcore";

data _null;
  set orion.country end=done;
  value = put(country,$quote4.);
  label = put(country_name,$quote30.);

  if _n_ = 1 then call execute('proc format; value $country');
  call execute(value|| '=' || label);
  if done then call execute('; run;');
run;


/*

1    + proc format;
1    +              value $country
2    + "AU"="Australia"
3    + "CA"="Canada"
4    + "DE"="Germany"
5    + "IL"="Israel"
6    + "TR"="Turkey"
7    + "US"="United States"
8    + "ZA"="South Africa"
9    + ;


*/

/*3. repetitive operations*/

/*3-1*/
proc sort data=orion.order_fact out=order_fact;
  by customer_id;
run;

data _null;
  set order_fact;
  by customer_id;
  where customer_id in (23, 45, 61);

  if last.customer_id then do;
    call execute('proc print data=order_fact;');
    call execute(cats('where customer_id=',customer_id,';'));
    call execute(cats('title "Orders from coustomer:',customer_id,'";'));
    call execute('run;');

  end;
run;

/*3-2*/

%let list=23, 45, 61;

proc sort data=orion.order_fact out=order_fact (keep = customer_id product_id quantity total_retail_price);
  by customer_id;
  where customer_id in (&list);
run;

data _null;
  set order_fact;
  by customer_id;

  if first.customer_id then do;
    order_count = 0;
    order_total = 0;
  end;

  order_count + 1;
  order_total+total_retail_price;

  if last.customer_id then do;
    call execute('proc print data=order_fact noobs;');
    call execute(cats('where customer_id =',customer_id,';'));
    call execute(catx(' ','title "',order_count,'Order(s) from customer ',customer_id,'totaling: ',put(order_total,dollar9.2),'";'));
    call execute('run;');
  end;
run;


/*4. pass variable values to a macro call*/
/*4-1*/
%macro orders(id, count,total);
proc print data=order_fact;
  where customer_id = &id;
  title "&count Order(s) from customer &id totaling: &total";
run;
%mend;


data _null;
  set order_fact;
  by customer_id;

  if first.customer_id then do;
    order_count = 0;
    order_total = 0;
  end;

  order_count + 1;
  order_total+total_retail_price;

  if last.customer_id then do;
    *call execute(cats('%orders(',customer_id,',',order_count,',',put(order_total,dollar9.2),')'));
    call execute(cats('%orders(',customer_id,',',order_count,',', ' %str( ', put(order_total,dollar9.2),'))'));  
  end;
run;


/*5. inappropriate uses of call execute*/

/*5-1*/

options symbolgen mlogic;
%macro example;
  %let test = OFF;
  data _null_;
    call symputx('test','ON','G');
  run;

  %if &test = ON %then %do;
    %put ***IT works!*;
  %end;
  %else %if &test = OFF %then %do;
    %put ***Not working!**;
  %end;
%mend;

data _null_;
  call execute('%example');
run;

%put &test;
