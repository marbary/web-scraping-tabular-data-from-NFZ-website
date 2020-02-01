OW_provider_product_data <- function(year, OW, prod_name) {
  
  #required_packages
  required_pkgs <- c("stringr", "rvest", "magrittr", "dplyr")
  for (pkg in required_pkgs) {
    if (pkg %in% rownames(installed.packages()) == FALSE)
    {install.packages(pkg)}
    if (pkg %in% rownames(.packages()) == FALSE)
    {library(pkg, character.only = TRUE)}
  }
  
  base_url <- "https://aplikacje.nfz.gov.pl/umowy/Provider/Index?ROK=%s&OW=%s&ServiceType=00&Code=&Name=&City=&Nip=&Regon=&Product=%s&OrthopedicSupply=false"
  formatted_base_url <- sprintf(base_url, year, OW, prod_name)
  
  #scraping services provider data (ID; name; localization)
  service_providers <- formatted_base_url %>% read_html() %>% html_node("table") %>% html_table()
  service_providers <- service_providers[c(2:4, 9)]
  #scraping voivodeship center and a year information
  VC_year <- formatted_base_url %>% read_html() %>% html_nodes(".row:nth-child(-n+2) .filter-val") %>% html_text()
  VC_year <- data.frame(year = VC_year[1], OW_name = VC_year[2])
  
  prefix <- "https://aplikacje.nfz.gov.pl"
  hrefs_for2layers <- paste(prefix, formatted_base_url %>% read_html() %>%
                              html_nodes(".hidden-sm+ td a") %>%
                              html_attr("href"), sep = "")
  
  data_update_date <- data.frame()
  hrefs_for3layers <- c()
  for (i in hrefs_for2layers) {
  href <- read_html(i) %>% html_nodes("td a") %>% html_attr("href")
  hrefs_for3layers <- append(hrefs_for3layers, paste(prefix, href, sep = ""))
  update_date <- read_html(i) %>% html_node("table") %>% html_table()
  data_update_date <- unlist(append(data_update_date, update_date[7])) # try to change data type to dataframe with date-time values
  }
  service_providers$data_update <- data_update_date
  
  #SCRAPING
  all_data_for_product <- data.frame()
  count <- 0
  for (i in hrefs_for3layers) {single_table <- read_html(i) %>% html_node("table") %>% html_table(header = TRUE)
  count<- count + 1
  attach <- service_providers[count,]
  attach1 <- attach[rep(seq_len(nrow(attach)), each = nrow(single_table)), ]
  attach1$id_col <- c(1:nrow(single_table))
  attach2 <- VC_year[rep(seq_len(nrow(VC_year)), each = nrow(single_table)),]
  attach2$id_col <- c(1:nrow(single_table))
  
  single_table$id_col <- c(1:nrow(single_table))
  single_table <- merge(attach2, merge(attach1, single_table[,-c(1,8)], by = "id_col"), by = "id_col")
  all_data_for_product <- rbind(all_data_for_product, single_table)
  }
  
  #add a script for new id "id_col" column
  ID <- c(1:nrow(all_data_for_product))
  all_data_for_product[1] <- ID
  
  #cleaning column names
  column_names <- c("ID", "Rok", "Osrodek_woj")
  for (i in colnames(all_data_for_product)[4:ncol(all_data_for_product)]) {col_name <- gsub(pattern = " ", replacement = "_", unlist(strsplit(i, "\r"))[1])
  column_names <- append(column_names, col_name)}
  colnames(all_data_for_product) <- column_names
  
  #Cleaning rest of the table - to edit
  kod <- c()
  kod_produktu <- c()
  
  for (i in all_data_for_product[,4]) {row <- unlist(strsplit(i, "\r"))
  kod <- append(kod, row[1])}
  all_data_for_product[,4] <- kod
  
  for (i in all_data_for_product[,7]) {row <- unlist(strsplit(i, "\r"))
  kod_produktu <- append(kod_produktu, row[1])}
  all_data_for_product[,7] <- kod_produktu
  
  #filter records with product - prod_name
  all_data_for_product1 <- as_tibble(all_data_for_product)
  all_product_data <- tibble()
  all_product_data <- filter(all_data_for_product1, Nazwa_produktu_kontraktowanego == gsub(pattern = "\\+", replacement = " ", toupper(prod_name)))
  
  # saving and nameing data
  Date_time <- format(Sys.time(), "%d-%m-%Y_%X")
  csv_file_name <- paste0(sprintf("%s_OW%s_%s", year, OW, prod_name), Date_time, sep = "")
  write.csv(all_product_data, csv_file_name, row.names = FALSE)}
