workdir <- "<mydirectory>/Source_Programs/R/R_Fortran"

m <- "106"               
n <- "107"               
eps <- "0.50"            
alpha <- "0.05"         
p1 <- "0.9245"            
p2 <- "0.9065"            

#####################################################

setwd(workdir)
out <- c(m,n,eps,alpha,p1,p2)
write(out,file="ste1_inp",ncolumns=1)
system("R CMD BATCH bi2ste1.R bi2ste1.log")
file.show("ste1_inp")
file.show("ste1_out")
