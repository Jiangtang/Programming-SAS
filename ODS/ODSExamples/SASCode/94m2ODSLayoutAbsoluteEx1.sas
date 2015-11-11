ods html close;
proc template;
define style Styles.OrionCalloutBlock;
parent =Styles.Printer;
style LayoutRegion/
background=cxbbb2e0;
end;
run;
options nodate nonumber;
ods escapechar="~";

title "~{style [preimage='c:\ODSExamples\Images\orionstarHeader.jpg' width=100pct background=cx494068 color=cxbbb2e0 font_size=32pt] Our Company }";

footnote "~{style [font_size=10pt just=right color=cxbbb2e0]SAS ODS Absolute Layout features.}";

ods pdf file="SGF22.pdf" notoc nogtitle nogfootnote;

ods layout absolute;
   ods region;
      ods text="~{style [preimage='c:\ODSExamples\Images\starLarge.gif' font_style=italic font_size=20pt color=cxbbb2e0]Who we are...}";

   ods region y=0.5in x=1in width=6in;
      ods text="The fictional Orion Star Sports & Outdoors is an international retail
company that sells sports and outdoor products. The headquarters is based in the 
United States, and retail stores are situated in a number of other countries including  
Belgium, Holland, Germany, the United Kingdom, Denmark, France, Italy, Spain, and  
Australia.";

   ods region y=1.25in x=1in width=4in;
      ods text="Products are sold through physical retail stores, as well as through mailorder 
catalogs and the Internet. Customers who sign up as members of the Orion Star 
Club organization can receive favorable special offers; therefore, most customers 
enroll in the Orion Star Club. The sales data in the scenario only include the 
purchases by Orion Star Club members in the years 1998 through 2002.";

   ods region y=2.2in height=.5in width=3in;
      ods text="~{style [preimage='c:\ODSExamples\Images\starLarge.gif' font_style=italic font_size=20pt color=cxbbb2e0]What we sell...}";

   ods region y=2.70in x=1in width=4in height=1.75in;
      ods text="Approximately 5500 different sports and outdoors products are offered at 
Orion Star. Some of the products are not sold in certain countries, whereas others are 
sold in volumes that reflect the different types of sports and outdoor activities that 
are performed in each country. All of the product names are fictitious.";
      ods text="~{newline}Products are organized in a hierarchy consisting of four levels:";
      ods text="Product Line";
      ods text="Product Category";
      ods text="Product Group";

   ods region y=4.3in height=.5in width=5in;
      ods text="~{style [preimage='c:\ODSExamples\Images\starLarge.gif' font_style=italic font_size=20pt color=cxbbb2e0]Where we generate our profit...}";

 /*  ods region y=5.1in width=4.70in height=4in;*/
   ods region y=5.35in width=4.75in height=3.75in;
      goptions device=png htext=1mm;
      proc gchart data=sashelp.orsales;
         pie product_category /
         sumvar=profit
         value=none
         percent=outside 
         slice=outside;
      run;
      quit; /* added this one per bari */
   /*ods region y=5.146in x=4.0in width=4.0in height=4in;*/
ods region y=5.5in x=4.625in width=3in height=3.7in;
      proc report nowd data=sashelp.orsales style(header)={background=cx494068 color=cxbbb2e0};
      columns product_category profit;
      define product_category / group;
      define profit /analysis sum format=dollar14.;
      run;
     /* quit; */
   ods pdf style=Styles.OrionCalloutBlock;
   ods region x=6in y=1.0625in width=2in height=1in;
      ods text="~{style [background=cx494068 color=cxbbb2e0 font_size=15pt just=center font_style=italic width=100pct] Our Mission }";
      ods text="~{style [font_style=italic vjust=center font_size=10pt just=center]To deliver the best quality sporting equipment, accessories, and outdoor equipment for all seasons at the most affordable prices.}";
   ods region x=6in y=2.1875in width=2in height=.75in;
      ods text="~{style [background=cx494068 color=cxbbb2e0 font_size=15pt just=center font_style=italic width=100pct] Our Vision }";
      ods text="~{style [font_style=italic vjust=center font_size=10pt just=center]To transform the way the world purchases sporting and outdoor equipment.}";
   ods region x=6in y=3.1in width=2in height=.75in;
      ods text="~{style [background=cx494068 color=cxbbb2e0 font_size=15pt just=center font_style=italic width=100pct] Our Values }";
      ods text="~{style [font_style=italic vjust=center font_size=10pt just=center]Customer focused, Swift and Agile, Innovative, Trustworthy}";
   ods region x=6in y=4.0in width=2in height=1in;
      ods text="~{style [background=cx494068 color=cxbbb2e0 font_size=15pt just=center font_style=italic width=100pct] Our Goal }";
   ods text="~{style [font_style=italic vjust=center font_size=10pt just=center]To grow sales by 15% annually while also improving profit margin through innovative thinking and operational efficiencies.}";
   ods pdf style=Styles.Printer;
ods layout end;
ods pdf close;
