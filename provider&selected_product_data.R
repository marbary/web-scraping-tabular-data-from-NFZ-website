provider_product_data <- function(year, OW, prod_name) {
  
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
  
  #provider's info gathering (id, name, city and voivodeship name), which next going to be added to the main table
  service_providers <- formatted_base_url %>% read_html() %>% html_node("table") %>% html_table()
  service_providers <- service_providers[2:4]
  
  
  hrefs_for3layers <- c()
  for (i in hrefs_for2layers) {href <- read_html(i) %>% html_nodes("td a") %>% html_attr("href")
  hrefs_for3layers <- append(hrefs_for3layers, paste(prefix, href, sep = ""))}
  
  #product data gathering
  all_data_for_product <- data.frame()
  count <- 0
  for (i in hrefs_for3layers) {single_table <- read_html(i) %>% html_node("table") %>% html_table(header = TRUE)
  count<- count + 1
  attach <- service_providers[count,]
  attach1 <- attach[rep(seq_len(nrow(attach)), each = nrow(single_table)), ]
  attach1$id_col <- c(1:nrow(single_table))
  single_table$id_col <- c(1:nrow(single_table))
  single_table <- merge(attach1, single_table[,-c(1,8)], by = "id_col")
  all_data_for_product <- rbind(all_data_for_product, single_table)
  }

  #cleaning column names
  column_names <- c("id_col")
  for (i in colnames(all_data_for_product)[2:10]) {col_name <- unlist(strsplit(i, "\r"))[1]
  column_names <- append(column_names, col_name)}
  colnames(all_data_for_product) <- column_names
  
  #Cleaning rest of the table - to edit
  kod <- c()
  kod_produktu <- c()
  
  for (i in all_data_for_product[,2]) {row <- unlist(strsplit(i, "\r"))
  kod <- append(kod, row[1])}
  all_data_for_product[,2] <- kod
  
  for (i in all_data_for_product[,5]) {row <- unlist(strsplit(i, "\r"))
  kod_produktu <- append(kod_produktu, row[1])}
  all_data_for_product[,5] <- kod_produktu
  
  # saving and nameing data file
  csv_file_name <- sprintf("%s_OW%s_%s", year, OW, prod_name)
  write.csv(all_data_for_product, csv_file_name, row.names = FALSE)}
