%macro ConditionCount(eval,in,out,issue) / des='Count rows that meet the condition';

    /* Check arguments */
    %if "&EVAL"="" %then %do;
        %put %str(E)RROR: No argument specified for EVAL.;
        %return;
    %end;
    %if "&IN"="" %then %do;
        %put %str(E)RROR: No argument specified for IN.;
        %return;
    %end;

    /* Set default for output */
    %if "&OUT"="" %then %let out=_NULL_;

    /* Set issue word */
    %if "&ISSUE" ne "" %then %do;

        %let issue=%upcase(&ISSUE);

        %if &ISSUE=E %then %let issue=%str(E)RROR;
        %else %if &ISSUE=W %then %let issue=%str(W)ARNING;
        %else %do;
            %put %str(E)RROR: %str(I)nvalid ISSUE argument. Please use E or W.;
            %return;
        %end;

    %end;
    %else %let issue=NOTE;

    /* Evaluate criteria */
    data &OUT;
        set &IN end=last;
        format flag 8.;
        retain flag 0;
        if %superq(eval) then flag+1;
        if last and flag then do;
            put "&ISSUE: Condition met " flag 'times.';
            put 'NOTE- ';
        end;
    run;

%mend ConditionCount;

/*
data input_data;
    format x y 8.;
    infile datalines;
    input x y;
datalines;
8 7
2 2
5 0
6 6
;
run;

%ConditionCount(x eq y, input_data);
*/
