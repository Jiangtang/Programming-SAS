workdir <- "<mydirectory>/Source_Programs/R/R_Fortran"

eps <- "0.50"         
alpha <- "0.05"      
p1 <- "0.9245"
p2 <- "0.9065"         
beta <- "0.80"           
qlambd <- "1.0"       

#######################################################

setwd(workdir)
out <- c(eps,alpha,p1,p2,beta,qlambd)
write(out,file="ste2_inp",ncolumns=1)
system("R CMD BATCH bi2ste2.R bi2ste2.log")
file.show("ste2_inp")
file.show("ste2_out")
