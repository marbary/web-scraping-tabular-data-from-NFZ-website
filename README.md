# web-scraping-product-cost-data-from-NFZ-website
product_dataset() is a function for scraping health-products-cost-data from multiple locations within Polish NFZ-s Contract Information Register (https://www.nfz.gov.pl/o-nfz/informator-o-zawartych-umowach/) for convenient health market analysis. The function agruments are: "year", "OW", "prod_name" which stand for: "year", "Provincial Branches of the National Health Fund's code" and "name of contracted product" respectively. The functions return a csv file with comprehensive dataset for further analysis.
For exaple, after sourcing my script "provider_product_data.R" into you R session, try: provider_product_data("2019", "01", "tlenoterapia+domowa"). 
If you want to find relevant data for a wider scope of time (years), make a function mapping, for expamle if you want to get data about "tlenoterapia+domowa" for "01" Provincial Branches of the National Health Fund's code from year 2012 to 2018, do this:
> source("/place/where/you/downloaded/script/product_dataset.R")

> years <- c("2012", "2013", "2014", "2015", "2016", "2017", "2018")

> for (year in years) {provider_product_data(year, "01", "tlenoterapia+domowa")} 

You can also mapp this function in different ways depending on what dataset you need to get.
