workdir <- "<mydirectory>/Source_Programs/R/R_Fortran"

rho1 <- ".6667"          
rho2 <- "1.5"            
alpha <- "0.05"          
p1 <- "0.50"             
p2 <- "0.50"             
beta <- "0.60"           
qlambd <- "3.0"          

######################################################

setwd(workdir)
out <- c(rho1,rho2,alpha,p1,p2,beta,qlambd)
write(out,file="aeq2_inp",ncolumns=1)
system("R CMD BATCH bi2aeq2.R bi2aeq2.log")
file.show("aeq2_inp")
file.show("aeq2_out")
