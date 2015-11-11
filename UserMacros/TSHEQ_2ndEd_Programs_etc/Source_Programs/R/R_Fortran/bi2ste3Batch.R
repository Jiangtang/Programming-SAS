workdir <- "<mydirectory>/Source_Programs/R/R_Fortran"

m <- "50"               
n <- "50"               
eps <- ".333333"             
alpha <- "0.05E0"           
sw <- "0.01E0"           
tolrd <- "1.0D-10"       
tol <- "0.00000001E0"    
maxh <- "25"             

####################################################

setwd(workdir)
out <- c(m,n,eps,alpha,sw,tolrd,tol,maxh)
write(out,file="ste3_inp",ncolumns=1)
system("R CMD BATCH bi2ste3.R bi2ste3.log")
file.show("ste3_inp")
file.show("ste3_out")
