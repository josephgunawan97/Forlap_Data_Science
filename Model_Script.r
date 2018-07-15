library(tidyr)

dataframe <- read.csv("MyData.csv")
dataframe$X <- c()
dataframe$X.1 <- c()
dataframe$tanggalBerdiri <- c()
dataframe <- dataframe[dataframe$statusProdi!="Tutup",]
dataframe <- dataframe %>%separate(Semester, c("Semester", "Tahun"), " ")
dataframe$Tahun <- as.numeric(dataframe$Tahun)
dataframe$Semester <- as.factor(dataframe$Semester)

new_test <- dataframe
new_test$Tahun[new_test$Tahun<2018] <- c(2018)
new_test$Banyak <- c()
new_test<- unique(new_test)

model <- lm (Banyak~. ,data=dataframe)
res <- predict(model,new_test)

new_data <- new_test
new_data$Banyak <-res
new_data$Banyak[new_data$Banyak<=0] <- 0
newdf <- rbind(dataframe,new_data)

#ggplot(newdf[newdf$namaProdi=="Akuntansi",],aes(x=Tahun,y=Banyak))+geom_bar(stat="identity") + coord_flip()
