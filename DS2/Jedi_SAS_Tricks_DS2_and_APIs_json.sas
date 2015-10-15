/*

http://blogs.sas.com/content/sastraining/2015/01/17/jedi-sas-tricks-ds2-apis-get-the-data-you-are-looking-for/
*/


proc ds2 ;
    data _null_;
        dcl package logger putlog();
        dcl varchar(32767) character set utf8 url response;
        method GetResponse(varchar(32767) url);
            dcl integer i rc;
            dcl package http webQuery();
            /* create a GET call to the API*/
            webQuery.createGetMethod(url);
            /* execute the GET */
            webQuery.executeMethod();
            /* retrieve the response body as a string */
            webQuery.getResponseBodyAsString(response, rc);
        end;
        method run();
            /* GET: obtain a list of all people */
            url='http://swapi.co/api/people';
            GetResponse(url);
            put;
            putlog.log('N', URL);
            putlog.log('N', Response);
            put;
            /* GET: obtain information for Luke Skywalker (Person 1) */
            url='http://swapi.co/api/people/1';
            GetResponse(url);
            put;
            putlog.log('N', URL);
            putlog.log('N', Response);
            put;
        end;
    enddata;
    run;
quit;

proc ds2 ;
    data CastOfCharacters/overwrite=yes;
      dcl varchar(32767) character set utf8 url response;
      drop url response;
      dcl integer id;
      dcl varchar(30) name hair_color skin_color eye_color birth_year gender;
      dcl double height mass;
      method GetResponse(varchar(32767) url);
         dcl integer rc;
         dcl package http webQuery();
         /* create a GET call to the API*/
         webQuery.createGetMethod(url);
         /* execute the GET */
         webQuery.executeMethod();
         /* retrieve the response body as a string */
         webQuery.getResponseBodyAsString(response, rc);
      end;
      method run();
         dcl int endloop;
         /* Make a GET and retrieve the number of persons */
         url='http://swapi.co/api/people';
         GetResponse(url);
         endloop=scan(Response,2,'".,:{}');
         /* Make sequential GETs, one for each person */
         do ID =1 to endloop;
            url=cats('http://swapi.co/api/people/',id);
            GetResponse(url);
            do;
               name=      scan(Response,2,'".,:{}');
               height=    scan(Response,4,'".,:{}');
               mass=      scan(Response,6,'".,:{}');
               hair_color=scan(Response,8,'".,:{}');
               skin_color=scan(Response,10,'".,:{}');
               eye_color= scan(Response,12,'".,:{}');
               birth_year=scan(Response,14,'".,:{}');
               gender=    scan(Response,16,'".,:{}');
               if name ne 'Not found' then output;
            end;
         end;
      end;
   enddata;
   run;
quit;

proc fedsql;
select id
      ,name
      ,height
      ,mass
   from CastOfCharacters
   limit 5;
quit;

