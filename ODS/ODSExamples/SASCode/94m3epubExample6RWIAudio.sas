
ods html close;
/*ods html5 path=rwiOut file="AudioRWITest.html";*/
ods epub3 file=rwiOut file="c:\Users\rocrum\AudioRWITest.epub" title="RWI Audio eBook" newchapter=now;
title "Adding Audio to EPUB Output";

data _null_;
dcl odsout obj();

   obj.format_text(data: "You can embed Audio into your eBook. ",
                   data: " Use the RWI Audio Method.", 
      style_elem: "SystemTitle"); 

/* Change file-path to the path where you downloaded SAS02_Orchestral30.mp3. */
filename AudFile url "c:\Users\rocrum\SAS02_Orchestral30.mp3";
 obj.audio(file:"fileref:AudFile",            
      type: "mp3",     
      preload: "auto",
      autoplay: "off",
      loop: "no"
      );
run;
ods epub3 close;
ods html; /* Not required in SAS Studio */
