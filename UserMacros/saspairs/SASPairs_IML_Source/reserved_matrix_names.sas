data spimlsrc.reserved_matrix_names;
	length rsvd_mname $20;
	input rsvd_mname $20.;
	rsvd_mname=upcase(rsvd_mname);
datalines;
autoreg             
bad_f_value         
badhess             
badsolution         
block               
can_change          
cov_mats            
count               
current_model       
delta               
dethess             
detpre              
df                  
diag                
dif                 
difm                
equality_constraints
f                   
fdet                
flag                
free                
fstart              
ftemp1              
ftemp2              
ftemp3              
fval                
f_scale             
gamma               
gamma_a             
gamma_c             
gamma_d             
gtol                
i                   
index_remove_sscp   
index_remove_sumx   
index_sscp          
index_sumx          
index_x             
invpre              
label               
log_likelihood
maxlen              
mnames              
mean_vecs           
mean_vector         
minev               
model_names         
model_output_label  
model_position      
mtype               
ncols               
nrows               
number_of_models    
number_of_parameters
n_configs           
n_cov               
n_covariates        
n_nomiss            
n_phenotypes        
n_rel               
n_remove_sscp       
n_remove_sumx       
n_var               
nbad                
ncheck              
nq                  
nzero               
obs                 
offdiag             
opt                 
order               
p1                  
p1cv                
p2                  
p2cv                
pairnum             
pair_number         
parm_label          
parm_value          
pn                  
pre                 
prem                
preinv              
printmeans          
quad                
r12                 
rcode
rcodes 
rel1                
rel2                
rel_label           
rel_pheno           
remove_sscp         
remove_sumx         
rowlabel            
same                
sample_size         
save_fit_indices    
span                
sscp                
start               
stop                
su20                
sumx                
svarnames           
tcopt               
thisf               
thismeans           
thispre             
thisremove          
thissscp            
thissumx            
thistrace           
varnames            
vccv                
whereinx            
x0                  
xres                
xstart              
;
run;

/* write out list in tab delimited form for the Table in the documentation */
/*
data _null_;
	set spimlsrc.reserved_matrix_names;

	length n1 n2 n3 n4 $20 tab $1;
	array name [4] n1 n2 n3 n4;
	retain count tab n1 n2 n3 n4;

	if _n_=1 then do;
		tab = collate(9);
		count=0;
	end;

	file 'temp_name2';
	count=count+1;
	name[count] = lowcase(rsvd_mname);
	if count=4 then do;
		put n1 tab n2 tab n3 tab n4;
		count=0;
	end;
run;
*/
