%let filename = %quote(c:\documents and settings\owner\my documents\my sas files\v8\saspairs\saspairs_otherstuff\asmat.cov);
%let cov_phenotypes = h_iq h_educ h_extra h_anx h_tm h_ind 
                      w_iq w_educ w_extra w_anx w_tm w_ind;
libname spothstf 'C:\Documents and Settings\Owner\My Documents\My SAS Files\V8\SASPairs\SASPairs_OtherStuff';
%let cov_data_set = %str(spothstf.kay_phillips);
%saspairs_create_cov_from_file(&filename, LO, 344, &cov_phenotypes, 
	&cov_data_set, 1, 2);
