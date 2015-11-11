/*making a sortable HTML table*/
%macro ods_html_sort_table;
	<script src='http://goo.gl/Pg0GB'></script>
	<script src='http://goo.gl/ruKEb'></script>
	<script>$(document).ready(function(){$('.table').tablesorter({widgets: ['zebra']});});</script>
%mend;

title ;
ods listing close;
ods html   file="a:\test\iris.html" style=sasweb headtext="%ods_html_sort_table";

data _null;
	set sashelp.iris;
	by Species;
	
/*	create an object, obj, based on the ODS Report Writing class, odsout*/
	if _n_ = 1 then do;
		dcl odsout obj();
	end;

	if (first.Species) then do; *by group processing;
	   obj.title(text: "Fisher's Iris Data Set by Species"); *title;

/*	   start a table*/
	   obj.table_start();
	   		obj.row_start();
		      if (Species = "Setosa") then
		         obj.image(file: "Iris_setosa.jpg" );*insert image;
		      else if (Species = "Versicolor") then
		         obj.image(file: "Iris_versicolor.jpg" );
		      else if (Species = "Virginica") then
		         obj.image(file: "Iris_virginica.jpg" );
			obj.row_end();

			obj.row_start();
				obj.format_cell(text: "Iris Species",  overrides: "fontweight=bold just=right" );
				obj.format_cell(text: Species, column_span: 3, overrides: "just=left");
			obj.row_end();

			obj.row_start();
				obj.format_cell(text: "Unit",  overrides: "fontweight=bold just=right" );
				obj.format_cell(text: "(mm)", column_span: 3, overrides: "just=left");
			obj.row_end();
	   obj.table_end();

	   /* start another table */
	   obj.table_start();
			obj.head_start();
				obj.row_start();
					obj.format_cell(text: "Sepal Length" , overrides: "fontweight=bold");
					obj.format_cell(text: "Sepal Width" , overrides: "fontweight=bold");
					obj.format_cell(text: "Petal Length" , overrides: "fontweight=bold");
					obj.format_cell(text: "Petal Width" , overrides: "fontweight=bold");
				obj.row_end();
			obj.head_end();
	end;

		obj.row_start();
			obj.format_cell(data: SepalLength);
			obj.format_cell(data: SepalWidth);
			obj.format_cell(data: PetalWidth);
			obj.format_cell(data: SepalLength);
		obj.row_end();

	if (last.Species) then do;
		obj.table_end();

		obj.note(data: "Note: These Tables are Sortable."); *note;

		obj.foot_start(); *footer;
			obj.row_start();
				obj.cell_start();
					obj.format_text(data: "Footer: Data from SAS V&sysver at &sysscp &sysscpl Sashelp.iris",just:"C");
				obj.cell_end();
			obj.row_end();
		obj.foot_end();

		obj.page();
	end;
run;

ods html close;
ods listing;
