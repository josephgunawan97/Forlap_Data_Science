library(RSelenium)
library(rvest)
library(dplyr)
library(XML)

#SETUP WEBSITE
rD <- rsDriver(port=4444L,browser="chrome")
remDr <- rD$client
remDr$navigate("https://forlap.ristekdikti.go.id/perguruantinggi")

#ISI CAPTCHA
captcha <- remDr$findElement(using = 'name', value = "captcha_value_1")
captcha <- as.numeric(captcha$getElementAttribute("value"))
captcha2 <- remDr$findElement(using = 'name', value = "captcha_value_2")
captcha2 <- as.numeric(captcha2$getElementAttribute("value"))
captcha_fill <- remDr$findElement(using='id',value="kode_pengaman")
captcha_fill$sendKeysToElement(list(toString(captcha+captcha2), key="enter"))

# Pilih Kopertis 3
kode_koor <- remDr$findElement(using = 'name', value="kode_koordinasi")
kode_koor$clickElement()
koor_opt <- remDr$findElement(using = 'xpath', "//option[@value = '728989DD-251E-4516-BE2C-BA17A93A5C51']")
Sys.sleep(1)
koor_opt$clickElement()

#Mulai pencarian
submitbtn <- remDr$findElement(using="xpath","//input[@value='Cari Perguruan Tinggi']")
submitbtn$clickElement()

doc <- htmlParse(remDr$getPageSource()[[1]])
link <- xpathSApply(doc, "//a[@href]", xmlGetAttr,"href")
link <- as.data.frame(link[grepl("detail",link)])
colnames(link) <- c("detail")
Kode_PT <- xpathSApply(doc, "/html/body/div[2]/div[2]/div[2]/div[1]/div/table/tbody/tr/td[2]", xmlValue)
link <- cbind(link, Kode_PT)

#NYARI JUMLAH PAGE / DATA
current <- remDr$getCurrentUrl()[[1]]
doc <- htmlParse(remDr$getPageSource()[[1]])
next_page <- xpathSApply(doc, "//a[@href]", xmlGetAttr,"href")
last_page <- next_page[length(next_page)]
next_page <- next_page[length(next_page)-1]
second <- as.numeric(strsplit(next_page, "[/]")[[1]][6])
last <- as.numeric(strsplit(last_page, "[/]")[[1]][6])

#LOOPING AND MERGE LINK
for(i in 1:((last/20))) {
  if(next_page == "https://forlap.ristekdikti.go.id/files" || next_page == "https://forlap.ristekdikti.go.id/files/feeder") {
    remDr$navigate("https://forlap.ristekdikti.go.id/perguruantinggi")
    
    #ISI CAPTCHA
    captcha <- remDr$findElement(using = 'name', value = "captcha_value_1")
    captcha <- as.numeric(captcha$getElementAttribute("value"))
    captcha2 <- remDr$findElement(using = 'name', value = "captcha_value_2")
    captcha2 <- as.numeric(captcha2$getElementAttribute("value"))
    captcha_fill <- remDr$findElement(using='id',value="kode_pengaman")
    captcha_fill$sendKeysToElement(list(toString(captcha+captcha2), key="enter"))
    
    # Pilih Kopertis 3
    kode_koor <- remDr$findElement(using = 'name', value="kode_koordinasi")
    kode_koor$clickElement()
    koor_opt <- remDr$findElement(using = 'xpath', "//option[@value = '728989DD-251E-4516-BE2C-BA17A93A5C51']")
    Sys.sleep(1)
    koor_opt$clickElement()
    
    #Mulai pencarian
    submitbtn <- remDr$findElement(using="xpath","//input[@value='Cari Perguruan Tinggi']")
    submitbtn$clickElement()
    
    remDr$navigate(current)
    doc <- htmlParse(remDr$getPageSource()[[1]])
    next_page <- xpathSApply(doc, "//a[@href]", xmlGetAttr,"href")
    next_page <- ifelse(i==(last/20)-1, next_page[length(next_page)],next_page[length(next_page)-1])
    link2 <- xpathSApply(doc, "//a[@href]", xmlGetAttr,"href")
    link2 <- as.data.frame(link2[grepl("detail",link2)])
    colnames(link2) <- c("detail")
    Kode_PT <- xpathSApply(doc, "/html/body/div[2]/div[2]/div[2]/div[1]/div/table/tbody/tr/td[2]", xmlValue)
    link2 <- cbind(link2, Kode_PT)
    link <- merge(link, link2, all=TRUE)
    }
    
  else {
    current <- remDr$getCurrentUrl()[[1]]
    remDr$navigate(next_page)
    
    doc <- htmlParse(remDr$getPageSource()[[1]])
    next_page <- xpathSApply(doc, "//a[@href]", xmlGetAttr,"href")
    
    next_page <- ifelse(i==(last/20)-1, next_page[length(next_page)],next_page[length(next_page)-1])
    link2 <- xpathSApply(doc, "//a[@href]", xmlGetAttr,"href")
    link2 <- as.data.frame(link2[grepl("detail",link2)])
    colnames(link2) <- c("detail")
    
    Kode_PT <- xpathSApply(doc, "/html/body/div[2]/div[2]/div[2]/div[1]/div/table/tbody/tr/td[2]", xmlValue)
    link2 <- cbind(Kode_PT, link2)
    link <- merge(link, link2, all=TRUE)
    }
}

