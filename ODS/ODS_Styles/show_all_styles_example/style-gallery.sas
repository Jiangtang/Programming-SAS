/* Richard A. DeVenezia
 * April 15, 2004
 *
 * Create a gallery of output, each item is styled according to each
 * specifable style.
 *
 * orginal content posted to SAS-L April 15, 2004
 *
 * Note: Some styles cause Read Access Violations on some destinations.
 * IF YOU GET A READ ACCESS VIOLATION(RAV), EXIT YOUR SAS SESSION AND
 * START A NEW ONE. BEFORE SUBMITTING AGAIN, BE SURE TO EXCLUDE THE PATH
 * THAT CAUSED THE RAV
 */

/*-----
 * group: Data presentation
 * purpose: Generate output according to each style that can be specified.
 * notes: May cause access violations.  Works best on version 9.1+
 */

%macro StyleGallery (
  excludePaths =
, outPath = %sysfunc(pathname(WORK))
, destination = /* common ones are - pdf | rtf | html  */
, seed = 1
, file = gallery
, method = ALL_IN_ONE /* ALL_IN_ONE | ONE_EACH */
);

  %let method = %upcase (&method);
  %let destination = %lowcase (&destination);

  %if &destination = html and &method = ALL_IN_ONE %then %do;
    %put ERROR: destination=&destination and method=&method are incompatible;
    %goto EndMacro;
  %end;

  data foo;
    do class1 = 'a', 'b';*, 'c';
    do class2 = 1 to 3;
      nitems = 10*ranuni(&seed);
      do n = 1 to nitems;
        var1 = ranuni (&seed);
        var2 = ranuni (&seed);
        var3+1;
        output;
      end;
    end;
    end;
  run;

  title;
  footnote;

  ods _all_ close;
  ods trace off;

  proc template;
    ods output Template.Stats = styles(where=(type='Style'));
    list ;
  run;

  %let excludePaths = %sysfunc(translate(|&excludePaths.|,|,%str( )));
  %let excludePaths = %sysfunc(upcase(&excludePaths));

  proc sql;

    delete from styles
    where index ("&excludePaths"
                , '|' || trim(upcase(path)) || '|'
                )
    ;

    %local i nstyles;

    reset noprint;
    select count(*) into :nstyles from styles;
    %let nstyles = &nstyles;

    %do i = 1 %to &nstyles;
      %local style&i path&i;
    %end;

    select tranwrd(path,'Styles.','')
    into :style1-:style&nstyles.
    from styles
    ;

    select path
    into :path1-:path&nstyles.
    from styles
    ;
  quit;

  %if &method = ALL_IN_ONE %then %do;
    ods &destination file="&outPath./&file..&destination" ;

    %if &destination = pdf %then %do;
      ods &destination startpage=never;
    %end;
  %end;

  %do i = 1 %to &nstyles ;

    %put Render &i - &&style&i (&&path&i);

    %if &method = ONE_EACH %then %do;
      ods &destination file="&outPath./&file.-&&style&i...&destination" style=&&style&i;

      title "STYLE=&&style&i";
      footnote "Style Gallery - Richard A. DeVenezia";
    %end;
    %else %do;
      %* ALL_IN_ONE - works for pdf, not for html;
      ods &destination style=&&style&i;
    %end;

    proc tabulate data=foo;
      class class:;
      var var:;

      table
        class1*class2
      , var1*mean var2*min var3*max
      / box = "#&i: Style=&&style&i"
      ;
    run;

  %end;

  %if &method = ALL_IN_ONE %then %do;
    ods &destination close;
  %end;

%EndMacro:

%mend;

/**html
 * <p>Sample code</p>
 */

options nomprint;

/*
 * for destinations html and rtf, method ALL_IN_ONE output is not as
 * diverse as method ONE_EACH output
 */

/*
%StyleGallery ( destination = pdf, ExcludePaths = Styles.Theme, method = ONE_EACH )
%StyleGallery ( destination = html, method = ONE_EACH )
%StyleGallery ( destination = rtf,  method = ONE_EACH )
*/

%StyleGallery ( destination = pdf, ExcludePaths = Styles.Theme )
