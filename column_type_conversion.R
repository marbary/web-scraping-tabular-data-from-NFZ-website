#required_packages
required_pkgs <- c("stringr", "rvest", "magrittr", "dplyr", "taRifx")
for (pkg in required_pkgs) {
  if (pkg %in% rownames(installed.packages()) == FALSE)
  {install.packages(pkg)}
  if (pkg %in% rownames(.packages()) == FALSE)
  {library(pkg, character.only = TRUE)}
}

#cleansing sample data loaded directly form web service
data <- direct %>% read_html() %>% html_node("table") %>% html_table(dec = ",")
# do this in order to convert string columns with cost data to numric columns so you can analyze this data
data[,4] <- gsub(",", ".", data[,4])
data[,5] <- gsub(",", ".", data[,5])
data[,6] <- gsub(",", ".", data[,6])
data[,c(4:6)] <- sapply(data[,c(4:6)], destring)
# simple data summary
data <- as_tibble(data)

#cleansing sample data loaded form csv file
data1 <- read.csv("sample_data")
data1[, c(7, 12:14)] <- sapply(data1[,c(7, 12:14)], as.character)

data1[,7] <- gsub(",", ".", data1[,7])
data1[,12] <- gsub(",", ".", data1[,12])
data1[,13] <- gsub(",", ".", data1[,13])
data1[,14] <- gsub(",", ".", data1[,14])

data1[,c(7, 12:14)] <- sapply(data1[,c(7, 12:14)], destring)

