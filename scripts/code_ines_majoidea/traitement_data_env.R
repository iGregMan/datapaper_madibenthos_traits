install.packages("FactoMineR")
install.packages("missMDA")

library(Factoshiny)
library(missMDA)
library(FactoInvestigate)

install.packages("corrplot")
library(corrplot)
data=Madibenthos_envir
data<-data[,-1]
data<-data[,-1]
data<-data[,-1]
data<-data[,-1]
data<-data[,-1]

cor(data)
mat=cor(data)

corrplot(mat, order = "AOE", method = "color", addCoef.col = "grey")

corrplot.mixed(mat, order="AOE")

corrplot(cor(data), method="color", type="upper", tl.cex = 0.5, tl.col = "black", number.cex = 0.3, number.digits = 2)


install.packages("Cairo", dependencies = TRUE)
install.packages("xlsx")
