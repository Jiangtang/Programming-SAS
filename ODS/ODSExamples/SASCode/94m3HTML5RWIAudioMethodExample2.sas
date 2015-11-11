filename rwiOut "."; /* Create a file reference for the output. 
                      This example uses the current working directory. */

ods html close;
ods html5 path=rwiOut file="AudioTest.html";
title "Adding Audio to HTML5 Output";

data _null_;
dcl odsout obj();

   obj.format_text(data: "You can embed Video and Audio into your output.", 
      style_elem: "SystemTitle"); 

/* Change file-path to the path where you downloaded SAS02_Orchestral30.mp3. */
filename AudFile url "file-path\SAS02_Orchestral30.mp3";
   obj.note(data: "However, only in the ",
      inline_attr: "font_weight=bold",
      data: "ODS HTML5 ",
      inline_attr: "color=red",
      data: "Destination.",
      inline_attr: "font_weight=bold");


   obj.audio(file:"fileref:AudFile",            
      type: "mp3",     
      preload: "auto",
      autoplay: "off",
      loop: "no"
      );


   obj.footnote(data: 'Browsers support different file types.
                This output is viewed in Google Chrome.',
      style_attr: 'just=center  color=red fontsize=12pt');
run;

ods html5 close;
ods html; /* Not required in SAS Studio */