#TANSFORM DETAIL AND MERGE DATA
df <- data.frame(matrix(ncol = 0, nrow = 0))
for (j in 1:nrow(link)) {
  PT <- (read_html(toString(link[j,1])) %>% html_table(fill=TRUE))[[1]]
  PT<-PT[2,3]
  data <- (read_html(toString(link[j,1])) %>% html_table(fill=TRUE))[[3]]
  data <- data[!apply(is.na(data) | data == "", 1, all),]
  data <- data[ -c(6:8) ]
  data_fill <- as.data.frame(data[2:nrow(data),])
  colnames(data_fill) <- data[1,]
  data_fill$namaPT <- c()
  data_fill<-cbind(data_fill,namaPT=PT)
  df <- bind_rows(df,as.data.frame(data_fill))
}

#BUAT AMBIL LINK PRODI YANG ADA DI LINK
link4 <- link3

for(j in 1:nrow(link)){
  remDr$navigate(link[j,1])
  doc2 <- htmlParse(remDr$getPageSource()[[1]])
  link3 <- xpathSApply(doc2, "//a[@href]", xmlGetAttr,"href")
  link3 <- as.data.frame(link3[grepl("prodi/detail",link3)])
  link4 <- merge(link4,link3,all=TRUE)
}
df2 <- data.frame(matrix(ncol = 0, nrow = 0))
for (j in 1:nrow(link4)){
  PT <- (read_html(toString(link4[j,1])) %>% html_table(fill=TRUE))[[1]]
  NamaPT2<-PT[2,3]
  NamaProdi2 <- PT[4,3]
  Prodi <- (read_html(toString(link4[j,1])) %>% html_table(fill=TRUE))[[3]]
  Prodi <- Prodi[!apply(is.na(Prodi) | Prodi == "", 1, all),]
  Prodi <- Prodi[,2:3]
  data_fill2 <- as.data.frame(Prodi[1:nrow(Prodi),])
  data_fill2$namaPT <- c()
  data_fill2$namaProdi <- c()
  data_fill2<-cbind(data_fill2,namaPT=NamaPT2)
  data_fill2<-cbind(data_fill2,namaProdi=NamaProdi2)
  df2 <- df2 <- bind_rows(mutate_all(df2, as.character) ,mutate_all(as.data.frame(data_fill2), as.character))
}
new_data <- new_data[!new_data$Semester=="Data tidak ditemukan",]
new_data$Banyak <- as.numeric(new_data$Banyak)

write.csv(new_data,"MyData.csv")
