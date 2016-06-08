data a;
    word="1234321";

    i=1;
    j=length(word);

    do while(i<j);
        a=substr(word,i,1);
        b=substr(word,j,1);
        
        i=i+1;
        j=j-1;

        if a ne b then isP=0;
        else isP=1;

        output;
    end;
run;


data _null_;
    word="weow";
    rev=reverse(word);
    if word ne rev then isP=0;
    else isP=1;
    put isP=;
run;

