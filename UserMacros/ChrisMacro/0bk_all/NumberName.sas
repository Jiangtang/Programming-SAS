%macro NumberName(in,out,var,newvar,style=SHORT) / des='Convert numbers to names';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       NumberName
        Author:     Chris Swenson
        Created:    2010-11-12

        Purpose:    Convert numbers (e.g., 1000) to names (e.g., One thousand)

        Arguments:  in     - input data set
                    out    - outpout data set
                    var    - variable containing numbers
                    newvar - new variable
                    style= - LONG or SHORT style

        Note:       The macro does not generate names for decimal places.

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %macro NumberNameFmt(lib) / des='Create format for NumberName macro';

        %if "&LIB"="" %then %do;
            %put %str(E)RROR: No library specified.;
            %return;
        %end;

        data NumberName;
            format Start End Label $25.;
            retain Fmtname '$Numbername' Type 'C';

            /* Ones */
            start='1'; label='one';         end=start; HLO=''; output;
            start='2'; label='two';         end=start; HLO=''; output;
            start='3'; label='three';       end=start; HLO=''; output;
            start='4'; label='four';        end=start; HLO=''; output;
            start='5'; label='five';        end=start; HLO=''; output;
            start='6'; label='six';         end=start; HLO=''; output;
            start='7'; label='seven';       end=start; HLO=''; output;
            start='8'; label='eight';       end=start; HLO=''; output;
            start='9'; label='nine';        end=start; HLO=''; output;

            /* Teens */
            start='10'; label='ten';        end=start; HLO=''; output;
            start='11'; label='eleven';     end=start; HLO=''; output;
            start='12'; label='twelve';     end=start; HLO=''; output;
            start='13'; label='thirteen';   end=start; HLO=''; output;
            start='14'; label='fourteen';   end=start; HLO=''; output;
            start='15'; label='fifteen';    end=start; HLO=''; output;
            start='16'; label='sixteen';    end=start; HLO=''; output;
            start='17'; label='seventeen';  end=start; HLO=''; output;
            start='18'; label='eighteen';   end=start; HLO=''; output;
            start='19'; label='nineteen';   end=start; HLO=''; output;

            /* 20+ */
            start='20'; label='twenty';     end=start; HLO=''; output;
            start='30'; label='thirty';     end=start; HLO=''; output;
            start='40'; label='forty';      end=start; HLO=''; output;
            start='50'; label='fifty';      end=start; HLO=''; output;
            start='60'; label='sixty';      end=start; HLO=''; output;
            start='70'; label='seventy';    end=start; HLO=''; output;
            start='80'; label='eighty';     end=start; HLO=''; output;
            start='90'; label='ninety';     end=start; HLO=''; output;

            /* Other */
            start=''; label=''; end=start; HLO='O'; output;
        run;

        proc format library=&LIB cntlin=NumberName;
        run;

        proc catalog c=&LIB..formats;
            modify NumberName.formatc(description="Number names used with NumberName macro");
        run; quit;

    %mend NumberNameFmt;

    %let style=%upcase(&STYLE);

    /* Check arguments */
    %if "&in"="" %then %do;
        %put %str(E)RROR: No argument specified for IN.;
        %return;
    %end;
    %if %sysfunc(exist(&in))=0 %then %do;
        %put %str(E)RROR: Specified input data set does not exist.;
        %return;
    %end;
    %if "&out"="" %then %do;
        %put %str(E)RROR: No argument specified for OUT.;
        %return;
    %end;
    %if "&var"="" %then %do;
        %put %str(E)RROR: No argument specified for VAR.;
        %return;
    %end;
    %if "&NEWVAR"="" %then %do;
        %put %str(E)RROR: No new variable name (NEWVAR) specified.;
        %return;
    %end;
    %if %index(*LONG*SHORT*,*&STYLE*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid STYLE argument. Please use SHORT or LONG.;
        %return;
    %end;

    %local varlen fmt;

    /* Check length of number in characters */
    proc sql noprint;
        select max(length(compress(put(&var, 25.))))
        into :varlen
        from &in
        ;
    quit;

    %if &varlen>21 %then %do;
        %put %str(E)RROR: Specified variable exceeds the current limit of macro (21).;
        %return;
    %end;

    /* Check on the availability of the NumberName format */
    %let fmt=0;
    proc sql noprint;
        select count(fmtname)
        into :fmt
        from dictionary.formats
        where fmtname='$NUMBERNAME'
        ;
    quit;
    %let fmt=&fmt;

    /* Run the macro to create the format if it is not available */
    %if &FMT=0 %then %do;
        %put NOTE: The $NUMBERNAME format was not available. The macro will execute the NumberNameFmt macro.;
        %put NOTE: To save the $NUMBERNAME format in a permanent library for faster processing,;
        %put NOTE: run the NumberNameFmt macro specifying a permanent library and modify the FMTSEARCH option.;
        %NumberNameFmt(work);
    %end;

    /* Convert the number to the name */
    data &out(drop=_temp_ _digit_ _scale_ i i_d);
        set &in;
        format _temp_ $25. &newvar $250. _digit_ $1. _scale_ $50.;

        /* Add leading zeros to the input number for scanning */
        _temp_=left(put(&var, z21.));

        /* Loop through each digit, one at a time */
        do i=1 to 21;

            /* Scan for the Ith digit */
            _digit_=substr(compress(_temp_), i, 1);

            /* Set the scale */
            /* The dots will not be included and are only used as placeholders */
        %if &STYLE=SHORT %then %do;
            _scale_=scan(". . quintillion, . . quadrillion, . . trillion, . . billion, . . million, . . thousand, . . .", i, ' ');
        %end;
        %else %if &STYLE=LONG %then %do;
            _scale_=scan(". . trillion, . . thousand_billion, . . billion, . . thousand_million, . . million, . . thousand, . . .", i, ' ');
        %end;

            /* Divide the iteration by 3 to determine hundreds/tens/ones place */
            /* Since the number has been padded with zeros in groups of 3, if the scan
               iteration is divisible by 3, it is in the Ones place. If .67 remains,
               it is in the tens place. If .33 remains, it is in the hundreds place. */
            i_d=scan(put(i/3, 20.2), -1, '.');

            /* Hundreds place */
            /* Only populate if not zero */
            if i_d='33' then do;
                if put(_digit_, $NumberName.) ne ''
                then &newvar=compbl(&newvar || ' ' || put(_digit_, $NumberName.) || ' hundred ');
            end;

            /* Tens place */
            /* For those starting with 1, add the ones place. Add a 0 for the others. */
            else if i_d='67' then do;
                if _digit_='1' then &newvar=compbl(&newvar || ' ' || put(substr(compress(_temp_), i, 2), $NumberName.));
                else &newvar=compbl(&newvar || ' ' || put(compress(_digit_ || '0'), $NumberName.));
            end;

            /* Ones place */
            /* Only process if the tens place was not 1, and add the scale at the end */
            else if i_d='00' then do;
                if substr(compress(_temp_), i-1, 1) ne '1'
                then &newvar=compbl(&newvar || ' ' || put(_digit_, $NumberName.));
                if &newvar ne '' and _scale_ ne '.' then &newvar=compbl(&newvar || _scale_);
                else if &var=0 then &newvar='Zero';
            end;

        end;

        /* Final cleanup: Set characters to left, remove _ from the long style, and
           set the first letter to upper-case */
        &newvar=tranwrd(left(&newvar), '_', ' ');
        &newvar=upcase(substr(&newvar, 1, 1)) || substr(&newvar, 2, length(&newvar)-1);
    run;

%mend NumberName;
