/*
http://blogs.sas.com/content/sasdummy/2015/09/28/parse-json-from-sas/

*/


proc ds2; 
  data messages (overwrite=yes);
    /* Global package references */
    dcl package json j();

    /* Keeping these variables for output */
    dcl double post_date having format datetime20.;
    dcl int views;
    dcl nvarchar(128) subject author board;
    
    /* these are temp variables */
    dcl varchar(65534) character set utf8 response;
    dcl int rc;
    drop response rc;

    method parseMessages();
      dcl int tokenType parseFlags;
      dcl nvarchar(128) token;
      rc=0;
      * iterate over all message entries;
      do while (rc=0);
        j.getNextToken( rc, token, tokenType, parseFlags);

        * subject line;
        if (token eq 'subject') then
          do;
            j.getNextToken( rc, token, tokenType, parseFlags);
            subject=token;
          end;

        * board URL, nested in an href label;
        if (token eq 'board') then
          do;
            do while (token ne 'href');
               j.getNextToken( rc, token, tokenType, parseFlags );
            end;
            j.getNextToken( rc, token, tokenType, parseFlags );
            board=token;
          end;

        * number of views (int), nested in a count label ;
        if (token eq 'views') then
          do;
            do while (token ne 'count');
               j.getNextToken( rc, token, tokenType, parseFlags );
            end;
            j.getNextToken( rc, token, tokenType, parseFlags );
            views=inputn(token,'5.');
          end;

        * date-time of message (input/convert to SAS date) ;
        * format from API: 2015-09-28T10:16:01+00:00 ;
        if (token eq 'post_time') then
          do;
            j.getNextToken( rc, token, tokenType, parseFlags );
            post_date=inputn(token,'anydtdtm26.');
          end;

        * user name of author, nested in a login label;
        if (token eq 'author') then
          do; 
            do while (token ne 'login');
               j.getNextToken( rc, token, tokenType, parseFlags );
            end;
            * get the author login (username) value;
            j.getNextToken( rc, token, tokenType, parseFlags );
            author=token;
            output;
          end;
      end;
      return;
    end;

    method init();
      dcl package http webQuery();
      dcl int rc tokenType parseFlags;
      dcl nvarchar(128) token;
      dcl integer i rc;

      /* create a GET call to the API                                         */
      /* 'sas_programming' covers all SAS programming topics from communities */
      webQuery.createGetMethod(
         'http://communities.sas.com/kntur85557/' || 
         'restapi/vc/categories/id/sas_programming/posts/recent' ||
         '?restapi.response_format=json' ||
         '&restapi.response_style=-types,-null&page_size=100');
      /* execute the GET */
      webQuery.executeMethod();
      /* retrieve the response body as a string */
      webQuery.getResponseBodyAsString(response, rc);
      rc = j.createParser( response );
      do while (rc = 0);
        j.getNextToken( rc, token, tokenType, parseFlags);
        if (token = 'message') then
          parseMessages();
      end;
    end;

  method term();
    rc = j.destroyParser();
  end;

  enddata;
run;
quit;

/* Add some basic reporting */
proc freq data=messages noprint;
    format post_date datetime11.;
    table post_date / out=message_times;
run;

ods graphics / width=2000 height=600;
title '100 recent message contributions in SAS Programming';
title2 'Time in GMT';
proc sgplot data=message_times;
    series x=post_date y=count;
    xaxis minor label='Messages';
    yaxis label='Time created' grid;
run;

title 'Board frequency for recent 100 messages';
proc freq data=messages order=freq;
    table board;
run;

title 'Detailed listing of messages';
proc print data=messages;
run;

title;
