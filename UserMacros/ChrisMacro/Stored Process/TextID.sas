%macro TextID(in,var,id=ID,out=,test=N) / des='Create a numeric ID for a text field that will always be the same';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       TextID
        Author:     Chris Swenson
        Created:    2011-10-17

        Purpose:    Convert a text field to an ID that will be the same when re-run.
                    The macro converts each part of the field into its binary
                    representation and then sums up each character.

        Arguments:  in    - input data set
                    var   - variable to assign an ID to
                    id    - ID variable name, defaulted to ID
                    out=  - output data set, defaulted to the input data set if blank
                    test= - Y/N flag to indicate whether to run the macro in test mode

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Check for blank arguments */
    %if %superq(IN)=%str() %then %do;
        %put %str(E)RROR: No argument specified for IN.;
        %return;
    %end;
    %if %superq(VAR)=%str() %then %do;
        %put %str(E)RROR: No argument specified for VAR.;
        %return;
    %end;

    /* Check for argument values in (Y N) */
    %let TEST=%substr(%upcase(&TEST), 1, 1);
    %if %index(*Y*N*,*&TEST*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid argument specified for TEST.;
        %put %str(E)RROR- Please use one of the following: Y or N.;
        %return;
    %end;

    /* Set the default for the output variable */
    %if "&OUT"="" %then %let out=&IN;

    data &OUT(drop=_i_
    %if &TEST=Y %then %do;
              step_:
    %end;
             )
    %if &TEST=Y %then %do;
         test(keep=&VAR &ID step_:)
    %end;
    ;
        format &ID 8.;
        set &IN;

        /* Steps in creating master ID */
        /* 1. substr(VAR, _i_) extracts the first character */
        /* 2. put(..., $binary8.) converts the character to binary */
        /* 3. input(..., binary8.) converts the binary to numeric */
        /* 4. ID + ... adds the numeric value to the master code */
        /* 5. The process is repeated for each character, adding each value to the */
        /*    previous, creating a unique master ID */
        &ID=.;
        do _i_=1 to length(&VAR);
            &ID + input(put(substr(&VAR, _i_, 1), $binary8.), binary8.);

        %if &TEST=Y %then %do;
            step_1=substr(product_type, _i_, 1);
            step_2=put(substr(product_type, _i_), $binary8.);
            step_3=input(put(substr(product_type, _i_), $binary8.), binary8.);
            step_4=plan_category_cd + input(put(substr(product_type, _i_, 1), $binary8.), binary8.);

            label step_1='Step 1: Extract 1 character'
                  step_2='Step 2: Convert character to binary'
                  step_3='Step 3: Convert binary to numeric'
                  step_4='Add the numeric value to the total'
            ;

            output test;
        %end;

        end;

    %if &TEST=Y %then %do;
        output &OUT;
    %end;
    run;

%mend TextID;
