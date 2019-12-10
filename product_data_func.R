product_data <- function(year, OW, prod_name) {
  
#required_packages
required_pkgs <- c("stringr", "rvest", "magrittr")
for (pkg in required_pkgs) {
  if (pkg %in% rownames(installed.packages()) == FALSE)
  {install.packages(pkg)}
  if (pkg %in% rownames(.packages()) == FALSE)
  {library(pkg, character.only = TRUE)}
}

  
base_url <- "https://aplikacje.nfz.gov.pl/umowy/Provider/Index?ROK=%s&OW=%s&ServiceType=00&Code=&Name=&City=&Nip=&Regon=&Product=%s&OrthopedicSupply=false"
formatted_base_url <- sprintf(base_url, year, OW, prod_name)

prefix <- "https://aplikacje.nfz.gov.pl"
hrefs_for2layers <- paste(prefix, formatted_base_url %>% read_html() %>%
html_nodes(".hidden-sm+ td a") %>%
html_attr("href"), sep = "")

hrefs_for3layers <- c()
for (i in hrefs_for2layers) {href <- read_html(i) %>% html_nodes("td a") %>% html_attr("href")
hrefs_for3layers <- append(hrefs_for3layers, paste(prefix, href, sep = ""))}

#scraped_data
all_data_for_product <- data.frame()
for (i in hrefs_for3layers) {single_table <- read_html(i) %>% html_node("table") %>% html_table(header = TRUE)
all_data_for_product <- rbind(all_data_for_product, single_table[,-c(1,8), drop = FALSE])}

#cleaning column names
column_names <- c()
for (i in colnames(all_data_for_product)) {col_name <- unlist(strsplit(i, "\r"))[1]
column_names <- append(column_names, col_name)}
colnames(all_data_for_product) <- column_names

#Cleaning rest of the table
kod_produktu <- c()
nazwa_produktu <- c()

for (i in all_data_for_product[,1]) {row <- unlist(strsplit(i, "\r"))
kod_produktu <- append(kod_produktu, row[1])}
all_data_for_product[,1] <- kod_produktu

for (i in all_data_for_product[,2]) {row <- unlist(strsplit(i, "\r"))
nazwa_produktu <- append(nazwa_produktu, row[1])}
all_data_for_product[,2] <- nazwa_produktu
csv_file_name <- sprintf("%s_OW%s_%s", year, OW, prod_name)
write.csv(all_data_for_product, csv_file_name, row.names = FALSE)}
