%macro MinMaxDt(ds,datevar,format,override=N) / des='Output min and max of a date';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       MinMaxDt
        Author:     Chris Swenson
        Created:    2010-05-18

        Purpose:    Output min and max of a date

        Arguments:  ds        - input data set
                    datevar   - date variable
                    format    - format of date variable if it is text type
                    override= - re-run the macro overriding the original value

        Usage:      The macro will only run once for a given data set and variable
                    combination. It will output the previous value unless the
                    override argument is set to Yes.

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Check required arguments */
    %if "&ds"="" %then %do;
        %put %str(E)RROR: Data set argument missing.;
        %return;
    %end;
    %if "&datevar"="" %then %do;
        %put %str(E)RROR: Date variable argument missing.;
        %return;
    %end;

    /* Check if the macro has already been run with the same arguments */
    %let override=%substr(%upcase(&override), 1, 1);
    %if %symexist(minmaxdt)=1 and &override=N %then %do;

        %if "&minmaxdt"="&datevar on the &ds data set" %then %do;

            %put NOTE: Minimum and maximum dates already obtained for the &datevar variable on the &ds data set.;
            %put ;
            %goto exit;

        %end;

    %end;

    /* Manage scope */
    %global mindt maxdt minmaxdt;

    /* Determine type of variable */
    %local vtype vformat type;
    %let vtype=%varinfo(&ds, &datevar, type);
    %let vformat=%varinfo(&ds, &datevar, format);
    %let format=%upcase(&format);

    /* Identify whether the variable is date or datetime */
    %if &vtype=N %then %do;

        %if %index(*DATEAMPM*DATETIME*DTDATE*DTMONYY*DTWKDATX*DTYEAR*DTYYQC*EURDFDT*NLDATM*NLDATMAP*NLDATMTM*NLDATMW*TOD*,*&vformat*)>0 %then %let type=ndt;
        %else %let type=nd;

    %end;

    %else %if &vtype=C %then %do;

        %if "&format"="" %then %do;
            %put %(E)RROR: No format specified. Format argument required with character variables.;
            %return;
        %end;
        %else %if %index(DATEAMPM*DATETIME*DTDATE*DTMONYY*DTWKDATX*DTYEAR*DTYYQC*EURDFDT*NLDATM*NLDATMAP*NLDATMTM*NLDATMW*TOD*, *&format*)>0 
            %then %let type=cdt;
        %else %let type=cd;

    %end;

    %if "&format"="" %then %put NOTE: Variable type: &vtype | Variable format: &vformat;
    %else %put NOTE: Variable type: &vtype | Variable format: &vformat | Specified format: &format;

    /****************************************************************************/

    proc sql noprint;

    /* Numeric - Date format */
    %if &type=nd %then %do;
        select min(&datevar) format=YYMMDDN8.
             , max(&datevar) format=YYMMDDN8.
    %end;

    /* Numeric - Datetime format */
    %if &type=ndt %then %do;
        select min(datepart(&datevar)) format=YYMMDDN8.
             , max(datepart(&datevar)) format=YYMMDDN8.
    %end;

    /* Character - Date format */
    %if &type=cd %then %do;
        select min(input(&datevar, &format..)) format=YYMMDDN8.
             , max(input(&datevar, &format..)) format=YYMMDDN8.
    %end;

    /* Character - Datetime format */
    %if &type=cdt %then %do;
        select min(datepart(input(&datevar, &format..))) format=YYMMDDN8.
             , max(datepart(input(&datevar, &format..))) format=YYMMDDN8.
    %end;

        into :mindt, :maxdt
        from &ds
        where not missing(&datevar)
        ;
    quit;

    /****************************************************************************/

    %let mindt=&mindt;
    %let maxdt=&maxdt;
    %let minmaxdt=&datevar on the &ds data set;

    %exit:

    %put NOTE: Minimum Date: &mindt (MINDT);
    %put NOTE- Maximum Date: &maxdt (MAXDT);
    %put NOTE- of &minmaxdt;

%mend MinMaxDt;
