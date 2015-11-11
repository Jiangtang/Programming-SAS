
ods epub3 file="CatVideoRWI.epub" title="RWI Video eBooK" newchapter=now;

title;
footnote;

data _null_;
   dcl odsout obj();

   obj.video(/*-- catbox.mp4 will be selected --*/
             file:"http://www.elizabethcastro.com/epub/examples/catbox.mp4",
             type:"mp4",
             poster:"poster.jpg",
             width:"382px",
             height:"287px"
             );
   run;
   
ods epub3 close;
