/*<pre><b>
/ Program      : unistats.sas
/ Version      : 11.8
/ Author       : Roland Rashleigh-Berry
/                Joachim Klinger
/ Date         : 07-Jun-2015
/ Purpose      : Clinical reporting macro to calculate proc univariate
/                statistics and category counts with percentages with optional
/                statistics added and by default to print a report.
/ SubMacros    : %unimap %words %fmtord %vartype %varfmt %unipvals %quotelst
/                %zerogrid %allfmtvals %unicatrep %varlen %qdequote %verifyb
/                %quotecnt %quotescan %noquotes %unicat2word %sortedby %match
/                %mvarlist %mvarvalues %varlistn %nlobs %nodup %attrc %eqsuff
/                %removew %hasvarsc %varnum (assumes %popfmt already run)
/ Notes        : When dstranstat= or dstranstattrt= is specified then character
/                variables whose names end with STR are created for every
/                corresponding transposed numeric variable where the number of
/                decimal places can optionally be adjusted using the variable
/                specified to dpvar= .
/
/                The formats nfmt=, minfmt= etc. will be applied to all numeric
/                variables. To adjust them individually (compared to these
/                settings) you can end the variable with /+1 (no spaces) to add
/                one decimal place to all values (has no effect on nfmt=) or
/                /-1 to substract one decimal place. /+2 will add two decimal
/                places etc.. If you ask for statistics name transposed data then
/                no adjustment will be done as only one format can be applied.
/                It only works for treatment arm transposed data and the maximum
/                length allowed for any format is the length of catnfmt= plus 8.
/                An additional "m" in the decimal place adjust will make the min
/                and max values use the same format as mean.
/
/                A global macro variable _statkeys_ is created that maps the
/                labels supplied to stats= to their resulting variable names.
/
/                You can request output datasets from this macro. The contents
/                of these datasets are described below.
/
/                These are the variables in the dsout= dataset (stats)
/                -----------------------------------------------------
/                &byvars: whatever you defined to the byvars= parameter
/                &trtvar: whatever you defined to the trtvar= parameter
/                _page: Will be all 1 unless variables have been assigned to the
/                       page1/2/..vars= parameters
/                _varord: A sequence number for the variables defined to varlist=
/                _vartype: "C" or "N" depending whether the variable is numeric
/                         or categorical. Note that numeric variables can be
/                         categorical depending on the assigned format.
/                _varname: The name of the variable
/                _varlabel: The label of the variable.
/                _dpadj:   Decimal point adjustment
/                _minmaxadj: Make decimal points of min and max the same as mean
/                _statord: A sequence number for the statistic (or category).
/                          If catn= has a value then the sequence number for it
/                          will be 0.5
/                _statname: The name of the statistic (or category value)
/                _statlabel: The label of the statistic (or category). For stats
/                         this will be as you defined it for the stats= parameter.
/                _value: Value of the statistic (or count of the category)
/                _pct: Percentage for category (for stats it will be missing)
/                _dummy=0: Dummy variable you can use to "flatten" a proc report
/                          by declaring it "group noprint" after the "across"
/                          variables have followed other "group" variables.
/
/
/                These are the variables in the dspout= dataset (pvalues)
/                --------------------------------------------------------
/                &byvars: whatever you defined to the byvars= parameter
/                &trtvar=9999: or whatever value assing to ptrtval=
/                _page: Will be all 1 unless variables have been assigned to the
/                       page1/2/..vars= parameters
/                _varord: A sequence number for the variables defined to varlist=
/                _vartype: "C" or "N" depending whether the variable is numeric
/                         or categorical. Note that numeric variables can be
/                         categorical depending on the assigned format.
/                _varname: The name of the variable
/                _varlabel: The label of the variable.
/                _statvalue: Statistics value
/                _pvalue: p-value
/                _test: Test used CHISQ/FISHER/ANOVA
/                _statord=1 for categorical variables (or 0.5 if catn= is set)
/                           and for numeric variables it is the value
/                           corresponding to the MEAN statistic.
/                _statname: The name of the statistic (or category value)
/                _statlabel: The label of the statistic (or category). For stats
/                         this will be as you defined it for the stats= parameter
/                _dummy=0
/
/
/                These are the variables in the dstrantrt= dataset
/                       (treatment variable transposed data)
/                -------------------------------------------------
/                &byvars: whatever you defined to the byvars= parameter
/                _page: Will be all 1 unless variables have been assigned to the
/                       page1/2/..vars= parameters.
/                _varord: A sequence number for the variables defined to varlist=
/                _vartype: "C" or "N" depending whether the variable is numeric
/                         or categorical. Note that numeric variables can be
/                         categorical depending on the assigned format.
/                _varname: The name of the variable
/                _varlabel: The label of the variable
/                _dpadj:   Decimal point adjustment
/                _minmaxadj: Make decimal points of min and max the same as mean
/                _statord: A sequence number for the statistic (or category).
/                          If catn= has a value then the sequence number for it
/                          will be 0.5
/                _statname: The name of the statistic (or category value)
/                _statlabel: The label of the statistic (or category). For stats
/                         this will be as you defined it for the stats= parameter
/                _dummy=0
/                _indent='        '
/                TRT1, TRT2, TRT3, etc.: character formatted value(s) with
/                         variable names that are constructed using the prefix
/                         defined to tranpref= followed by actual treatment arm
/                         values.
/
/                Output order for the above dataset will be in the order
/                variables have been listed above.
/
/
/                These are the variables in the dstranstat= dataset
/                         (statistic name transposed data)
/                --------------------------------------------------
/                &byvars: whatever you defined to the byvars= parameter
/                &trtvar: whatever you defined to the trtvar= parameter
/                &dpvar:  whatever you defined to the dpvar=  parameter
/                _page: Will be all 1 unless variables have been assigned to the
/                       page1/2/..vars= parameters.
/                _varord: A sequence number for the variables defined to varlist=
/                _vartype: "C" or "N" depending whether the variable is numeric
/                         or categorical. Note that numeric variables can be
/                         categorical depending on the assigned format.
/                _varname: The name of the variable
/                _varlabel: The label of the variable
/                _dpadj:   Decimal point adjustment
/                _deffmt:  Default format (without &dpvar applied)
/                _valfmt:  Value format (with &dpvar applied)
/                _minmaxadj: Make decimal points of min and max the same as mean
/                N, MIN, MEAN, MAX etc. or whatever you defined to the stats=
/                        parameter. Note that the variable names follow the
/                        proc univariate naming conventions which are as follows:
/                        N, MIN, MEAN, MAX, STD, P1, P5, P10, Q1, MEDIAN, Q3, P90,
/                        P95, P99 and the labels of these variables will be the
/                        actual strings supplied to the stats= parameter.
/                NSTR, MINSTR, MEANSTR etc. which are the character variable
/                versions of the above numeric variables.
/
/                Output order for the above dataset will be in the order
/                variables have been listed above.
/
/
/                These are the variables in the dstranstattrt= dataset
/                    (statistic name+treatment arm transposed data)
/                -----------------------------------------------------
/                &byvars: whatever you defined to the byvars= parameter
/                &dpvar:  whatever you defined to the dpvar=  parameter
/                _page: Will be all 1 unless variables have been assigned to the
/                       page1/2/..vars= parameters.
/                _varord: A sequence number for the variables defined to varlist=
/                _vartype: "C" or "N" depending whether the variable is numeric
/                         or categorical. Note that numeric variables can be
/                         categorical depending on the assigned format.
/                _varname: The name of the variable
/                _varlabel: The label of the variable
/                _dpadj:   Decimal point adjustment
/                _deffmt:  Default format (without &dpvar applied)
/                _valfmt:  Value format (with &dpvar applied)
/                _minmaxadj: Make decimal points of min and max the same as mean
/                N1, N2, MIN1, MIN2 etc. or whatever you defined to the stats=
/                        parameter. Note that the variable names follow the
/                        proc univariate naming conventions which are as follows:
/                        N, MIN, MEAN, MAX, STD, P1, P5, P10, Q1, MEDIAN, Q3, P90,
/                        P95, P99 and the labels of these variables will be the
/                        actual strings supplied to the stats= parameter.
/                N1STR, N2STR, MIN1STR, MIN2STR etc. which are the character
/                variable versions of the above numeric variables.
/
/                Output order for the above dataset will be in the order
/                variables have been listed above.
/
/ Usage        : See tutorial with demonstrations on the Spectre web site. After
/                completing the tutorial you will be able to learn more about the
/                capabilities of this macro by reading this header.
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              Name of input dataset (where clause allowed)
/ msglevel=X        Message level to use inside this macro for notes and 
/                   information written to the log. By default, both Notes and
/                   Information are suppressed. Use msglevel=N or I for more
/                   information.
/ varlist           Variables to calculate stats/category counts for. Variables
/                   should be separated by spaces. Decimal places can be
/                   adjusted by following the variable name with /+1 etc. (add 1
/                   decimal place), /m (make mean, max and min have the same
/                   number of decimal places) and a variable label can be
/                   declared in the form var1="variable one". If you define
/                   variable labels then you must enclose the list in %str() so
/                   that the equals signs don't get confused with parameter
/                   assignments.
/                   You can force page breaks between variables by putting <p>
/                   or <pg> between the variables. These too must have spaces
/                   either side to distinguish them.
/ pageon=           If you are using byrowvar= and byrowfirst=yes then you can
/                   further force page throws by specifying byrow variable
/                   values (separated by spaces) to cause a page throw. For
/                   numeric variables then you should specify the value(s)
/                   unquoted but for character variables the value(s) can be a
/                   start string value or whole value quoted. Take care whether
/                   your variable is numeric or character. For example, you
/                   could have a "sexcd" byrow variable that is numeric but
/                   formatted as character in which case your pageon= values
/                   should be numeric. If you set the pageon= value to be
/                   identical to your bvyrowvar= variable name then it will
/                   force page throws for each new value of the byrowvar
/                   variable. This parameter is only useful if you are calling
/                   the %unicatrep macro.
/ usettest=no       By default, do not use proc ttest for continuous numeric
/                   variables for two treatment arms but rather use proc glm
/                   ANOVA instead. Set this to yes to use proc ttest but none
/                   of the glm parameters will be accepted.
/ sattcond=<0.1     This applies to proc ttest and is the condition of the 
/                   Probability F test value for the equality of variances such
/                   that the Satterthwaite approximation T value and ProbT value
/                   get used instead of the Pooled T value and ProbT value.
/ modelproc=GLM     Procedure to use for modeling
/ nparvarlist       Variables to be processed by "proc npar1way"
/ exactvarlist      Variables defined to nparvarlist= that require a p-value
/                   based on a non-parameteric exact test.
/ chisqvarlist      Categorical variables for the Chi-square test (must also be
/                   defined to varlist= and statvarlist=)
/ fishervarlist     Categorical variables for the Fisher's exact test (must also
/                   be defined to varlist= and statvarlist=)
/ chifishvarlist    Categorical variables where the choice between the
/                   Chi-square test and Fisher's exact test is determined based
/                   on Cochran's recommendation.
/ stattrtlist       List of treatment arm values (separated by spaces) used for
/                   stats calculations (defaults to not using the value
/                   assigned to _trttotstr_).
/ statlabelmacro=unistatlabel     Macro to call to change _statlabel values. By
/                   default this is "unistatlabel". You might have a different
/                   macro to do this for each sponsor.
/ npvalstat=MEAN    Statistic keyword to merge numeric pvalues with. Note that
/                   for merging with paired statistic labels then the first
/                   keyword should be used.
/ stat0lbl="Value"  Label for the stat column 0
/ stat1lbl="p-value" Label for the stat column 1
/ stat2-9lbl=" "    Label for stats column 2-9
/ stat0-9w=6        Width of the stats columns 0-9
/ stat1-9w=8
/ statalign=c       Alignment of stats columns is "c" (no quotes) for "center".
/                   This will be the default for individual stats columns.
/ stat0-9align      Alignment of stats columns 0-9
/ showstat0=no      Default action for showing the statistics value column
/ showstat1=yes     Default action for showing the pvalue column
/ statsopdest       Default is not to write the stats output to any destination.
/                   This is an ODS style destination for the output from the
/                   statistical procedures when you are calculating p-values.
/                   "ODS" will be added at the start of your call plus the
/                   ending semicolon. The first word of your parameter values
/                   will be used in the ods close statement. To route the stats
/                   output to the normal window then set the value to LISTING.
/                   To write listing output to a file then use in the form
/                      LISTING FILE="name-of-the file"
/                   Note that file names must be used and not filerefs.
/                   To route output to a PDF with a style then use in the form
/                      PDF FILE="name-of-the-file" style=journal
/                   ------------------------------------------------------------
/ freqsept1-20      Proc freq septuplet statements for the placement of values 
/                   from ods tables in the output report/dataset in the form:
/                      varname(s)#keyword#missing#dset#statno#statord#code
/                   where "varname(s)" is the variable name or list of variable
/                   names separated by spaces,
/                  "keyword" is the proc freq option name,
/                  "missing" is "Y" or "N" for whether to include missing values
/                   in the calculation,
/                  "dset" is the ods table name with the attached where clause
/                   (if you prefix this table name with "Tr" it will transpose
/                   the table so that Name1 will become the variable name and
/                   Value1 its value),
/                  "statno"=1-9 for the STAT column number (you can also specify
/                   a treatment arm such as TRT1, TRT2 etc.),
/                  "statord" is the order number in the list of descriptive
/                   statistics and
/                  "code" is the code to format the value(s) for variables in
/                   the ods table.
/                   ------------------------------------------------------------
/ odstables         Extra needed ODS tablenames other than Welch and ModelAnova.
/                   Example: odstblname=LSMeanCL LSMeanDiffCL will create
/                   extra datasets named LSMeanCL and LSMEeanDiffCL which you
/                   can refer to in your "quad" statements as described below.
/ quad1-9           quadruplet statements for the placement of values from
/                   ods tables in the output/report dataset in the form:
/                      dset#statno#statord#code
/                   where "dset" is the ods table name with the attached where
/                   clause, 
/                  "statno"=1-9 for the STAT column number (you can also
/                   specify a treatment arm such as TRT1, TRT2 etc.),
/                  "statord" is the order number in the list of descriptive
/                   statistics, and 
/                  "code" is the code to format the value(s) in the ods table.
/ weight            WEIGHT statement that can be added as an extra. The
/                   start word WEIGHT and ending semicolon will be generated.
/ adjcntrvar        Variable representing the centre to be used in adjustment
/                   for centre effects in PROC call. Only one variable
/                   allowed. Terms will be generated in the model statement
/                   for modelform=short as:
/                     model response=trtcd centre /ss1 ss2 ss3 ss4;
/                   or for modelform=long as:
/                     model response=trtcd centre trtcd*centre /ss1 ss2 ss3 ss4;
/                   You can use this parameter for a variable other than a
/                   centre but note that whatever variable you choose, if it is
/                   not a categorical or dichotomous variable suitable for use
/                   in the CLASS statement of a PROC  call then you will need
/                   to use the class= parameter to supply the correct call.
/ errortype=3       Default is to select the error type 3 (Hypothesis type)
/                   treatment arm p-value from the ModelANOVA ODS dataset that
/                   is output from the  procedure.
/ modelform=short   Default is to generate the short form of the model
/                   statement as described in the adjcntrvar= parameter
/                   description.
/ dsmodelanova      Dataset to append the ModelANOVA datasets to generated by
/                   the PROC.
/ hovwarn=yes       Issue a warning message where the homogeneity of variances
/                   shows a significant difference. This will only be done for
/                   one-way ANOVA so if adjcntrvar= is set then the hov*=
/                   parameters will be ignored. A NOTE statement will be
/                   generated where appropriate if a warning is not issued.
/ hovcond=LE 0.05   Condition for meeting HoV significance
/ hovtest=Levene    HoV test to use. You can choose between OBRIEN, BF,
/                   Levene, Levene(type=square) and Levene(type=abs). Levene
/                   and Levene(type=square) are the same. The Bartlett test is
/                   not supported.
/ welch=no          By default, do not calculate ANOVA p-values using the Welch
/                   test for one-way ANOVA where the HoV condition for
/                   significance is met. If Welch is used then the hovtest
/                   defined to hovtest= will be employed in the MEANS statement.
/ cntrwarn=yes      By default, warn if a centre effect and/or centre-by-
/                   treatment effect is significant. For the short model as
/                   described for the adjcntrvar= parameter, use the centre
/                   term. For the long model, use the centre and
/                   centre-by-treatment effect term.
/ cntrcond=LE 0.05  Condition for significance to apply to the centre effect
/ intercond=LE 0.1  Condition for significance to apply to the
/                      treatment*centre interaction.
/                   ------------------------------------------------------------
/ descstats         NOTE: If you define any paired statistics for this parameter
/                   then you will have to set a value for mincolw= (the minimum
/                   column width) yourself as this is not yet automatically
/                   calculated.
/
/                   List of descriptive statistic labels separated by spaces
/                   (allows for footnote flags at end for unpaired statistics).
/                   These will be mapped to statistics keywords and if not
/                   possible an error message will be issued. You are allowed
/                   to pair stats labels such as "Mean(SD)" and in this case
/                   the values will be combined using the extra characters in
/                   the string as the delimiters. Although, for paired stats,
/                   no spaces are allowed, a space will be substituted for the
/                   "^" character to allow you to add spaces to improve layout.
/                   Although, for single statistics, an attempt is made to align
/                   all values with the decimal point, this can not be done for
/                   paired statistics.
/ trtvar            Treatment arm variable (defaults to &_trtvar_ set up in the
/                   %popfmt macro but must be set if %popfmt not called) which
/                   must be a coded numeric variable or a short coded character
/                   variable (typically one or two bytes with no spaces).
/ trtfmt            Treatment arm format (defaults to &_trtfmt_ set up in the
/                   %popfmt macro but must be set if %popfmt not called).
/ trtvallist        This is a list of the treatment arm values unquoted. You
/                   do not need to specify this since it defaults to the
/                   contents of _trtvallist_ created by the %popfmt macro but
/                   if the contents of that global macro variable are not
/                   suited to your needs then you can override it using this
/                   parameter.
/ trtalign=c        Default alignment of treatment column headers is centred
/ total=no          By default, do not show total for all treatment arms
/ byvars            By variable(s)
/ dsout=_unistats   Output dataset (no modifiers - defaults to _unistats). If
/                   you rename this then do not use an underscore prefix
/                   otherwise it could be deleted.
/ dspout=_pvalues   P-value output dataset name (no modifiers - defaults to
/                   _pvalues)
/ dstrantrt         Dataset name for treatment arm transposed data
/                   (no modifiers).
/ dstranstat        Dataset name for statistic transposed data (no modifiers)
/ dstranstattrt     Dataset name for statistic-trt transposed data (no
/                   modifiers). Varibale names will the the statistics key
/                   name followed by the treatment arm identifier (eg.
/                   MEAN1 (for trt=1), MEANA (for trt="A") etc.)
/ plugtran=no       By default, do not plug the missing string variables with
/                   zeroes or periods for the dstranstattrt= output dataset.
/ unicatrep=no      By default, do not produce a report for treatment arm
/                   transposed data.
/ print=yes         This is passed on to %unicatrep and if set to "no" (no
/                   quotes) the .lst output will be suppressed. This is in
/                   case you just want ODS output.
/ unicatstyle=1     Style to use for the %unicatrep macro. 1=indented
/                   2=separate columns.
/ varw=12           Width of variable label column for unicatstyle=2
/ unistatrep=no     By default, do not produce a report for statistic name
/                   transposed data (REPORT NOT AVAILABLE YET).
/ spantotal=yes     For when unicatrep is called, trtlabel spans the total
/                   column as well, if there.
/ tranpref=TRT      Prefix for transposed treatment arm variable names
/ missing=yes       By default, display counts of categorical values that are
/                   missing using what is defined to misstxt= as the name.
/ misstxt=Not Recorded     Text for missing categoricals
/ misspct=no        By default, do not calculate and show percentages for
/                   missing value categories. If set to "no" (the default)
/                   then p-values will not be based on the missing category
/                   count. For these missing values to not feature in the
/                   percentage values for non-missing categories, use
/                   pctcalc=cat so that the percentage is based on the non-
/                   missing category count.
/ nopctcatlist      Extra categories to exclude from the percentage calculation
/                   and p-value calculations. The items should be quoted and
/                   separated by spaces. Item text should match the case before
/                   any lowercasing is done by this macro.
/ catn              By default, do not show the "N" category count. Set this to
/                   "n", "N" or "n(missing)" (not quoted) to activate it. Note
/                   that if a left round bracket is detected then the number of
/                   missing values will be shown in round brackets following
/                   the "n" count. Although free text is allowed, the second
/                   part of the expression will be shown as the number of
/                   missing values. No other statistic is possible.
/ varordadd=0       Optional number to add to _varord sequence values. You
/                   would only use this if you were making multiple calls to
/                   %unistats and bringing together the output datasets.
/                   ------------------------------------------------------------
/                   Note that the following three parameters determine the
/                   minimum width of the columns for when %unicatrep is called,
/                   although you can override this by setting mincolw= .
/                   The minimum width of the column is the length of the
/                   catnfmt plus the pctfmt plus 3 (plus 1 if pctsign=yes).
/                   If you are using paired stats labels then you can either
/                   set mincolw= to a suitable value or increase the catnfmt
/                   format length to avoid columns for the paired stats being
/                   truncated.
/ catnfmt=3.        Format for category counts for tranposed data
/ pctfmt=5.1        By default, use the 5.1 format to display percentages. You
/                   must give this format a length for a user format.
/ pctsign=no        By default, do not show the percent sign for percentages
/                   ------------------------------------------------------------
/                   Note that you would normally set nfmt= to the same as
/                   catfmt= and make sure the other formats that follow it
/                   match such that the number of digits to the left of the
/                   decimal point matches that for nfmt= .
/ nfmt=3.           Format for N statistic for tranposed data
/ stdfmt=6.2        Format for STD statistic for tranposed data
/ minfmt=5.1        Format for MIN statistic for tranposed data
/ maxfmt=5.1        Format for MAX statistic for tranposed data
/ meanfmt=5.1       Format for MEAN statistic and ALL OTHER statistics for
/                   tranposed data.
/ pvalfmt=p63val.   Default format (created inside this macro) for p-value
/                   statistic for tranposed data (6.3 unless <0.001 or >0.999)
/ probfmt=p73val.   Default format (created inside this macro) for p-value
/                   statistic for tranposed data (7.3 unless <0.001 or >0.999)
/ statvalfmt=6.2    Default format for statistics value
/ dpvar             Numeric variable containing the expected number of decimal
/                   places for measured values (optional - only applies to
/                   character variable equivalents of those numeric variables
/                   transposed by statistics name). Values higher than 0
/                   increment the number of decimal places over those indicated
/                   by the above given formats by that amount. This will
/                   normally be used for transposed lab data values where
/                   different lab parameters are displayed to different
/                   precisions. If you need to drop leading spaces in some cases
/                   then post-process the output dataset.
/ leftstr=no        By default, do not left align the values formatted in the
/                   --STR character variables.
/ padmiss=no        Related to the leftstr= parameter this is to say if you want
/                   missing values padded after the decimal point with non-
/                   breaking spaces to help align it when you display the string
/                   as right justified.
/ pvalmisstxt=" n/a"  (quoted) Used in the internal p63val. format for assigning
/                   a string when the p-value has a missing value.
/ pvalids=yes       By default, attach p-value ids to the end of p-values as per
/                   the list defined below.
/ fisherid=^        Symbol to suffix formatted p-values for the Fisher exact
/                   test.
/ chisqid=~         Symbol to suffix formatted p-values for the Chi-square test
/ cmhid=$           Symbol to suffix formatted p-values for the CMH test
/ anovaid=#         Symbol to suffix formatted p-values for the ANOVA
/ welchid=&         Symbol to suffix formatted p-values for the Welch test
/ nparid=§          Symbol to suffix formatted p-values for the non-parametric
/                   Kruskal-Wallis test (or Wilcoxon rank sum test).
/ ttestid=$         Symbol to suffix formatted p-values for the Pooled ttest
/ sattid=&          Symbol to suffix formatted p-values for the Satterthwaite
/                   approximation of the ttest.
/ nodata=nodata     Name of macro to call to produce a report if there is no
/                   data. This would normally put out a "NO DATA" message.
/ catlabel=" "      For a print the default is for no category column label
/ varlabel=" "      For a print the default is for no variable column label
/ catw              By default this macro will assign a category column width
/                   to meet the page width.
/ odsescapechar="°" ODS escape character (quoted)
/ trtlabel          Label for combined category counts and stats
/ odstrtlabel       ODS non-listing output label for combined category counts and
/                   stats (defaults to value of trtlabel= ). Note that column
/                   underlines defined using "--" that work for ascii output do
/                   not work for ODS output. Assuming "^" is the ODS escape
/                   character then to achieve a spanning underline for ODS output
/                   then use the following method where both the ascii form and
/                   ODS form are shown as examples (works for SAS 9.2 or later)
/              trtlabel="Treatment Arm" "__"
/           odstrtlabel='^{style [borderbottomwidth=1 borderbottomcolor=black]
/                        Treatment Arm}'
/ topline=yes       Default is to show a line at the top of the report for ascii
/                   output. Non-listing ODS output will not show this line.
/ pageline=no       Default is not to show a line under the report on each page
/ pageline1-15      Additional lines (in quotes) to show at the bottom of each
/                   page.
/ pagemacro         Name of macro (no starting "%") to assign the page line
/                   values instead of setting them manually. This macro will be
/                   called in a "proc report" compute block so it must not
/                   contain any data step or procedure boundaries in any code
/                   it calls and must resolve to something that is syntactically
/                   correct for compute block processing. You can have 
/                   parameter settings in the macro call.
/ endline=no        Default is not to show a line under the end of the report.
/                   This is the best setting for ODS RTF tables and the like.
/ endline1-15       Additional lines (in quotes) to show at end of report
/ endmacro          Name of macro (no starting "%") to assign the end line
/                   values instead of setting them manually. This macro will be
/                   called in a "proc report" compute block so it must not
/                   contain any data step or procedure boundaries in any code
/                   it calls and must resolve to something that is syntactically
/                   correct for compute block processing. You can have 
/                   parameter settings in the macro call.
/ pgbrkpos=before   Page break position defaults to before. This will allow
/                   the endline1-9 to be put after the last item is displayed.
/                   If set to "after" (no quotes) then endline1-9 will be forced
/                   onto a new page.
/ spacing=2         Default spacing is 2 between the categories and treatments
/ trtspace=4        Default spaces to leave between treatment arm columns
/ trtw1-19          Widths for each treatment column. If left blank then this
/                   will be calculated for you.
/ trtsp1-19         You can specify individual column spacing for the treatment
/                   arms. If left blank then this will be filled in from the
/                   spacing= parameter setting (for the first treatment arm)
/                   and the trtspace= setting for the others.
/ indent=4          Spaces to indent categories for report
/ split=@           Split character (no quotes) for proc report if requested
/ pctcalc=pop       By default, category percentages are calculated on the basis
/                   of treatment arm population. This can be changed to "cat"
/                   (no quotes) to calculate percentages based on total category
/                   counts.
/ allcatvars        List of variables (separated by spaces) for which all
/                   categories belonging to a format are displayed.
/ allcat=yes        By default, show all the possible format values for
/                   categorical variables. If set to yes then this overrides
/                   the allcatvars= setting.
/ lowcasevarlist    For categorical variables, make sure the second character
/                   onwards are displayed as lower case.
/ dpalign=yes       Default is to align the decimal point for descriptive
/                   statistics for listing output. Set this to "no" (no quotes)
/                   to disable this action.
/ odsdpalign=no     Default it not to align on decimal point for non-listing ODS
/                   output. The reason being that mostly a proportional font is
/                   used for non-listing ODS output and so alignment of the
/                   decimal point is not possible in any case.
/ pctwarn=yes       By default, put out a warning message if a percentage is
/                   greater than 100.01
/ out               Named output dataset from proc report if required when
/                   %unicatrep macro is called.
/ wordtabdest       Destination for a Word-type table of cell values to copy and
/                   paste into Word and turn into a table. This only works for
/                   where you have treatment columns like %unicatrep reports.
/                   Note that you can use the odsrtf= parameter to give you RTF
/                   tables suitable for inclusion into Word documents. RTF
/                   tables can easily be manipulated and edited by word
/                   processors.
/ wordtabdlim=';'   Delimiter to use for Word-type table of cell values (must be
/                   quoted).
/ odsrtf            Give the "file='filename' style=style" (unquoted) to create
/                   RTF output. This will be passed to the %unicatrep macro.
/                   "ods rtf   ;" and "ods rtf close;" will be automatically
/                   generated. If you want to suppress the plain text output
/                   then use the setting print=no.
/ odshtml           Works the same way as odsrtf
/ odshtmlcss        Works the same way as odsrtf
/ odscsv            Works the same way as odsrtf
/ odspdf            Works the same way as odsrtf
/ odslisting        Allows you to specify a file= statement to pass through to
/                   the %unicatrep macro.
/ odsother          Works the same way as odsrtf but you have to supply the
/                   destination word as the first word.
/ tfmacro           Name of macro (no % sign) containing titles and footnotes
/                   code to be enacted before any output is produced.
/ extmacro          External macro to call (no % sign) and will typically be
/                   used to include extra stats values to add to the report.
/ odstfmacro        Name of macro (no % sign) containing titles and footnotes
/                   code to be enacted before any ODS non-listing output is
/                   produced by the %unicatrep macro. If not used then the macro
/                   defined to tfmacro= will be in effect.
/ statstfmacro      Name of macro (no % sign) containing titles and footnotes
/                   code to be enacted for statistical procedure output when
/                   calculating p-values. Note that these titles and footnotes
/                   will remain in effect for normal output unless you define a
/                   titles and footnotes macro to tfmacro= .
/ byrowvar          This is for when you want to show a "by" variable as a row
/                   following the variable you are analyzing.
/ byroword          Ordering variable for byrowvar if needed
/ byrowlabel        Label for byrowvar
/ byrowalign        Alignment of byrow (left/center/right)
/ byrowfmt          Format for byrow variable
/ byroww            Width for byrowvar
/ byrow2var         Second byrow variable
/ byrow2ord         Second byrow ordering variable if needed
/ byrow2label       Second byrow label
/ byrow2align       Second byrow alignment (left/center/right)
/ byrow2fmt         Second byrow format
/ byrow2w           Width for byrow2var
/ pluggaps=yes      By default, plug missing counts for categories and their
/                   percentages with zeroes and do the same for numeric counts.
/                   Set to "no" (no quotes) if you do not want this action to
/                   be taken.
/ nbspaces=no       By default, do not translate normal spaces to non-breaking
/                   spaces. Setting it to "yes" (no quotes) can be useful for
/                   maintaining alignment and forcing excel to treat cell
/                   contents as text. This will be applied to stats output only.
/                   To apply to other variables, use filtercode= and translate
/                   spaces to "A0"x in the code you supply.
/ compskip=yes      (no quotes) By default, throw a blank line after a variable
/                   for ODS reports. For ascii output, compskip=no will always
/                   be in effect.
/ compskippos=after (no quotes) By default, throw the skip line after a
/                   variable.
/ byrowfirst=no     (no quotes) Default is not to display the variable declared
/                   to byrowvar= as the first column when %unicatrep called.
/ mincolw           Minimum width of the treatment columns. If you are using
/                   paired stats then you can set this to a value to avoid
/                   truncation.
/ trtvarlist        You should not need to use this except in special situations
/                   where you want to specify labels to go with the transposed
/                   treatment variables in the proc report call at the end of
/                   the %unicatrep macro such as in this example:
/              trtvarlist=("__ DRUG 1 __" TRT1 TRT2) ("__ DRUG 2 __" TRT3 TRT4)
/                   You need to know what treatment variables there are and
/                   this will be put in the log by the %popfmt macro. If you
/                   are specifying column widths (usually not required) then if
/                   you change the natural order of these TRT variables then the
/                   trtw(n)= value that acts on a variable is the one that you
/                   would use if the natural order had not been changed.
/ odstrtvarlist     This works like trtvarlist= but is for ODS output where you
/                   need something different such as special underlines. If you
/                   do not set this then trtvarlist= remains in effect for ODS
/                   output if you have given it a value.
/ dsdenom           Dataset to use for the denominator for calculating
/                   percentages. Setting this overrides the pctcalc= process.
/                   The denominator value must be held in the variable _total.
/                   The sort order of this dataset will be used for the merge
/                   but if no sort order is known then a matching of variable
/                   names will be done. Note that if you have "by" variables
/                   then these should normally be in this dataset as well.
/ denomshow=yes     By default, show the denominator value (ddd) held in the
/                   dsdenom dataset as part of the display string. The digits
/                   will be trimmed and will have one space on each side. A
/                   slash will precede it as shown below.
/                   nnn / ddd (pct)
/ addnpct=no        By default, do not add a string to the end of a categorical
/                   variable label that indicates that the statistics are of the
/                   "n (%)" type. Note that if all the variables are categorical
/                   variables it is best to signify this in a title or add it
/                   using the freesuff= parameter of the %popfmt macro.
/ addnpctstr=", n (%)"    (quoted) String to add to the trimmed end of a
/                   categorical variable label to indicate that the statistics
/                   are of the "n (%)" type.
/ filtercode        SAS code you specify to drop observations and do minor
/                   reformatting before %unicatrep is called. If this code
/                   contains commas then enclose in quotes (the quotes will be
/                   dropped from the start and end before the code is executed).
/                   Using this parameter might be easier than deferring the call
/                   to %unicatrep and editing the dataset before calling
/                   %unicatrep. You can have multiple lines of sas code if you
/                   end each line with a semicolon. For serious editing you
/                   should do this in a macro defined to extmacro= .
/                   ============================================================
/                   Note that the following parameters apply to ODS output only
/ spanrows=yes      Applies to sas v9.2 and later. Default is to enable the
/                   "spanrows" option for "proc report". You should leave this
/                   set to "yes" (no quotes) unless you have a clear need.
/                   ============================================================
/                   Note that giving incorrect parameter values to fonts or any
/                   other values used in a style() statement in proc report can
/                   result in extremely confusing log error messages, usually
/                   shown as a missing round bracket sign as explained here.
/                     ERROR 79-322: Expecting a (.
/                     ERROR 76-322: Syntax error, statement will be ignored.
/                   http://support.sas.com/kb/2/457.html
/                   There is nothing wrong with this macro if this happens. You
/                   just need to get your values right. Whatever style()
/                   statement causes an error message is the one that contains
/                   an incorrect value. Check in the SAS documentation for the
/                   values you are allowed to use. It won't be font weight or
/                   style causing the problem as correct values for these are
/                   enforced by this macro.
/ font_face_stats=arial   Font to use for ODS output of the calculated stats
/                   values. For correct alignment of the decimal point for non-
/                   paired stats for MS Office then this should be set to
/                   "Courier" (no quotes) and you should set odsdpalign=yes.
/                   If your font face contains more than one word then use
/                   quotes (e.g. "courier new"). Also use quotes if you are
/                   specifying a search order for fonts such as
/                   "arial, helvetica".
/ font_weight_stats=medium    Weight of font to use for stats columns
/                   (choice of light, medium or bold enforced by this macro).
/ font_weight_other=medium    Weight of font to use for columns other than
/                   the calculated stats.
/ font_face_other=times     Font to use for ODS output for columns other
/                   than the calculated stats.
/ font_style_other=roman    Font style (italic, roman or slant) to use for ODS
/                   output for columns other than the calculated stats.
/ font_weight_other=medium    Weight of font to use for columns other than
/                   the calculated stats (choice of light, medium or bold).
/ report_border=no  Whether to draw a border around the report
/ header_border=no  Whether to draw a border around the column headers
/ column_border=no  Whether to draw a border around the cells in the report
/ lines_border=no   Whether to draw a border around the computed lines in the
/                   report.
/ rules=none        Ruler lines to use in the report must be set to one of the
/                   following: none, all, cols, rows, groups.
/ cellspacing=0     Spacing between cells
/ cellpadding=0     Padding between cells
/ outputwidthpct=calc    Integer percentage of the ODS output width to use.
/                   Default is "calc" (no quotes) for the %unistats macro to
/                   calculate a suitable value itself (ReportWidth*2/3).
/                   Set to null (nothing) for ODS to do automatic sizing. This
/                   won't look nice as there will be insufficient space between
/                   columns with the default cellspacing=0. Set to whatever
/                   integer percentage you like, otherwise. If this is set to
/                   anything other than null then the column widths for ascii
/                   reports are used to calculate percentages for individual
/                   columns (if these are available).
/                   ============================================================
/                   Colors for the different parts of the table
/ background_header=white
/ foreground_header=black
/ background_stats=white
/ foreground_stats=black
/ background_other=white
/ foreground_other=black
/                   ============================================================
/                   Whether to draw underlines (_ul) or overlines (_ol) for
/                   different parts of the report.
/ header_ul=yes
/ report_ul=yes
/ report_ol=yes
/ linepx=1          Width of drawn line in pixels
/ linecol=black     Color of drawn line
/ compskip_ul=no    Default is not to underline the compskip extra lines
/ compskippx=1      Width in pixels of the compskip underlines
/ compskipcol=black   Color of the compskip underlines
/                   ============================================================
/                   Note that you can insert code for the following two
/                   parameters that will apply immediately before and
/                   immediately after the "proc report" step for when you are
/                   calling %unicatrep. ENCLOSE YOUR CODE IN SINGLE QUOTES.
/                   Enclosed SINGLE quotes will be removed by the macro before
/                   code execution. Note that you are responsible for including
/                   all semicolons and "run" statements required for correct
/                   code syntax.
/ odsprerepcode     Code to execute immediately before the "proc report" step
/                   for ODS non-listing output (enclose in single quotes).
/ odspostrepcode    Code to execute immediately after the "proc report" step
/                   for ODS non-listing output (enclose in single quotes).
/ dsparam           Name of parameter dataset. This can EITHER be a "flat"
/                   dataset with variable names matching parameter names OR a
/                   Name-Value pair "tall" dataset (both Name and Value must be
/                   character variables and be called "Name" and "Value" in the
/                   input dataset) with the contents of Name matching a parameter
/                   name and Value its value. "Tall" datasets are suited to the
/                   metadata-driven use of this macro. In both cases, variables
/                   should be character variables. Numeric values can be used
/                   but they must be supplied as characters. Note that parameter
/                   values that are normally supplied in quotes such as 'Courier'
/                   must be enclosed in extra quotes such as Value="'Courier'"
/                   when building the parameter dataset.
/
/                   You can use dataset modifiers when specifying the input
/                   dataset and these modifiers will be applied to create the
/                   internal work dataset "_dsparam". Do not call your parameter
/                   dataset "_dsparam" as this is reserved for use inside this
/                   macro and will be deleted.
/
/ listallparams=no  By default, do not list all the parameters and their values
/                   that this macro has put into effect. Parameter dataset
/                   settings are always listed. Note that parameter values are
/                   often abbreviated to upper case first character inside this
/                   macro such as "no" becoming "N" and "yes" becoming "Y".
/ msgs=yes          By default, write useful information messages to the log
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  12Jul05         v1.1 - parameters spantotal, breakvar, breakpos and
/                      pageline2-5 added.
/ rrb  13Jul05         v2.0 allcatvars= and allcat= parameters added so that all
/                      categories belonging to a format are displayed for these
/                      variables.
/ rrb  09Jan06         v3.0 ability to adjust decimal places for numeric
/                      variables added and numeric p-values have a _statord
/                      value corresponding to the _statord of the MEAN.
/ rrb  24Jan06         Parameters nparvarlist=, chisqvarlist=, fishervarlist=
/                      added to define type of p-value to calculate for listed
/                      variables and pvatrtrlist= added so that treatment arm
/                      values for the p-value calculation can be specified.
/ rrb  25Jan06         Global macro variables _pvalue1_ etc. set up to contain
/                      pvalues.
/ rrb  30Jan06         lowcasevarlist= added and additional "m" allowed in
/                      decimal places adjust to make min amd max the same format
/                      as mean.
/ rrb  03Feb06         Default trtvar=
/ rrb  04May06 RRB001  Make pvartrtlist= default setting dependent on whether
/                      statvarlist is set and put note in for trtfmt= to say it
/                      must be set if %popfmt not called.
/ rrb  04May06         Only plug gaps with zeroes if treatment arm population
/                      not zero.
/ rrb  04May06         Logic of plugging gaps with zeroes altered to use local
/                      macro variable "plug".
/ rrb  07Jul06         Bug fix for catn=N processing plus some header tidies
/ rrb  10Jul06         misspct=yes bug fixed.
/ rrb  11Jul06 RRB002  _statord=1 set to get pvalues to merge with other data.
/ rrb  14Jul06         More header tidies
/ rrb  22Jul06         Do not lowercase _statlabel if set to "&misstxt"
/ rrb  26Aug06         v 3.1 has nopctcatlist= added so that no percentages are
/                      calculated for these categories nor p-values.
/ rrb  23Sep06         v 3.2 has pvalmisstxt=" n/a" added
/ rrb  09Oct06 RRB003  Problem with missing fmtord. format fixed and minor
/                      change to definition of p63val format.
/ rrb  13Feb07         "macro called" message added
/ rrb  12Mar07         Default now pctcalc=pop rather than pctcalc=cat (v3.3)
/ rrb  19Mar07         Add dpalign=yes parameter so that this action can be
/                      disabled if required.
/ rrb  20Mar07         Handling of character trtvar corrected (v3.5)
/ rrb  21Mar07         Add STDMEAN handling and fix pvalue merge bug for
/                      categorical variables (v3.6)
/ rrb  23Mar07         catnfmt= parameter can now have a format longer than
/                      three characters (v4.0)
/ rrb  24Mar07         Use "A0"x instead of "FE"x for the decimal point
/                      alignment character (v4.1)
/ rrb  25Mar07         _strlen_ set up to keep the string length for transposed
/                      treatment variables for %unicatrep deferred calls (v4.2)
/ rrb  02May07         pctsign=no parameter added to allow users to force the
/                      display of the percent sign for category percentages if
/                      required.
/ rrb  16May07         pctfmt=5.1 parameter added to allow users to change the
/                      percent format.
/ rrb  17May07         Further checking of pctfmt= value added (v4.5)
/ rrb  28May07         Allow the variable list to have variable labels attached
/                      in the form var1="variable one" and apply these labels
/                      to the output dataset. If followed by /n then the
/                      variable will be treated as numeric for numeric
/                      variables with a user format applied (v4.6)
/ rrb  30Jul07         Header tidy
/ rrb  01Sep07         pctwarn=yes parameter added
/ rrb  16Sep07         Added out= parameter to name the kept dataset created by
/                      proc report to pass through to the %unicatrep macro, if
/                      called.
/ rrb  16Sep07         wordtabdest= and wordtabdlim= parameters added
/ rrb  18Sep07         unicatstyle= , varw= and odsrtf= parameters added
/ rrb  19Sep07         odshtml= and odspdf= parameters added
/ rrb  21Sep07         odsother= parameter added
/ rrb  23Sep07         Header tidy
/ rrb  24Sep07         tfmacro= and pvalues=yes parameters added
/ rrb  30Sep07         topline=no is now the default which is better suited to
/                      ODS output.
/ rrb  30Dec07         Delete _unidsin dataset just before creating new one and
/                      fixed bug with _popfmt_ incorrectly assigned as a label
/                      when trtfmt= set to otherwise.
/ rrb  30Dec07         Use nfmt as a format for the NMISS statistic
/ rrb  31Dec07         Mapping of statistic labels to keywords and formats is
/                      displayed in log as a "note" statement. Keywords that
/                      start with "STD" will have the stdfmt= format applied.
/ rrb  31Dec07         Bug fixed with NMISS format when decimal points adjusted
/ rrb  05Jan08         Decimal point alignment bug in "fillstr:" routine fixed
/ rrb  06Jan08         New parameters glmadjcntrvar= and statsopdest= added for pass
/                      through to %unipvals for adjustment for centre effects.
/ rrb  06Jan08         Added errortype= , modelform= and dsmodelanova= for
/                      pass-through to %unipvals for adjustment for centre
/                      effects.
/ rrb  07Jan08         hovwarn=, hovcond=, hovtest= amd welch= added for pass-
/                      through to %unipvals to test and warn for homogeneity of
/                      variances significant difference for one-way ANOVA and to
/                      calculate using Welch test. welchid=§ added in this macro
/                      to give a symbol to a Welch p-value.
/ rrb  08Jan08         Added cntrwarn=, cntrcond= and cntrerrtype= for pass-
/                      through to %unipvals for centre effect warning.
/ rrb  08Jan08         cntrerrtype= removed. cntrcond= value changed and
/                      intercond=0.1 added.
/ rrb  13Jan08         dsmodelanova= dataset now deleted using proc datasets.
/                      ftestid= replaced by anovaid=. cntrwarn= processing
/                      changed.
/ rrb  13Jan08         Added cmhid= and support for the CMH test
/ rrb  14Jan08         glmclass=, glmmodel=, glmmeans= and glmweight= added so
/                      the user can override the statements generated by the
/                      %unipvals macro for the main glm call.
/ rrb  19Jan08         Added a note on use of glm*= parameters
/ rrb  19Jan08         Keep all variables in input dataset and pass all
/                      variables to %unipvals.
/ rrb  20Jan08         Decimal places adjusted for a number of statistics
/                      keywords.
/ rrb  26Jan08         Bug fixed with character format being like $3. in %cat
/ rrb  02Feb08         v5.0 allows for paired stats= words like "Mean(SD)" and
/                      enhances the catn= value so that the number of missing
/                      values can be shown. trtlabel= now defaults to null.
/                      pvalids=yes added to allow suppression of all p-value ids
/                      in the output. odshtmlcss= and odscsv= parameters added.
/                      print=yes parameter added for pass-through to %unicatrep.
/                      pluggaps= parameter added. byrow*= and compskip=
/                      parameters added for pass-through to %unicatrep.
/                      nbspaces= added to allow all spaces to be changed to non-
/                      breaking spaces so that html output does not drop leading
/                      spaces and convert multiple spaces to single spaces.
/ rrb  03Feb08         More byrow*= parameters added
/ rrb  09Feb08         compskip=no is now the default plus explanation of how to
/                      increase column length for when paired stats are used has
/                      been added to the header.
/ rrb  10Feb08         mincolw= parameter added
/ rrb  15Feb08         "^" now translated into a space when used in a delimiter
/                      for paired stats. A space no longer automatically added
/                      before a "(" and after a ";".
/ rrb  17Feb08         Added comments in header for page1vars= etc. parameters
/ rrb  23Feb08         byvars= generated where this is null but byrow*=
/                      parameters used.
/ rrb  24Feb08         Numeric pvalue stat defined to npvalstat= is merged on
/                      the first stat of a paired stat.
/ rrb  11Mar08         misspct= explanation updated in header
/ rrb  13Mar08         Mispelling of SKEWNESS corrected in code
/ rrb  15Mar08         odslisting= parameter added
/ rrb  17Mar08         byrowfirst= parameter added and breakvar= and breakpos=
/                      parameters removed.
/ rrb  19Mar08         trtvarlist= parameter added
/ rrb  20Mar08         Where paired stats are both missing then show as blank
/                      and not show delimiters.
/ rrb  25Mar08         If first of paired stats is "N" and this is missing but
/                      second of pair is not missing then show "N" as "0".
/ rrb  25Mar08         For variables defined with a negative adjustment for
/                      decimal places then the processing has changed such
/                      that the min, max and sum can show zero decimal points in
/                      addition to the variables that are counts (N, NMISS etc.)
/                      but all other statistics must show at least one decimal
/                      point.
/ rrb  30Apr08         dsdenom= and denomshow= parameters added and glmopdest=
/                      replaced by statsopdest= .
/ rrb  07May08         filtercode= parameter added
/ rrb  09May08         font_face_stats= and font_face_other= parameter added
/ rrb  09May08         report_border=, header_border=, column_border=, rules=
/                      cellspacing= and lines_border= parameters added.
/ rrb  11May08         compskippos=, cellpadding= and outputwidthpct= parameters
/                      added.
/ rrb  11May08         foreground and background parameters added
/ rrb  12May08         _ul and _ol parameters added
/ rrb  12May08         byvars2= parameter added for %unipvals call
/ rrb  13May08         font_style_other= and font_weight_stats parameters added
/ rrb  14May08         font_weight_stats= default changed to bold and
/                      outputwidthpct= default changed to calc.
/ rrb  18May08         compskip_ul= compskippx= compskipcol= parameters added
/ rrb  21May08         addnpct= and addnpctstr= parameters added
/ rrb  02Jun08         spanrows= parameter added
/ rrb  03Aug08         Changed default to font_weight_stats=medium plus header
/                      tidy.
/ rrb  12Oct08         _varlabel length increased to 256 for v6.14
/  JK  03Mar09         glmlsmeans= and odstblname= parameters added
/ rrb  05Mar09         Global macro variables for p-values: _pvalue1_, _pvalue2_
/                      etc. only set up when byvars=, byrowvar= and byrow2var=
/                      are all null. Problem with _pvalstr uninitialized message
/                      resolved (v6.16)
/ rrb  01Jun09         prerepcode= and postrepcode= parameters added plus header
/                      tidy for v6.17.
/ rrb  18Jun09         tfmacro= parameter value now passed to %unicatrep if
/                      called plus header tidy for v6.18
/ rrb  22Jun09         prerepcode= and postrepcode= parameters renamed to
/                      odsprerepcode= and odspostrepcode= and default now
/                      topline=yes (v6.19)
/ rrb  04Jul09         New parameter odstrtlabel= added (v6.20)
/  JK  06Jul09         pass-through misspct to %unipvals to consider correct
/                      calculation of p-values for Fisher- and Chi-square test
/                      (v6.21)
/ rrb  11Jul09         odstfmacro= parameter added (v6.22)
/ rrb  12Jul09         dsparam= parameter added (v6.23)
/ rrb  13Jul09         listallparams= parameter added plus parameter dataset
/                      handling changed slightly (v6.24)
/ rrb  02Aug09         Parameter pvalcolw=8 added (v6.25)
/ rrb  23Aug09         statsopdest= processing changed to ODS style and done
/                      inside of %unistats instead of being passed through to
/                      %unipvals (v6.26)
/ rrb  27Aug09         statstfmacro= and odstrtvarlist= parameters added.
/                      compskip=yes is now the default (for ascii output
/                      compskip=no is enforced) (v6.27)
/ rrb  30Aug09         odsescapechar= parameter added plus header tidy (v6.28)
/ rrb  10Sep09         %unquote() used with %qdequote() for filtercode (v6.29)
/ rrb  12Oct09         Calls to %dequote changed to calls to %qdequote due to
/                      macro renaming (v6.30)
/ rrb  03Nov09         Page throws now done using <p> or <pg> in the variable
/                      list to indicate the place for a page throw. Use of
/                      page1vars-page9vars to control paging now discontinued
/                      and the parameters deleted (v6.31)
/ rrb  04Nov09         Default font weights are now all "medium". Default stats
/                      font changed from Courier to Arial. odsdpalign=no
/                      parameter added such that by default, non-listing ODS
/                      output does not have the decimal point aligned in columns
/                      (v6.32)
/ rrb  07Nov09         pageon= parameter added (v6.33)
/ rrb  23Jan10         Font face for statistics now Times by default (v6.34)
/ rrb  24Jan10         Header tidy for compskip= documentation
/ rrb  01Nov10         statvalues=no parameter added (by default do not show
/                      stats values with p-values). This statistics value is a
/                      regulatory requirement for China's SFDA (v6.35)
/ rrb  07Nov10         Keywords LCLMnn, UCLMnn, LCLnn, UCLnn allowed where n is
/                      75, 90, 95 or 99 and LCLM, UCLM are the confidence limits
/                      of the mean and LCL, UCL are the confidence limits of the
/                      spread of values (you must have also selected "N", "MEAN"
/                      and "STD" for this to work). Odsescapechar= changed
/                      to odsescapechar="°". probfmt= parameter added for
/                      probability values from proc univariate (v6.36)
/ rrb  09Nov10         Bug with paired confidence stats delimiters fixed (v6.37)
/ rrb  16Nov10         extmacro= parameter added for the manipulation of the
/                      output dataset before %unicatrep is called. This will
/                      take effect after the filtercode= parameter and just
/                      before %unicatrep is called. tfmacro= should from now on
/                      only be used for titles and footnotes (v6.38)
/ rrb  06Feb11         allcat=yes is now the default so that all categories
/                      defined in a format are by default shown (v7.1)
/ rrb  13Mar11         Further major changes made to handling statistics.
/                      Statistics columns are now named STAT1, STAT2 etc. and a
/                      number of parameters have been added or renamed. This
/                      macro is no longer public domain software (v8.0)
/ rrb  19Mar11         freqsept(1-20)= parameters added (v8.1)
/ rrb  28Mar11         pvalfmt= and statvalfmt= now passed to %unipvals (v8.2)
/ rrb  08May11         Code tidy
/ rrb  16May11         unicatrep=no replaced by print=yes so that this macro by
/                      default uses %unicatrep for printing. This is opposite to
/                      the way this macro worked before since it was assumed
/                      this macro was going to be used to create an output
/                      dataset in most cases. But now this macro can handle most
/                      reporting needs so it is better to print by default. A 
/                      major change so main version number is incremented. Some
/                      "code tidy" damage was also fixed (v9.0)
/ rrb  17May11         Name-Value pair datasets allowed as parameter datasets
/                      in addition to "flat" parameter datasets (v9.1)
/ rrb  23May11         Double declare of print=yes,print=yes fixed (v9.2)
/ rrb  24May11         msglevel=N parameter added (v9.3)
/ rrb  25May11         pageline= and endline= parameters extended to 15 (was 9)
/                      and pagemacro= and endmacro= parameters added (v9.4)
/ rrb  08Jun11         Add call to %unistatlabel (v9.5)
/ rrb  09Jun11         Added statlabelmacro=unistatlabel parameter (v9.6)
/ rrb  12Jul11         Added trtalign= parameter (v9.7)
/ rrb  23Jul11         spacing= and trtsp1-15= parameters added (v9.8)
/ rrb  26Jul11         Limit for trtw= and trtsp= parameters increased from
/                      15 to 19 (v9.9)
/ rrb  28Aug11         Change default descstats= plus bug fixed with adjustment
/                      of decimal places (v9.10)
/ rrb  15Sep11         nodata=nodata parameter added (v9.11)
/ rrb  17Sep11         nodata= processing passed to %unicatrep (v9.12)
/ rrb  23Sep11         Header tidy
/ rrb  27Sep11         Redocumentation of freqsept= and glmquad= parameters
/                      since the "statno" segment now allows you to specify a
/                      treatment arm variable.
/ rrb  27Sep11         Variable length of 30 used instead of &strlen (v9.13)
/ rrb  01Oct11         Tidied up description of glmquad= and freqsept=
/ rrb  10Oct11         "glm" prefix dropped from glm parameters since a
/                      different procedure can be defined to modelproc= (v10.0)
/ rrb  05Nov11         usettest=, sattcond=, ttestid= and sattid= parameters
/                      added for "proc ttest" and the Satterthwaite
/                      approximation (v10.1)
/ rrb  16Nov11         Fixed p63val format definition (v10.2)
/ rrb  04Dec11         _unidsin dataset deletion added at end plus display of a
/                      few global macro variables set up (v10.3)
/ rrb  29Dec11         dstranstattrt= and dpvar= processing added for use when
/                      transposing by statistic keyword (+ treatment arm).
/                      Character variables (name ending in STR) corresponding to
/                      the numeric variables are also created where the number
/                      of decimal places can be optionally adjusted using the
/                      contents of the dpvar= variable (v11.0)
/ rrb  30Dec11         msglevel= processing changed (v11.1)
/ rrb  02Jan12         leftstr= processing added plus decimal point adjustment
/                      no longer applied to _statname="N" (v11.2)
/ rrb  03Jan12         _trtvallist_ used instead of _trtinlist_ and trtvallist=
/                      added as a parameter (that defaults to the contents of
/                      _trtvallist_) (v11.3)
/ rrb  10Jan12         padmiss= and msgs= processing added (v11.4)
/ rrb  20Jan12         Values are rounded to the tenth decimal place when the
/                      format is applied to create the character variable
/                      equivalent (which ends in STR) (v11.5)
/ rrb  26Jan12         plugtran= processing added that can act on the
/                      dstranstattrt= dataset to plug blank strings (v11.6)
/ rrb  20Jul12         Internally defined macro names now start with "_uni" and
/                      all macros matching that pattern are deleted from 
/                      work.sasmacr at macro close using %delmac (v11.7)
/ rrb  14Sep14         Use of "keyword" dropped for boolean options (v11.8)
/ rrb  29May15         Header description of dsin= parameter updated.
/ rrb  07Jun15         Header description of descstats= parameter updated.
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: unistats v11.8;

%macro unistats(dsin=,
            msglevel=X,
             varlist=,
              pageon=,
            usettest=no,
            sattcond=<0.1,
         statvarlist=,
      statlabelmacro=unistatlabel,
         statsopdest=,
           showstat0=no,
           showstat1=yes,
           npvalstat=MEAN,
            stat0lbl="Value",
            stat1lbl="p-value",
            stat2lbl=" ",
            stat3lbl=" ",
            stat4lbl=" ",
            stat5lbl=" ",
            stat6lbl=" ",
            stat7lbl=" ",
            stat8lbl=" ",
            stat9lbl=" ",
              stat0w=6,
              stat1w=8,
              stat2w=8,
              stat3w=8,
              stat4w=8,
              stat5w=8,
              stat6w=8,
              stat7w=8,
              stat8w=8,
              stat9w=8,
           statalign=,
          stat0align=,
          stat1align=,
          stat2align=,
          stat3align=,
          stat4align=,
          stat5align=,
          stat6align=,
          stat7align=,
          stat8align=,
          stat9align=,
        exactvarlist=,
        chisqvarlist=,
       fishervarlist=,
      chifishvarlist=,
         nparvarlist=,
      statvaltrtlist=,
           modelproc=GLM,
           errortype=3,
           modelform=short,
        dsmodelanova=,
             hovwarn=yes,
             hovcond=LE 0.05,
             hovtest=Levene,
               welch=no,
               class=,
               model=,
               means=,
             lsmeans=,
           odstables=,
               quad1=,
               quad2=,
               quad3=,
               quad4=,
               quad5=,
               quad6=,
               quad7=,
               quad8=,
               quad9=,
              weight=,
          adjcntrvar=,
            cntrwarn=yes,
            cntrcond=LE 0.05,
           intercond=LE 0.1,
             anovaid=#,
             ttestid=#,
             welchid=&,
              sattid=&,
           descstats=N Mean S.D. Median Minimum Maximum,
              trtvar=,
              trtfmt=,
          trtvallist=,
               total=no,
              byvars=,
               dsout=_unistats,
              dspout=_pvalues,
           dstrantrt=,
          dstranstat=,
       dstranstattrt=,
            plugtran=no,
               print=yes,
         unicatstyle=1,
                varw=12,
          unistatrep=no,
           spantotal=yes,
            tranpref=TRT,
             missing=yes,
             misstxt=Not Recorded,
             misspct=no,
        nopctcatlist=,
                catn=,
           varordadd=0,
             catnfmt=3.,
                nfmt=3.,
              stdfmt=6.2,
              minfmt=5.1,
              maxfmt=5.1,
             meanfmt=5.1,
              pctfmt=5.1,
             probfmt=p73val.,
          statvalfmt=6.2,
               dpvar=,
             leftstr=no,
             padmiss=no,
             pvalfmt=p63val.,
         pvalmisstxt=" n/a",
             pvalids=yes,
            fisherid=^,
             chisqid=~,
               cmhid=$,
              nparid=§,
              nodata=nodata,
            catlabel=" ",
            varlabel=" ",
                catw=,
       odsescapechar="°",
            trtlabel=,
         odstrtlabel=,
             spacing=2,
             topline=yes,
            pageline=no,
           pageline1=,
           pageline2=,
           pageline3=,
           pageline4=,
           pageline5=,
           pageline6=,
           pageline7=,
           pageline8=,
           pageline9=,
          pageline10=,
          pageline11=,
          pageline12=,
          pageline13=,
          pageline14=,
          pageline15=,
           pagemacro=,
             endline=no,
            endline1=,
            endline2=,
            endline3=,
            endline4=,
            endline5=,
            endline6=,
            endline7=,
            endline8=,
            endline9=,
           endline10=,
           endline11=,
           endline12=,
           endline13=,
           endline14=,
           endline15=,
            endmacro=,
            pgbrkpos=before,
            trtspace=4,
               trtw1=,
               trtw2=,
               trtw3=,
               trtw4=,
               trtw5=,
               trtw6=,
               trtw7=,
               trtw8=,
               trtw9=,
              trtw10=,
              trtw11=,
              trtw12=,
              trtw13=,
              trtw14=,
              trtw15=,
              trtw16=,
              trtw17=,
              trtw18=,
              trtw19=,
              trtsp1=,
              trtsp2=,
              trtsp3=,
              trtsp4=,
              trtsp5=,
              trtsp6=,
              trtsp7=,
              trtsp8=,
              trtsp9=,
             trtsp10=,
             trtsp11=,
             trtsp12=,
             trtsp13=,
             trtsp14=,
             trtsp15=,
             trtsp16=,
             trtsp17=,
             trtsp18=,
             trtsp19=,
            trtalign=c,
              indent=4,
               split=@,
             pctcalc=pop,
          allcatvars=,
              allcat=yes,
      lowcasevarlist=,
             dpalign=yes,
          odsdpalign=no,
             pctsign=no,
             pctwarn=yes,
                 out=,
         wordtabdest=,
         wordtabdlim=';',
              odsrtf=,
             odshtml=,
          odshtmlcss=,
              odscsv=,
              odspdf=,
          odslisting=,
            odsother=,
             tfmacro=,
            extmacro=,
          odstfmacro=,
        statstfmacro=,
            byrowvar=,
            byroword=,
          byrowlabel=" ",
          byrowalign=,
            byrowfmt=,
              byroww=,
           byrow2var=,
           byrow2ord=,
         byrow2label=" ",
         byrow2align=,
           byrow2fmt=,
             byrow2w=,
            pluggaps=yes,
            nbspaces=no,
            compskip=yes,
         compskippos=after,
          byrowfirst=no,
             mincolw=,
          trtvarlist=,
       odstrtvarlist=,
          filtercode=,
             dsdenom=,
           denomshow=yes,
             addnpct=no,
          addnpctstr=", n (%)",
            spanrows=yes,
     font_face_stats=times,
   font_weight_stats=medium,
     font_face_other=times,
    font_style_other=roman,
   font_weight_other=medium,
       report_border=no,
       header_border=no,
       column_border=no,
        lines_border=no,
               rules=none,
         cellspacing=0,
         cellpadding=0,
      outputwidthpct=calc,
   background_header=white,
   foreground_header=black,
    background_stats=white,
    foreground_stats=black,
    background_other=white,
    foreground_other=black,
           header_ul=yes,
           report_ul=yes,
           report_ol=yes,
              linepx=1,
             linecol=black,
         compskip_ul=no,
          compskippx=1,
         compskipcol=black,
       odsprerepcode=,
      odspostrepcode=,
             dsparam=,
       listallparams=no,
           freqsept1=,
           freqsept2=,
           freqsept3=,
           freqsept4=,
           freqsept5=,
           freqsept6=,
           freqsept7=,
           freqsept8=,
           freqsept9=,
          freqsept10=,
          freqsept11=,
          freqsept12=,
          freqsept13=,
          freqsept14=,
          freqsept15=,
          freqsept16=,
          freqsept17=,
          freqsept18=,
          freqsept19=,
          freqsept20=,
                msgs=yes
               );

  %local parmlist;

  %*- get a list of parameters for this macro -;
  %let parmlist=%mvarlist(unistats);

  %*- remove the macro variable name "parmlist" from this list -;
  %let parmlist=%removew(&parmlist,parmlist);


  %local i j err wrn errflag pg allvars var usefmtord fmt ls trtvartype libname
         memname plug trtformat statfmts stat dpadj minmaxadj lowcase varlist2
         usetest exact strlen pctnfmt varlist3 varlist4 varlist5 varlistx key val
         forcenum denomsortvars badvars asis cllist bit byvars2 savopts has0obs;

  %let errflag=0;
  %let err=ERR%str(OR);
  %let wrn=WAR%str(NING);

  %if not %length(&msglevel) %then %let msglevel=X;
  %let msglevel=%upcase(%substr(&msglevel,1,1));
  %if "&msglevel" NE "N" and "&msglevel" NE "I" %then %let msglevel=X;

  %let savopts=%sysfunc(getoption(msglevel,keyword)) %sysfunc(getoption(notes));

  %if "&msglevel" EQ "N" or "&msglevel" EQ "I" %then %do;
    options msglevel=&msglevel;
  %end;
  %else %do;
    options nonotes;
  %end;

  %let delodsdsets=;

  %let byvars2=_page _varord _vartype _varname _varlabel _dpadj _minmaxadj;


               /*-----------------------------------------*
                        Parameter dataset handling
                *-----------------------------------------*/

  %if %length(&dsparam) %then %do;

    *-- handle possible dataset modifiers --;
    data _dsparam;
      set &dsparam;
    run;
 
    %if %hasvarsc(_dsparam,name value) %then %do;
      *-- we have a Name-Value pair dataset so transpose it to a "flat" dataset --;
      proc transpose data=_dsparam(keep=name value) out=_dsparam(drop=_name_);
        var value;
        id name;
      run;
 
      %if %varnum(_dsparam,_label_) %then %do;
        *-- drop the _label_ --;
        data _dsparam,
          set _dsparam:
          drop _label_;
        run;
      %end;
    %end;

    %if %nlobs(_dsparam) NE 1 %then %do;
      %let errflag=1;
      %put &err: (unistats) The parameter dataset dsparam=&dsparam should have one;
      %put &err: (unistats) observation but this dataset has %nlobs(_dsparam) observations.;
      %put &err: (unistats) Checking of this dataset will continue but it can not be used.;
      %put;
    %end;

    %let varlist2=%varlistn(_dsparam);
    %if %length(&varlist2) %then %do;
      %let errflag=1;
      %put &err: (unistats) Numeric variables are not allowed in the parameter dataset ;
      %put &err: (unistats) dsparam=&dsparam but the following numeric variables exist:;
      %put &err: (unistats) &varlist2;
      %put;
    %end;

    %if %varnum(_dsparam,dsparam) %then %do;
      %let errflag=1;
      %put &err: (unistats) The variable DSPARAM is present in the parameter dataset;
      %put &err: (unistats) dsparam=&dsparam but use of this variable inside a;
      %put &err: (unistats) parameter dataset is not allowed.;
      %put;
    %end;

    proc contents noprint data=_dsparam out=_unicont(keep=name);
    run;

    data _null_;
      length badvars $ 2000;
      retain badvars ;
      set _unicont end=last;
      name=upcase(name);
      if name not in (%quotelst(&parmlist)) then badvars=trim(badvars)||" "||name;
      if last then call symput('badvars',trim(left(badvars)));
    run;

    %if %length(&badvars) %then %do;
      %let errflag=1;
      %put &err: (unistats) The following list of variables in dsparam=&dsparam;
      %put &err: (unistats) do not match any of the macro parameter names so the;
      %put &err: (unistats) parameter dataset will not be used:;
      %put &err: (unistats) &badvars;
      %put;
    %end;

    proc datasets nolist;
      delete _unicont;
    run;
    quit;

    %if &errflag %then %goto exit;

    *- the parameter dataset is good so call symput all the variables -;
    data _null_;
      set _dsparam;
      array _char {*} _character_;
      length __y $ 32;
      do __i=1 to dim(_char);
        __y=vname(_char(__i));
        call symput(__y,trim(left(_char(__i))));
      end;
    run;

    %let varlist2=%varlist(_dsparam);

    proc datasets nolist;
      delete _dsparam;
    run;
    quit;

    %put MSG: (unistats) The following macro parameters and their values were;
    %put MSG: (unistats) set as the result of use of the dsparam=&dsparam;
    %put MSG: (unistats) parameter dataset:;
    %mvarvalues(&varlist2);
    %put;

  %end;


               /*-----------------------------------------*
                    Check we have enough parameters set
                *-----------------------------------------*/


  %global _statkeys_ _strlen_;
  %let _statkeys_=;

  %global _misstxt_;
  %let _misstxt_=&misstxt;

  %*- we need this to get round the "BY-line truncated" bug in "proc univariate" -;
  %let ls=%sysfunc(getoption(linesize));

  %if not %length(&plugtran) %then %let plugtran=no;
  %let plugtran=%upcase(%substr(&plugtran,1,1));

  %if not %length(&trtvallist) %then %let trtvallist=&_trtvallist_;

  %if not %length(&leftstr) %then %let leftstr=no;
  %let leftstr=%upcase(%substr(&leftstr,1,1));
  %if not %length(&padmiss) %then %let padmiss=no;
  %let padmiss=%upcase(%substr(&padmiss,1,1));

  %if not %length(&listallparams) %then %let listallparams=no;
  %let listallparams=%upcase(%substr(&listallparams,1,1));

  %if not %length(&mincolw) %then %let mincolw=0;

  %if not %length(&addnpct) %then %let addnpct=no;
  %let addnpct=%upcase(%substr(&addnpct,1,1));

  %if %length(&dsdenom) %then %let denomsortvars=%sortedby(&dsdenom);

  %if not %length(&denomshow) %then %let denomshow=yes;
  %let denomshow=%upcase(%substr(&denomshow,1,1));

  %if not %length(&pluggaps) %then %let pluggaps=yes;
  %let pluggaps=%upcase(%substr(&pluggaps,1,1));

  %if not %length(&nbspaces) %then %let nbspaces=no;
  %let nbspaces=%upcase(%substr(&nbspaces,1,1));

  %if not %length(&pctsign) %then %let pctsign=no;
  %let pctsign=%upcase(%substr(&pctsign,1,1));

  %if not %length(&pctwarn) %then %let pctwarn=yes;
  %let pctwarn=%upcase(%substr(&pctwarn,1,1));

  %if "&pctwarn" EQ "N" %then %do;
    %put &wrn: (unistats) Percent > 100.01 checks disabled;
  %end;

  %if not %length(&pctfmt) %then %let pctfmt=5.1;
  %let pctnfmt=%substr(&pctfmt,%verifyb(&pctfmt,0123456789.)+1);


  %if not %length(&pctnfmt) or not %index(&pctnfmt,.) %then %do;
    %let errflag=1;
    %put &err: (unistats) Format supplied to pctfmt=&pctfmt not valid;
  %end;
  %else %if "%substr(&pctnfmt,1,1)" EQ "." %then %do;
    %let errflag=1;
    %put &err: (unistats) No format length supplied to pctfmt=&pctfmt;
  %end;


  %if not %length(&pctcalc) %then %let pctcalc=pop;
  %let pctcalc=%upcase(&pctcalc);

  %if "&pctcalc" NE "CAT" and "&pctcalc" NE "POP" %then %do;
    %let errflag=1;
    %put &err: (unistats) You have pctcalc=&pctcalc but only CAT or POP are allowed;
  %end;

  %if not %length(&print) %then %let print=yes;
  %let print=%upcase(%substr(&print,1,1));

  %if ("&print" EQ "Y" or %length(&wordtabdest))
    and not %length(&dstrantrt) %then %let dstrantrt=_unitran;

  %if "&unistatrep" EQ "Y" and not %length(&dstranstattrt) and not %length(&dstranstat) 
    %then %let dstrantrt=_unitranstat;

  %if not %length(&minfmt) %then %let minfmt=&maxfmt;

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (unistats) No input dataset assigned to dsin=;
  %end;

  %if not %length(&varlist) %then %do;
    %let errflag=1;
    %put &err: (unistats) No variable list assigned to varlist=;
  %end;
  %else %do;
    %*- set varlist3 to varlist but with labels and equals signs removed -;
    %let varlist3=%sysfunc(compress(%noquotes(%str(&varlist)),=));
    %*- set up varlist2 without decimal point adjust or page throws -;
    %let varlist2=;
    %do i=1 %to %words(&varlist3);
      %if %length(&statvarlist) %then %do;
        %global _pvalue&i._;
        %let _pvalue&i._=;
      %end;
      %let var=%scan(&varlist3,&i,%str( ));
      %if "%upcase(&var)" NE "<P>"
      and "%upcase(&var)" NE "<PG>" %then %do;
        %*- drop the decimal point modifier if there is one -;
        %let varlist2=&varlist2 %scan(&var,1,/);
      %end;
    %end;
  %end;
 

  %if not %length(&dsout) %then %do;
    %let errflag=1;
    %put &err: (unistats) No output dataset assigned to dsout=;
  %end;

  %if not %length(&trtvar) %then %do;
    %let trtvar=&_trtvar_;
    %put NOTE: (unistats) Defaulting trtvar=&trtvar;
    %put;
  %end;

  %if not %length(&total) %then %let total=no;
  %let total=%upcase(%substr(&total,1,1));

  %if not %length(&misstxt) %then %let misstxt=Not Recorded;

  %if not %length(&missing) %then %let missing=yes;
  %let missing=%upcase(%substr(&missing,1,1));

  %if not %length(&misspct) %then %let misspct=no;
  %let misspct=%upcase(%substr(&misspct,1,1));

  %if not %length(&allcat) %then %let allcat=yes;
  %let allcat=%upcase(%substr(&allcat,1,1));

  %if "&missing" EQ "N" %then %let misspct=N;

  %if not %length(&varordadd) %then %let varordadd=0;

  %if %length(&statvarlist) %then %do;  /* RRB001 */
    %if not %length(&statvaltrtlist) %then %let statvaltrtlist=ne &_trttotstr_;
    %else %let statvaltrtlist=in (&statvaltrtlist);
  %end;

  %if not %length(&trtfmt) %then %let trtfmt=&_popfmt_;

  %if not %length(&dpalign) %then %let dpalign=yes;
  %let dpalign=%upcase(%substr(&dpalign,1,1));
  %if not %length(&odsdpalign) %then %let odsdpalign=no;
  %let odsdpalign=%upcase(%substr(&odsdpalign,1,1));
  %let asis=on;
  %if &odsdpalign=N %then %let asis=off;




  %if &errflag %then %goto exit;

  %if not %length(&msgs) %then %let msgs=yes;
  %let msgs=%upcase(%substr(&msgs,1,1));

  %*- set varlist4 to varlist but with the labels removed -;
  %if %quotecnt(&varlist) %then %do;
    %let varlist4=%noquotes(%str(&varlist));
    %*- set varlist5 to the variables with labels defined -;
    %let varlist5=;
    %do i=1 %to %words(&varlist4);
      %let var=%scan(&varlist4,&i,%str( ));
      %let var=%scan(&var,1,/);
      %if "%substr(&var,%length(&var),1)" EQ "="
        %then %let varlist5=&varlist5 %substr(&var,1,%length(&var)-1);
    %end;
    %if %words(&varlist5) NE %quotecnt(&varlist) %then %do;
      %let errflag=1;
      %put &err: (unistats) Number of variable labels=%quotecnt(&varlist) does not;
      %put &err: (unistats) match with variable count with labels=%words(&varlist5);
      %put &err: (unistats) for varlist=&varlist;
    %end;
  %end;


  %*----- work out the category display length -----;
  %if not %length(&catnfmt) %then %let catnfmt=3.;
  %*- add 3 for the space and round brackets -;
  %let strlen=%eval(%scan(&catnfmt,1,.)+3);
  %*- add the length of the percent format -;
  %let strlen=%eval(&strlen+%scan(&pctnfmt,1,.));
  %*- if displaying percent sign then add 1 to the length -;
  %if "&pctsign" EQ "Y" %then %let strlen=%eval(&strlen+1);
  %*- if displaying denominator then add more -;
  %if %length(&dsdenom) and "&denomshow" EQ "Y"
    %then %let strlen=%eval(&strlen+%scan(&catnfmt,1,.)+3);
  %if &strlen LE &mincolw %then %let strlen=&mincolw;
  %let _strlen_=&strlen;


  %if "&listallparams" EQ "Y" %then %do;
    %put;
    %put MSG: (unistats) The complete list of macro parameters and their values;
    %put MSG: (unistats) that this macro has put into effect is as follows:;
    %mvarvalues(&parmlist);
    %put;
  %end;


  %*- make sure the ModelANOVA append dataset is deleted -;
  %if %length(&dsmodelanova) %then %do;
    %if %sysfunc(exist(&dsmodelanova)) %then %do;
      proc datasets nolist
        %if %index(&dsmodelanova,.) %then %do;
          lib=%scan(&dsmodelanova,1,.)
        %end;
        ;
        delete %scan(&dsmodelanova,-1,.);
      run;
      quit;
    %end;
  %end;


               /*-----------------------------------------*
                      Check stat labels map to keywords
                *-----------------------------------------*/

  %if %length(&descstats) %then %do;
    %let _statkeys_=%unimap(&descstats,msgs=&msgs);
    %if not %length(&_statkeys_) %then %goto exit;
    %if &msgs NE N %then %do;
      %put;
      %put MSG: (unistats) The following labels defined to descstats: &descstats;
      %put MSG: (unistats) were mapped to the following keywords: &_statkeys_;
    %end;
  %end;


               /*-----------------------------------------*
                    Pair stats keywords to their format
                *-----------------------------------------*/

  %let statfmts=;
  %if %length(&descstats) %then %do;
    %do i=1 %to %words(&_statkeys_);
      %let stat=%scan(&_statkeys_,&i,%str( ));
      %let statfmts=&statfmts &stat;
      %if "&stat" EQ "N" %then %let statfmts=&statfmts &nfmt;
      %else %if "&stat" EQ "NMISS" %then %let statfmts=&statfmts &nfmt;
      %else %if "&stat" EQ "NOBS" %then %let statfmts=&statfmts &nfmt;
      %else %if %index(&stat,STD) EQ 1 %then %let statfmts=&statfmts &stdfmt;
      %else %if "&stat" EQ "KURTOSIS" %then %let statfmts=&statfmts &stdfmt;
      %else %if "&stat" EQ "SKEWNESS" %then %let statfmts=&statfmts &stdfmt;
      %else %if "&stat" EQ "MIN" %then %let statfmts=&statfmts &minfmt;
      %else %if "&stat" EQ "MAX" %then %let statfmts=&statfmts &maxfmt;
      %else %if "&stat" EQ "SUM" %then %let statfmts=&statfmts &maxfmt;
      %else %if "%substr(&stat.XXX,1,4)" EQ "PROB" %then %let statfmts=&statfmts &probfmt;
      %else %let statfmts=&statfmts &meanfmt;
    %end;
    %if &msgs NE N %then %do;
      %put MSG: (unistats) and have been assigned formats as follows: &statfmts;
      %put MSG: (unistats) and a corresponding format $statfmt has been created.;
    %end;
    proc format;
      value $statfmt
      %do i=1 %to %words(&statfmts) %by 2;
        "%scan(&statfmts,&i,%str( ))" = "%scan(&statfmts,%eval(&i+1),%str( ))"
      %end;
      ;
    run;
  %end;


               /*-----------------------------------------*
                      Check all variables are present
                *-----------------------------------------*/

  %if not %length(&byvars) %then %let byvars=&byroword &byrowvar &byrow2ord &byrow2var;

  %let allvars=&trtvar &dpvar &byvars &adjcntrvar &varlist2;


  %*- delete _unidsin dataset if it exists -;
  %if %sysfunc(exist(_unidsin)) %then %do;
    proc datasets nolist;
      delete _unidsin;
    run;
    quit;
  %end;


  *- this data step in case input dataset has attached clauses -;
  data _unidsin;
    set &dsin;
    %if %length(&trtfmt) %then %do;
      format &trtvar &trtfmt ;
    %end;
  run;


  *- check for 0 obs -;
  %if %attrn(_unidsin,nobs) EQ 0 %then %do;
    %let has0obs=Y;
    *- set up _page to prevent a %unicatrep error -;
    data _unidsin;
      retain _page 0;
      set _unidsin;
    run;
    %let dstrantrt=_unidsin;
    %goto unicat;
  %end;


  %*- generate total for all treatment arms if requested -;
  %if "&total" EQ "Y" %then %do;
    data _unidsin;
      set _unidsin;
      output;
      &trtvar=&_trttotstr_;
      output;
    run;
  %end;


  %*- check all variables are in input dataset -;
  %do i=1 %to %words(&allvars);
    %let var=%scan(&allvars,&i,%str( ));
    %if not %varnum(_unidsin,&var) %then %do;
      %let errflag=1;
      %put &err: (unistats) Variable "&var" not in input dataset;
    %end;
  %end;

  %if &errflag %then %goto exit;


  %*- if any variables labels found then apply to dataset -;
  %if %quotecnt(&varlist) %then %do;
    *- can not use "proc datasets" due to weird label syntax -;
    data _unidsin;
      set _unidsin;
      label
      %do i=1 %to %words(&varlist5);
        %let var=%scan(&varlist5,&i,%str( ));
        &var=%unquote(%quotescan(%str(&varlist),&i))
      %end;
      ;
    run;
  %end;


  %*- store the treatment variable type (C/N) -;
  %let trtvartype=%vartype(_unidsin,&trtvar);

  %*- store the treatment format -;
  %let trtformat=%varfmt(_unidsin,&trtvar);



       /*===========================================================*
        *===========================================================*
               Define macro to process Categorical variables
        *===========================================================*
        *===========================================================*/

  %macro _unicat(var,varnum,page,lowcase);

    %local allfmtvals fmt varlen sortord vartype;

    %let vartype=%vartype(_unidsin,&var);
    %let allfmtvals=N;
    %if %index(%quotelst(%upcase(&allcatvars)),"%upcase(&var)")
        or "&allcat" EQ "Y" %then %let allfmtvals=Y;

    %let fmt=%varfmt(_unidsin,&var);
    %if not %length(%sysfunc(compress(&fmt,$1234567890.))) %then %do;
      %let fmt=;
      %let allfmtvals=N;
    %end;

    %let varlen=%varlen(_unidsin,&var,nodollar);

    %if "&vartype" EQ "C" %then %do;
      %if "%substr(&fmt%str(     ),1,5)" EQ "$CHAR"
       or not %length(%sysfunc(compress(&fmt,$123456789.)))
       %then %let usefmtord=0;
    %end;

    %if %length(&fmt) %then %do;
      %fmtord(&fmt);
    %end;

    data _unistatc;
      length _statname $ 160
             _varname $ 32
             _varlabel $ 256
             _dpadj $ 2
             _minmaxadj $ 1
             ;
      retain _page &page _varord %eval(&varnum+&varordadd)
             _vartype "C" _varname "&var" _dpadj " " _minmaxadj " ";
      set _unidsin;
      _varlabel=vlabel(&var);
      %if "&addnpct" EQ "Y" %then %do;
        _varlabel=trim(_varlabel)||&addnpctstr;
      %end;
      _fmt=vformat(&var);
      if _fmt ne ' ' then do;
        %if "&vartype" EQ "C" %then %do;
          if &var NE ' ' then _statname=putc(&var,_fmt);
          else _statname="&misstxt";
        %end;
        %else %do;
          if &var NE . then _statname=putn(&var,_fmt);
          else _statname="&misstxt";
        %end;
      end;
      else do;
        %if "&vartype" EQ "C" %then %do;
          _statname=&var;
        %end;
        %else %do;
          _statname=put(&var,best.-L);
        %end;
      end;
    run;


    %*- if this is one of the pvalue variables then process -;
    %if %index(%quotelst(%upcase(&statvarlist)),"%upcase(&var)") %then %do;
      data __pin;
        set _unistatc(where=(1=1
             %if "&missing" EQ "Y" and "&misspct" EQ "N" %then %do;
               and _statname not in ("&misstxt" &nopctcatlist)
             %end;
             ));
      run;
      %let usetest=;
      %if %index(%quotelst(%upcase(&chisqvarlist)),"%upcase(&var)")
        %then %let usetest=C;
      %else %if %index(%quotelst(%upcase(&fishervarlist)),"%upcase(&var)")
        %then %let usetest=F;
      %unipvals(dsin=__pin(where=(&trtvar &statvaltrtlist)),npvalstat=&npvalstat,
              dsout=__pout,trtvar=&trtvar,respvar=&var,type=C,usetest=&usetest,
              byvars=&byvars,byvars2=&byvars2,varname=&var,
              pvalfmt=&pvalfmt,statvalfmt=&statvalfmt,modelproc=&modelproc,
              freqsept1=&freqsept1,freqsept2=&freqsept2,freqsept3=&freqsept3,
              freqsept4=&freqsept4,freqsept5=&freqsept5,freqsept6=&freqsept6,
              freqsept7=&freqsept7,freqsept8=&freqsept8,freqsept9=&freqsept9,
              freqsept10=&freqsept10,freqsept11=&freqsept11,freqsept12=&freqsept12,
              freqsept13=&freqsept13,freqsept14=&freqsept14,freqsept15=&freqsept15,
              freqsept16=&freqsept16,freqsept17=&freqsept17,freqsept18=&freqsept18,
              freqsept19=&freqsept19,freqsept20=&freqsept20,
              misspct=&misspct,pvalids=&pvalids);

      %if %sysfunc(exist(&dspout)) %then %do;
        data &dspout;
          set &dspout __pout;
        run;
      %end;
      %else %do;
        data &dspout;
          set __pout;
        run;
      %end;

      proc datasets nolist;
        delete __pin __pout;
      run;
      quit;
    %end;


    *- count of non-missing values -;
    proc summary nway missing data=_unistatc
      %if "&misspct" EQ "N" %then %do;
        (where=(_statname not in ("&misstxt" &nopctcatlist)))
      %end;
      ;
      class &byvars &trtvar;
      id _page _varord _vartype _varname _varlabel;
      output out=_unistatt(drop=_type_ rename=(_freq_=_total));
    run;


    *- count of missing values -;
    proc summary nway missing data=_unistatc
      %if "&misspct" EQ "N" %then %do;
        (where=(_statname EQ "&misstxt"))
      %end;
      ;
      class &byvars &trtvar;
      id _page _varord _vartype _varname _varlabel;
      output out=_unistatm(drop=_type_ rename=(_freq_=_pct));
    run;


    %if &pctcalc EQ CAT %then %let sortord=&byvars &trtvar;
    %else %if &pctcalc EQ POP %then %let sortord=&trtvar &byvars;


    proc summary nway missing data=_unistatc;
      class &sortord _statname;
      id &byvars2;
      output out=_unistatc(drop=_type_ rename=(_freq_=_value));
    run;


    %if "&allfmtvals" EQ "Y" %then %do;

      %allfmtvals(var=&var,length=&varlen,fmt=&fmt,dsout=_uniallfmt,decodevar=_statname,decodelen=160)
      %zerogrid(dsout=_unizero,var1=&sortord &byvars2,
                ds1=_unistatc,var2=_statname,ds2=_uniallfmt,zerovar=_value)

      data _unistatc;
        merge _unizero _unistatc;
        by &sortord _statname;
      run;

      proc datasets nolist;
        delete _unizero _uniallfmt;
      run;
      quit;

    %end;



    %if %length(&dsdenom) %then %do;
      %if not %length(&denomsortvars) %then %do;
        %let denomsortvars=%match(%varlist(_unistatc),%varlist(&dsdenom));
        proc sort data=&dsdenom out=_unidenom;
          by &denomsortvars;
        run;
      %end;
      %else %do;
        data _unidenom;
          set &dsdenom;
        run;
      %end;
      proc sort data=_unistatc;
        by &denomsortvars;
      run;
    %end;



    data _unistatc;
      length _statlabel $ 160;
      retain _dummy 0;
      %if %length(&dsdenom) %then %do;
        merge _unidenom _unistatc;
        by &denomsortvars;
      %end;
      %else %if &pctcalc EQ CAT %then %do;
        merge _unistatt _unistatc;
        by &byvars &trtvar;
      %end;
      %else %if &pctcalc EQ POP %then %do;
        merge _popfmt _unistatc(in=_data);
        by &trtvar;
        if _data;
        format &trtvar &trtformat;
      %end;
      _statlabel=_statname;
      %if "&lowcase" EQ "Y" %then %do;
        if _statname NE "&misstxt" then
          _statlabel=substr(_statlabel,1,1)||lowcase(substr(_statlabel,2));
      %end;
      if _statname in ("&misstxt" &nopctcatlist) then do;
        if _statname EQ "&misstxt" then _statord=999;
        else do;
          %if %length(&fmt) %then %do;
            _statord=input(_statname,fmtord.);
          %end;
          %else %do;
            _statord=1; *- RRB003 -;
          %end;
        end;
        _pct=.;
        %if "&misspct" EQ "Y" %then %do;
          _pct=100*_value/_total;
          %if "&pctwarn" NE "N" %then %do;
          if _pct GT 100.01 then
            put "&wrn: (unistats) _pct GT 100.01 " (_all_) (=);
          %end;
        %end;
      end;
      else do;
        %if %length(&fmt) %then %do;
          _statord=input(_statname,fmtord.);
        %end;
        %else %do;
          _statord=1; *- RRB002 -;
        %end;
        if _total in (.,0) then _pct=.;
        else _pct=100*_value/_total;
        %if "&pctwarn" NE "N" %then %do;
        if _pct GT 100.01 then
          put "&wrn: (unistats) _pct GT 100.01 " (_all_) (=);
        %end;
      end;
    run;


    proc sort data=_unistatc;
      by &byvars &trtvar &byvars2 _statord _statname;
    run;

    %if %length(&catn) %then %do;
      *- merge the missing count with the total count -;
      data _unistatt;
        merge _unistatt _unistatm;
        by &byvars &trtvar _page _varord _vartype _varname _varlabel;
        if _total=. then _total=0;
        if _pct=. then _pct=0;
      run;
      data _unistatt;
        length _statlabel _statname $ 160 _dpadj $ 2 _minmaxadj $ 1;
        retain _statord 0.5  _statname "N" _statlabel "&catn" _total .
              _dummy 0 _vartype "C" _dpadj " " _minmaxadj " ";
        set _unistatt(rename=(_total=_value));
      run;

      proc append base=&dsout data=_unistatt;
      run;
    %end;

    proc append base=&dsout data=_unistatc
    %if "&missing" EQ "N" %then %do;
      (where=(_statname ne "&misstxt"))
    %end;
    ;
    run;

    proc datasets nolist;
      delete _unistatc _unistatt _unistatm;
    run;
    quit;

  %mend _unicat;



       /*===========================================================*
        *===========================================================*
                 Define macro to process NUMeric variables
        *===========================================================*
        *===========================================================*/

  %macro _uninum(var,varnum,page,dpadj,minmaxadj);
    %local i ;

    data _unistatn;
      length _varlabel $ 256
             _varname $ 32
             _dpadj $ 2
             _minmaxadj $ 1
             ;
      retain _page &page _varord %eval(&varnum+&varordadd) _vartype "N"
      _varname "&var" _dpadj "&dpadj" _minmaxadj "&minmaxadj";
      set _unidsin;
      _varlabel=vlabel(&var);
    run;


    %*- if this is one of the pvalue variables then process -;
    %if %index(%quotelst(%upcase(&statvarlist)),"%upcase(&var)") %then %do;
      data __pin;
        set _unistatn;
      run;
      %let usetest=;
      %if %index(%quotelst(%upcase(&nparvarlist)),"%upcase(&var)")
        %then %let usetest=N; %*- N=non-parametric test -;
      %if %index(%quotelst(%upcase(&exactvarlist)),"%upcase(&var)")
        %then %let exact=yes;
      %unipvals(dsin=__pin(where=(&trtvar &statvaltrtlist)),varname=&var,
              dsout=__pout,trtvar=&trtvar,respvar=&var,type=N,usetest=&usetest,
              pvalfmt=&pvalfmt,statvalfmt=&statvalfmt,modelproc=&modelproc,
              exact=&exact,adjcntrvar=&adjcntrvar,npvalstat=&npvalstat,
              errortype=&errortype,modelform=&modelform,dsmodelanova=&dsmodelanova,
              hovwarn=&hovwarn,hovcond=&hovcond,hovtest=&hovtest,welch=&welch,
              cntrwarn=&cntrwarn,cntrcond=&cntrcond,intercond=&intercond,
              class=&class,model=&model,means=&means,usettest=&usettest,
              ttestid=&ttestid,sattid=&sattid,
              lsmeans=&lsmeans,odstables=&odstables,weight=&weight,sattcond=&sattcond,
              quad1=&quad1,quad2=&quad2,quad3=&quad3,quad4=&quad4,
              quad5=&quad5,quad6=&quad6,quad7=&quad7,quad8=&quad8,
              quad9=&quad9,byvars=&byvars,byvars2=&byvars2,misspct=&misspct,
              pvalids=&pvalids);

      %if %sysfunc(exist(&dspout)) %then %do;
        data &dspout;
          set &dspout __pout;
        run;
      %end;
      %else %do;
        data &dspout;
          set __pout;
        run;
      %end;

      proc datasets nolist;
        delete __pin __pout;
      run;
      quit;
    %end;


    *- fix for "BYline truncated" bug is to set linesize to max -;
    options ls=max;

    proc univariate noprint data=_unistatn;
      by &byvars &trtvar &byvars2 &dpvar;
      var &var;
      output out=_unistatn
      %let cllist=;
      %do i=1 %to %words(&_statkeys_);
        %let bit=%scan(&_statkeys_,&i,%str( ));
        %if "%substr(&bit.XX,1,3)" EQ "LCL" or "%substr(&bit.XX,1,3)" EQ "UCL" %then %let cllist=&cllist &bit;
        %else %do;
          %scan(&_statkeys_,&i,%str( ))%str(=)%scan(&_statkeys_,&i,%str( ))
        %end;
      %end;
      ;
    run;

    %if %length(&cllist) %then %do;
      data _unistatn;
        set _unistatn;
        %do i=1 %to %words(&cllist);
          %let bit=%scan(&cllist,&i,%str( ));
          %if "%substr(&bit,4,1)" EQ "M" %then %do;
            %if "%substr(&bit,1,1)" EQ "L" %then %do;
              &bit=MEAN-tinv((1-%sysevalf((100-%sysfunc(compress(&bit,ULCM)))/100)/2),(N-1))*STD/sqrt(N);
            %end;
            %else %do;
              &bit=MEAN+tinv((1-%sysevalf((100-%sysfunc(compress(&bit,ULCM)))/100)/2),(N-1))*STD/sqrt(N);
            %end;
          %end;
          %else %do;
            %if "%substr(&bit,1,1)" EQ "L" %then %do;
              &bit=MEAN-tinv((1-%sysevalf((100-%sysfunc(compress(&bit,ULCM)))/100)/2),(N-1))*STD;
            %end;
            %else %do;
              &bit=MEAN+tinv((1-%sysevalf((100-%sysfunc(compress(&bit,ULCM)))/100)/2),(N-1))*STD;
            %end;
          %end;
        %end;
      run;
    %end;

    *- reset linesize -;
    options ls=&ls;

    proc transpose data=_unistatn out=_unistatn(drop=_label_
                                              rename=(col1=_value));
      by &byvars &trtvar &byvars2 &dpvar;
      var &_statkeys_;
    run;

    data _unistatn;
      retain _pct _total . _dummy 0;
      length _statname _statlabel $ 160;
      set _unistatn;
      _statname=_name_;
      _statlabel=put(_statname,$_statlb.);
      _statord=input(_statname,_stator.);
      drop _name_;
    run;

    proc sort data=_unistatn;
      by &byvars &trtvar &byvars2 &dpvar _statord _statname;
    run;

    proc append base=&dsout data=_unistatn;
    run;

    proc datasets nolist;
      delete _unistatn;
    run;
    quit;

  %mend _uninum;


               /*-----------------------------------------*
                          Create required formats
                *-----------------------------------------*/

  proc format;
    value p63val (default=6)
    low-<0.001="<0.001"
    0.999<-high=">0.999"
    .=&pvalmisstxt
    OTHER=[6.3]
    ;
    value p73val (default=7)
    low-<0.001=" <0.001"
    0.999<-high=" >0.999"
    .=&pvalmisstxt
    OTHER=[7.3]
    ;
    value p83val (default=8)
    low-<0.001="  <0.001"
    0.999<-high="  >0.999"
    .=&pvalmisstxt
    OTHER=[8.3]
    ;
    invalue _stator
    %do i=1 %to %words(&_statkeys_);
      "%scan(&_statkeys_,&i,%str( ))"=&i
    %end;
    ;
    value $_statlb
    %do i=1 %to %words(&_statkeys_);
      "%scan(&_statkeys_,&i,%str( ))"="%scan(&_statlabs_,&i,%str( ))"
    %end;
    ;
  run;


               /*-----------------------------------------*
                        Start processing the data
                *-----------------------------------------*/


  proc sort data=_unidsin;
    by &byvars &trtvar;
  run;



  *- get rid of the append base datasets if they exist -;
  proc datasets nolist;
    delete &dsout
    %if %length(&statvarlist) %then %do;
      &dspout
    %end;
    ;
  run;
  quit;

  %*- by default, do not show output from stats procedures -;
  %if %length(&statvarlist) %then %do;
    ods listing close;
  %end;

  %if %length(&statsopdest) %then %do;
    ODS &statsopdest ;
  %end;

  %if %length(&statstfmacro) %then %do;
    %&statstfmacro;
  %end;

  %let pg=1;
  %do i=1 %to %words(&varlist3);
    %let var=%scan(&varlist3,&i,%str( ));
    %if "%upcase(&var)" EQ "<P>"
     or "%upcase(&var)" EQ "<PG>" %then %let pg=%eval(&pg+1);
    %else %do;
      %*- see if it had a decimal point adjust added -;
      %let dpadj=%upcase(%scan(&var,2,/));
      %*- see if treat-as-numeric is being asked for -;
      %let forcenum=0;
      %if %index(&dpadj,N) GT 0 %then %do;
        %let forcenum=1;
        %let dpadj=%sysfunc(compress(&dpadj,N));
      %end;
      %if %index(&dpadj,M) GT 0 %then %do;
        %let minmaxadj=M;
        %let dpadj=%sysfunc(compress(&dpadj,M));
      %end;
      %else %let minmaxadj=;

      %if %length(&dpadj) %then %do;
        %if "%substr(&dpadj,1,1)" NE "+"
        and "%substr(&dpadj,1,1)" NE "-"
          %then %let dpadj=+&dpadj;
      %end;
      %*- drop decimal point adjust from variable name -;
      %let var=%scan(&var,1,/);
      %if ("%vartype(_unidsin,&var)" EQ "C")
       or ("%vartype(_unidsin,&var)" EQ "N" and not &forcenum and
          ("%substr(%varfmt(_unidsin,&var)%str(    ),1,4)" NE "BEST"
          and %length(%sysfunc(compress(%varfmt(_unidsin,&var),0123456789.))))) %then %do;
         %let lowcase=N;
         %if %index(%quotelst(%upcase(&lowcasevarlist)),"%upcase(&var)") %then %let lowcase=Y;
         %_unicat(&var,&i,&pg,&lowcase);
      %end;
      %else %_uninum(&var,&i,&pg,&dpadj,&minmaxadj);
    %end;
  %end;



  %if %length(&statsopdest) %then %do;
    ODS %scan(&statsopdest,1,%str( )) CLOSE ;
  %end;


  %*- restore listing output that was disabled for stats output -;
  %if %length(&statvarlist) %then %do;
    ods listing;
  %end;



               /*-----------------------------------------*
                              Final output sort
                *-----------------------------------------*/

  proc sort data=&dsout;
    by &byvars &trtvar &byvars2 &dpvar _statord _statname _statlabel;
  run;

  %if %length(&statvarlist) %then %do;
    data _null_;
      length _pvalmacvar $ 30;
      set &dspout;
      _pvalmacvar="_pvalue"||compress(put(_varord,4.))||"_";
      call symput(_pvalmacvar,
        compress(STAT1,"&fisherid.&chisqid.&cmhid.&anovaid.&welchid.&nparid.&ttestid,&sattid"));
    run;
    proc sort data=&dspout;
      by &byvars &byvars2 _statord;
    run;
  %end;



           /*---------------------------------------------------*
               Transpose the unistats data using statistic name
            *---------------------------------------------------*/

  %if %length(&dstranstat) %then %do;
    data _unitemp;
      length _deffmt _valfmt _valuestr $ 16 _statstr $ 32;
      set &dsout;
      _deffmt=put(_statname,$statfmt.);
      _valfmt=_deffmt;
      %if %length(&dpvar) %then %do;
        if &dpvar>0 and _statname not in ("N" "NMISS") then do;
          if scan(_deffmt,2,".") NE " " then do;
            _valfmt=trim(left(put(input(scan(_deffmt,1,"."),3.)+&dpvar,3.)))||"."
              ||trim(left(put(input(scan(_deffmt,2,"."),3.)+&dpvar,3.)));
          end;
          else do;
            _valfmt=trim(left(put(input(scan(_deffmt,1,"."),3.)+&dpvar+1,3.)))||"."
              ||trim(left(put(max(0,input(scan(_deffmt,2,"."),3.))+&dpvar,3.)));
          end;
        end;
      %end;
      _valuestr=putn(round(_value,0.0000000001),_valfmt);
      %if "&leftstr" EQ "Y" %then %do;
        _valuestr=left(_valuestr);
        %if "&padmiss" EQ "Y" %then %do;
          if _valuestr="." then do;
            if scan(put(_statname,$statfmt.),2,".") NE " " then 
              _npad=input(scan(put(_statname,$statfmt.),2,"."),2.);
            else _npad=0;
            %if %length(&dpvar) %then %do;
              if &dpvar>0 then _npad=_npad+&dpvar;
            %end;
            if _npad>0 then _valuestr="."||repeat("A0"x,_npad-1);
          end;
        %end;
      %end;
      _statstr=trim(_statname)||"STR";
    run;

    proc transpose data=_unitemp out=_unitemp1(drop=_name_);
      by &byvars &trtvar &byvars2 &dpvar;
      var _value;
      id _statname;
      idlabel _statlabel;
    run;

    proc transpose data=_unitemp out=_unitemp2(drop=_name_);
      by &byvars &trtvar &byvars2 &dpvar;
      var _valuestr;
      id _statstr;
      idlabel _statlabel;
    run;

    data &dstranstat;
      merge _unitemp1 _unitemp2;
      by &byvars &trtvar &byvars2 &dpvar;
    run;

    proc datasets nolist;
      delete _unitemp _unitemp1 _unitemp2;
    run;
    quit;

    %let libname=%scan(&dstranstat,-2,.);
    %if not %length(&libname) %then %let libname=work;
    %let memname=%scan(&dstranstat,-1,.);

    *- assign the correct formats to the stats variables -;
    %if %length(&descstats) %then %do;
      proc datasets nolist lib=&libname;
        modify &memname;
        format &statfmts;
      run;
      quit;
    %end;
  %end;


           /*---------------------------------------------------*
               Transpose the unistats data using statistic-trt
            *---------------------------------------------------*/

  %if %length(&dstranstattrt) %then %do;
    data _unitemp;
      length _deffmt _valfmt _valuestr $ 16 _stattrt _stattrtstr $ 32;
      set &dsout;
      _deffmt=put(_statname,$statfmt.);
      _valfmt=_deffmt;
      %if %length(&dpvar) %then %do;
        if &dpvar>0 and _statname not in ("N" "NMISS") then do;
          if scan(_deffmt,2,".") NE " " then do;
            _valfmt=trim(left(put(input(scan(_deffmt,1,"."),3.)+&dpvar,3.)))||"."
              ||trim(left(put(input(scan(_deffmt,2,"."),3.)+&dpvar,3.)));
          end;
          else do;
            _valfmt=trim(left(put(input(scan(_deffmt,1,"."),3.)+&dpvar+1,3.)))||"."
              ||trim(left(put(max(0,input(scan(_deffmt,2,"."),3.))+&dpvar,3.)));
          end;
        end;
      %end;
      _valuestr=putn(round(_value,0.0000000001),_valfmt);
      %if "&leftstr" EQ "Y" %then %do;
        _valuestr=left(_valuestr);
        %if "&padmiss" EQ "Y" %then %do;
          if _valuestr="." then do;
            if scan(put(_statname,$statfmt.),2,".") NE " " then 
              _npad=input(scan(put(_statname,$statfmt.),2,"."),2.);
            else _npad=0;
            %if %length(&dpvar) %then %do;
              if &dpvar>0 then _npad=_npad+&dpvar;
            %end;
            if _npad>0 then _valuestr="."||repeat("A0"x,_npad-1);
          end;
        %end;
      %end;
      _stattrt=trim(_statname)||trim(left(&trtvar));
      _stattrtstr=trim(_statname)||trim(left(&trtvar))||"STR";
    run;
    proc sort data=_unitemp;
      by &byvars &byvars2 &dpvar;
    run;

    proc transpose data=_unitemp out=_unitemp1(drop=_name_);
      by &byvars &byvars2 &dpvar;
      var _value;
      id _stattrt;
      idlabel _statlabel;
    run;

    proc transpose data=_unitemp out=_unitemp2(drop=_name_);
      by &byvars &byvars2 &dpvar;
      var _valuestr;
      id _stattrtstr;
      idlabel _statlabel;
    run;

    data &dstranstattrt;
      merge _unitemp1 _unitemp2;
      by &byvars &byvars2 &dpvar;
    run;

    proc datasets nolist;
      delete _unitemp _unitemp1 _unitemp2;
    run;
    quit;

    %let libname=%scan(&dstranstattrt,-2,.);
    %if not %length(&libname) %then %let libname=work;
    %let memname=%scan(&dstranstattrt,-1,.);

    *- assign the correct formats to the stats variables -;
    %if %length(&descstats) %then %do;
      proc datasets nolist lib=&libname;
        modify &memname;
        format 
          %do i=1 %to %words(&trtvallist);
            %do j=1 %to %words(&statfmts) %by 2;
              %scan(&statfmts,&j,%str( ))%scan(&trtvallist,&i,%str( ))
                %scan(&statfmts,%eval(&j+1),%str( ))
            %end;
          %end;
        ;
      run;
      quit;
    %end;

    %if "&plugtran" EQ "Y" %then %do;
      data &dstranstattrt;
        set &dstranstattrt;
        %do i=1 %to %words(&trtvallist);
          %let val=%scan(&trtvallist,&i,%str( ));
          %do j=1 %to %words(&_statkeys_);
            %let key=%scan(&_statkeys_,&j,%str( ));
              %if "&key" EQ "N" or "&key" EQ "NMISS" %then %do;

                if missing(&key&val) then do;
                  &key&val=0;
                  &key&val.str=putn(0,vformat(&key&val));
                  %if "&leftstr" EQ "Y" %then %do;
                    &key&val.str=left(&key&val.str);
                  %end;
                end;

              %end;
              %else %do;

                if missing(&key&val) then do;
                  &key&val.str=putn(.,vformat(&key&val));

                  %if "&leftstr" EQ "Y" %then %do;
                    &key&val.str=left(&key&val.str);

                    %if "&padmiss" EQ "Y" %then %do;

                      if scan(vformat(&key&val),2,".") NE " " then _npad=input(scan(vformat(&key&val),2,"."),2.);
                      else _npad=0;
                      %if %length(&dpvar) %then %do;
                        if &dpvar>0 then _npad=_npad+&dpvar;
                      %end;
                      if _npad>0 then &key&val.str="."||repeat("A0"x,_npad-1);

                    %end;

                  %end;
                end;

              %end;

          %end;
        %end;
       run;

    %end;

  %end;


           /*---------------------------------------------------*
               Transpose the unistats data using treatment arm
            *---------------------------------------------------*/

  %if %length(&dstrantrt) %then %do;

    data &dstrantrt;
      length _idlabel $ 120 _tempfmt $ 4 _str $ 30
             ;
      set &dsout;
      if _vartype="C" then do;
        if (_statname in ("&misstxt" &nopctcatlist) and "&misspct" NE "Y")
          then _str=put(_value,&catnfmt);
        else if _statord=0.5 then do;
          if not index("&catn",'(') then _str=put(_value,&catnfmt);
          else _str=put(_value,&catnfmt)||' ('||trim(left(put(_pct,&catnfmt)))||')';
        end;
        else do;
         %if "&pctsign" EQ "Y" %then %do;
           %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
             _str=put(_value,&catnfmt)||' / '||trim(left(put(_total, 8.)))||" ("||put(_pct,&pctfmt)||'%)';
           %end;
           %else %do;
             _str=put(_value,&catnfmt)||' ('||put(_pct,&pctfmt)||'%)';
           %end;
         %end;
         %else %do;
           %if %length(&dsdenom) and "&denomshow" EQ "Y" %then %do;
             _str=put(_value,&catnfmt)||' / '||trim(left(put(_total, 8.)))||" ("||put(_pct,&pctfmt)||')';
           %end;
           %else %do;
             _str=put(_value,&catnfmt)||' ('||put(_pct,&pctfmt)||')';
           %end;
         %end;
        end;
      end;
      else if _vartype="N" then do;
       /************ rrb
        %if %length(&statvarlist) %then %do;
          if _pvalstr ne ' ' then _str=_pvalstr;
          else do;
        %end;
        ************/
            if _dpadj=" " then do;
              if _statname="N" then _str=put(_value,&nfmt);
              else if _statname="NMISS" then _str=put(_value,&nfmt);
              else if _statname="NOBS" then _str=put(_value,&nfmt);
              else if _statname=:"PROB" then _str=put(round(_value,0.0000000001),&probfmt);
              else if _statname=:"STD" then _str=put(round(_value,0.0000000001),&stdfmt);
              else if _statname="KURTOSIS" then _str=put(round(_value,0.0000000001),&stdfmt);
              else if _statname="SKEWNESS" then _str=put(round(_value,0.0000000001),&stdfmt);
              else if _statname="MIN" then do;
                if _minmaxadj NE "M" then _str=put(round(_value,0.0000000001),&minfmt);
                else _str=put(_value,&meanfmt);
              end;
              else if _statname="MAX" then do;
                if _minmaxadj NE "M" then _str=put(round(_value,0.0000000001),&maxfmt);
                else _str=put(_value,&meanfmt);
              end;
              else if _statname="SUM" then do;
                if _minmaxadj NE "M" then _str=put(round(_value,0.0000000001),&maxfmt);
                else _str=put(round(_value,0.0000000001),&meanfmt);
              end;
              else _str=put(round(_value,0.0000000001),&meanfmt);
            end;
            else do;
              _tempadj=input(_dpadj,2.);
              if _statname="N" then _str=put(_value,&nfmt);
              else if _statname="NMISS" then _str=put(_value,&nfmt);
              else if _statname="NOBS" then _str=put(_value,&nfmt);
              else if _statname=:"PROB" then _str=put(round(_value,0.0000000001),&probfmt);
              else if _statname=:"STD" or _statname in ("KURTOSIS" "SKEWNESS") then do;
                _tempfmt="&stdfmt";
                link fillstr;
              end;
              else if _statname="MIN" then do;
                if _minmaxadj NE "M" then _tempfmt="&minfmt";
                else _tempfmt="&meanfmt";
                link fillstr;
              end;
              else if _statname="MAX" then do;
                if _minmaxadj NE "M" then _tempfmt="&maxfmt";
                else _tempfmt="&meanfmt";
                link fillstr;
              end;
              else if _statname="SUM" then do;
                if _minmaxadj NE "M" then _tempfmt="&maxfmt";
                else _tempfmt="&meanfmt";
                link fillstr;
              end;
              else do;
                _tempfmt="&meanfmt";
                link fillstr;
              end;
            end;
        /************** rrb
        %if %length(&statvarlist) %then %do;
          end;
        %end;
         **************/
      end;
      %if &nbspaces EQ Y %then %do;
        _str=translate(_str,"A0"x," ");
      %end;
      %else %if &dpalign EQ Y %then %do;
        if substr(_str,&strlen,1)=' ' then substr(_str,&strlen,1)="A0"x;
      %end;
      _idlabel=put&trtvartype(&trtvar,vformat(&trtvar));
      return;
      fillstr:
        _intempfmt=_tempfmt;
        if input(scan(_tempfmt,2,"."),2.) not in (.,0) then do;
          if _tempadj GT 0 then _tempfmt=compress(put(input(scan(_tempfmt,1,"."),2.)+_tempadj,2.))||
            "."||compress(put(input(scan(_tempfmt,2,"."),2.)+_tempadj,2.));
          else do;
            if input(scan(_tempfmt,2,"."),2.)+_tempadj LE 0 then do;
              if _statname in ("MIN", "MAX", "SUM") then _tempfmt="&nfmt";
              else _tempfmt="&meanfmt";
            end;
            else _tempfmt=compress(put(input(scan(_tempfmt,1,"."),2.)+_tempadj,2.))||
              "."||compress(put(input(scan(_tempfmt,2,"."),2.)+_tempadj,2.));
          end;
        end;
        else do;
          if _tempadj GT 0 then _tempfmt=compress(put(input(scan(_tempfmt,1,"."),2.)+1+_tempadj,2.))||
            "."||compress(put(_tempadj,2.));
        end;
        ****PUT ">>>>>>>>>" _varname= _statname= _tempadj= _intempfmt= _tempfmt= ;
        _str=putn(round(_value,0.0000000001),_tempfmt);
      return;
      drop _tempfmt _tempadj _intempfmt;
    run;


    *- sort and combine values for combined stats labels such as "Mean(SD)" -;
    proc sort data=&dstrantrt;
      by &byvars &trtvar &byvars2 _statlabel _statord;
    run;

    data &dstrantrt;
      length _newstr $ 30
             _skelolabel $ 160
             _delim1 _delim2 _delim3 $ 4
             _holdstatname $ 160
             _holdstatord 8
             ;
      retain _newstr _holdstatname " " _holdstatord .;
      set &dstrantrt;
      by &byvars &trtvar &byvars2 _statlabel;
      if first._statlabel and last._statlabel then output;
      else do;
        if first._statlabel then do;
          _newstr=left(translate(_str," ","A0"x));
          _holdstatname=_statname;
          _holdstatord=_statord;
        end;
        if last._statlabel and not first._statlabel then do;
          *- set "N" value to zero if this is missing -;
          if _holdstatname="N" and _newstr=" " then _newstr="0";
          _skelolabel=translate(upcase(_statlabel)," ","ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.");
          _delim1=left(scan(_skelolabel,1," "));
          _delim2=left(scan(_skelolabel,2," "));
          _delim3=left(scan(_skelolabel,3," "));
          _str=translate(_str," ","A0"x);
          if not (_newstr=" " and _str=" ") then do;
            if _delim3 ne " " then _str=trim(_delim1)||trim(_newstr)||trim(_delim2)||trim(left(_str))||_delim3;
            else _str=trim(_newstr)||trim(_delim1)||trim(left(_str))||_delim2;
          end;
          else _str=" ";
          _statname=_holdstatname;
          _statord=_holdstatord;
          *- translate hat character to a space -;
          _str=translate(_str," ","^");
          _newstr=" ";
          output;
        end;
      end;
      drop _newstr _skelolabel _delim1 _delim2 _delim3 _holdstatname _holdstatord;

    proc sort data=&dstrantrt;
      by &byvars &trtvar &byvars2 _statord _statname _statlabel;
    run;



    data &dstrantrt;
      length _str $ 30;
      set &dstrantrt;
      *- translate hat character to a space -;
      if _vartype="N" then _statlabel=translate(_statlabel," ","^");
    run;



    *- sort ready for a transpose... -;
    proc sort data=&dstrantrt;
      by &byvars &byvars2 _statord _statname _statlabel &trtvar;
    run;


    *- ...and then transpose -;
    proc transpose data=&dstrantrt prefix=&tranpref out=&dstrantrt(drop=_name_);
      by &byvars &byvars2 _statord _statname _statlabel;
      var _str;
      id &trtvar;
      idlabel _idlabel;
      format &trtvar ;
    run;


    *- plug the gaps -;
    data &dstrantrt;
      length &_trtvarlist_ $ 30;
      retain _dummy 0 _indent '        ';
      set &dstrantrt;
      %if "&pluggaps" EQ "Y" %then %do;
        %do i=1 %to &_trtnum_;
          %*- only plug gaps for when a treatment arm has a non-zero population -;
          %if "%scan(&_trttotals_,&i,%str( ))" NE "0" %then %do;
            *- test if we have spaces in this treatment arm column -;
            if %scan(&_trtvarlist_,&i,%str( )) EQ " " then do;
              if _vartype="C" then do;
                if (_statname in (" " &nopctcatlist) or (_statname="&misstxt" and "&misspct" EQ "N")) then do;
                  %scan(&_trtvarlist_,&i,%str( ))=put(0,&catnfmt);
                end;
                else if _statname="N" then do;
                  *- for where you have a count combined with a missing count -;
                  if scan(_statlabel,2) EQ " " then %scan(&_trtvarlist_,&i,%str( ))=put(0,&catnfmt);
                  else %scan(&_trtvarlist_,&i,%str( ))=put(0,&catnfmt)||" (0)";
                end;
                else do;
                  %if "&pctsign" EQ "Y" %then %do;
                    %scan(&_trtvarlist_,&i,%str( ))=put(0,&catnfmt)||" ("||put(0,&pctfmt)||"%)";
                  %end;
                  %else %do;
                    %scan(&_trtvarlist_,&i,%str( ))=put(0,&catnfmt)||" ("||put(0,&pctfmt)||")";
                  %end;
                end;
                %if &nbspaces EQ Y %then %do;
                  %scan(&_trtvarlist_,&i,%str( ))=translate(%scan(&_trtvarlist_,&i,%str( )),"A0"x," ");
                %end;
                %else %if &dpalign EQ Y %then %do;
                  if substr(%scan(&_trtvarlist_,&i,%str( )),vlength(%scan(&_trtvarlist_,&i,%str( ))),1) EQ " "
                  then substr(%scan(&_trtvarlist_,&i,%str( )),vlength(%scan(&_trtvarlist_,&i,%str( ))),1)="A0"x;
                %end;
              end;   /* end of _vartype="C" */
              else do; /* for _vartype="N" only plug the N or N(missing) value */
                if _statname="NMISS" and scan(_statlabel,2) NE " " then
                  %scan(&_trtvarlist_,&i,%str( ))=put(0,&catnfmt)||" (0)";
                else if _statname="N" then do;
                  %scan(&_trtvarlist_,&i,%str( ))=put(0,&catnfmt);
                  %if &nbspaces EQ Y %then %do;
                    %scan(&_trtvarlist_,&i,%str( ))=translate(%scan(&_trtvarlist_,&i,%str( )),"A0"x," ");
                  %end;
                  %else %if &dpalign EQ Y %then %do;
                    if substr(%scan(&_trtvarlist_,&i,%str( )),vlength(%scan(&_trtvarlist_,&i,%str( ))),1)=" "
                    then substr(%scan(&_trtvarlist_,&i,%str( )),vlength(%scan(&_trtvarlist_,&i,%str( ))),1)="A0"x;
                  %end;
                end;
              end;
            end;
          %end;
        %end;
      %end;
      label
      %do i=1 %to &_trtnum_;
        %scan(&_trtvarlist_,&i,%str( ))=
          "%sysfunc(put&trtvartype(%scan(&trtvallist,&i,%str( )),&trtfmt))"
      %end;
      ;
    run;

    %if %length(&statvarlist) %then %do;
      data &dstrantrt;
        update &dstrantrt &dspout;
        by &byvars &byvars2 _statord;
      run;
    %end;


    %*-- apply filter code if any --;

    data &dstrantrt;
      set &dstrantrt;
      %&statlabelmacro;
      %if %length(&filtercode) %then %do;
        %unquote(%qdequote(&filtercode));
      %end;
    run;


    %*- call external data manipulation macro if set -;
    %if %length(&extmacro) %then %do;
      %&extmacro;
    %end;


    *- final sort -;
    proc sort data=&dstrantrt;
      by &byvars &byvars2 _statord _statname _statlabel _dummy _indent;
    run;

    *- use the pageon= parameter values to increment page count if set -;
    data &dstrantrt;
      retain _incpage 0;
      set &dstrantrt;
      by &byvars;
      %if %length(&pageon) and %length(&byrowvar) %then %do;
        if first.&byrowvar
        %if %qupcase(&byrowvar) ne %qupcase(&pageon) %then %do;
          and &byrowvar in: (&pageon)
        %end;
        then _incpage=_incpage+1;
      %end;
      _page=_page+_incpage;
      drop _incpage;
    run;


  %end;


               /*-----------------------------------------*
                  Call reporting macro if unicatrep is set
                *-----------------------------------------*/

  %unicat:
  %if "&print" EQ "Y" %then %do;

    %unicatrep(dsin=&dstrantrt,byvars=&byvars,odstrtlabel=&odstrtlabel,nodata=&nodata,
    catlabel=&catlabel,catw=&catw,spantotal=&spantotal,pageline=&pageline,endline=&endline,
    pageline1=&pageline1,pageline2=&pageline2,pageline3=&pageline3,pageline4=&pageline4,
    pageline5=&pageline5,pageline6=&pageline6,pageline7=&pageline7,pageline8=&pageline8,
    pageline9=&pageline9,pageline10=&pageline10,pageline11=&pageline11,pageline12=&pageline12,
    pageline13=&pageline13,pageline14=&pageline14,pageline15=&pageline15,pagemacro=&pagemacro,
    pgbrkpos=&pgbrkpos,total=&total,strlen=&strlen,varlabel=&varlabel,spacing=&spacing,
    endline1=&endline1,endline2=&endline2,endline3=&endline3,endline4=&endline4,
    endline5=&endline5,endline6=&endline6,endline7=&endline7,endline8=&endline8,
    endline9=&endline9,endline10=&endline10,endline11=&endline11,endline12=&endline12,
    endline13=&endline13,endline14=&endline14,endline15=&endline15,endmacro=&endmacro,
    trtlabel=&trtlabel,topline=&topline,trtspace=&trtspace,style=&unicatstyle,print=&print,
    trtw1=&trtw1,trtw2=&trtw2,trtw3=&trtw3,trtw4=&trtw4,trtw5=&trtw5,trtw6=&trtw6,
    trtw7=&trtw7,trtw8=&trtw8,trtw9=&trtw9,trtw10=&trtw10,trtw11=&trtw11,trtw12=&trtw12,
    trtw13=&trtw13,trtw14=&trtw14,trtw15=&trtw15,trtw16=&trtw16,trtw17=&trtw17,trtw18=&trtw18,
    trtw19=&trtw19,has0obs=&has0obs,
    trtsp1=&trtsp1,trtsp2=&trtsp2,trtsp3=&trtsp3,trtsp4=&trtsp4,trtsp5=&trtsp5,
    trtsp6=&trtsp6,trtsp7=&trtsp7,trtsp8=&trtsp8,trtsp9=&trtsp9,trtsp10=&trtsp10,
    trtsp11=&trtsp11,trtsp12=&trtsp12,trtsp13=&trtsp13,trtsp14=&trtsp14,trtsp15=&trtsp15,
    trtsp16=&trtsp16,trtsp17=&trtsp17,trtsp18=&trtsp18,trtsp19=&trtsp19,
    indent=&indent,split=&split,out=&out,varw=&varw,
    odsrtf=&odsrtf,odshtml=&odshtml,odspdf=&odspdf,odsother=&odsother,odshtmlcss=&odshtmlcss,
    odscsv=&odscsv,odslisting=&odslisting,showstat1=&showstat1,compskip=&compskip,
    byrowvar=&byrowvar,byroword=&byroword,byrowlabel=&byrowlabel,compskippos=&compskippos,
    byrowalign=&byrowalign,byrowfmt=&byrowfmt,byroww=&byroww,showstat0=&showstat0,
    byrow2var=&byrow2var,byrow2ord=&byrow2ord,byrow2label=&byrow2label,
    byrow2align=&byrow2align,byrow2fmt=&byrow2fmt,byrow2w=&byrow2w,
    byrowfirst=&byrowfirst,trtvarlist=&trtvarlist,font_face_stats=&font_face_stats,
    font_face_other=&font_face_other,font_weight_other=&font_weight_other,
    report_border=&report_border,header_border=&header_border,
    column_border=&column_border,lines_border=&lines_border,rules=&rules,
    cellspacing=&cellspacing,cellpadding=&cellpadding,outputwidthpct=&outputwidthpct,
    background_header=&background_header,foreground_header=&foreground_header,
    background_stats=&background_stats,foreground_stats=&foreground_stats,
    background_other=&background_other,foreground_other=&foreground_other,
    header_ul=&header_ul,report_ul=&report_ul,report_ol=&report_ol,
    linepx=&linepx,linecol=&linecol,font_style_other=&font_style_other,
    font_weight_stats=&font_weight_stats,compskip_ul=&compskip_ul,
    compskippx=&compskippx,compskipcol=&compskipcol,spanrows=&spanrows,
    odsescapechar=&odsescapechar,odsprerepcode=&odsprerepcode,odspostrepcode=&odspostrepcode,
    tfmacro=&tfmacro,odstfmacro=&odstfmacro,odstrtvarlist=&odstrtvarlist,asis=&asis,
    stat0w=&stat0w,stat1w=&stat1w,stat2w=&stat2w,stat3w=&stat3w,stat4w=&stat4w,stat5w=&stat5w,
    stat6w=&stat6w,stat7w=&stat7w,stat8w=&stat8w,stat9w=&stat9w,
    statalign=&statalign,trtalign=&trtalign,
    stat0align=&stat0align,stat1align=&stat1align,stat2align=&stat2align,stat3align=&stat3align,
    stat4align=&stat4align,stat5align=&stat5align,stat6align=&stat6align,stat7align=&stat7align,
    stat8align=&stat8align,stat9align=&stat9align,
    stat0lbl=&stat0lbl,stat1lbl=&stat1lbl,stat2lbl=&stat2lbl,stat3lbl=&stat3lbl,stat4lbl=&stat4lbl,
    stat5lbl=&stat5lbl,stat6lbl=&stat6lbl,stat7lbl=&stat7lbl,stat8lbl=&stat8lbl,stat9lbl=&stat9lbl
    );

  %end;

  %else %do;

    %*- call titles and footnotes macro if set -;
    %if %length(&tfmacro) %then %do;
      %&tfmacro;
    %end;

  %end;


               /*-----------------------------------------*
                    Call conversion-to-Word-table macro
                *-----------------------------------------*/

  %if %length(&wordtabdest) %then %do;
    %unicat2word(dsin=&dstrantrt,dest=&wordtabdest,dlim=&wordtabdlim,total=&total)
  %end;


               /*-----------------------------------------*
                                    Exit
                *-----------------------------------------*/

  %if &msgs NE N %then %do;
    %put;
    %put MSG: (unistats) The following global macro variables have been set up;
    %put MSG: (unistats) and can be resolved in your code.;
    %put _statkeys_=&_statkeys_;
    %put _strlen_=&_strlen_;
    %put _misstxt_=&_misstxt_;
  %end;

  proc datasets nolist;
    delete _unidsin;
  quit;

  %goto skip;
  %exit: %put &err: (unistats) Leaving macro due to problem(s) listed;
  %skip:

  %delmac(\_uni:);

  options &savopts;


%mend unistats;
