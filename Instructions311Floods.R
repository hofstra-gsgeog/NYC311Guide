# 311 Reports Aggregation from NYC OpenData
# instructions by ND Lucchetto
# nlucchetto1@pride.hofstra.edu


# LOAD BELOW FIRST! :)
install.packages("dplyr")
install.packages("RSocrata")
install.packages("writexl")

library(dplyr) 
library(RSocrata) 
library(writexl)


# 311 Data Page: https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2010-to-Present/erm2-nwe9/about_data

# IMPORTANT: I used NYC OpenData's online query tool to filter for only Queens data from 2023. I would recommend doing this to shrink the file size before importing, but alternatively filtering through R is possible (see below).

# Warning: Imports from NYC OpenData come w/ limit of 776,874 rows.
  # If you want to import your NYCOD query thru the API Endpoint (instead of downloading), you will need to add "&$limit=[# of queried rows + 1]" to the end of the URL.
  # Downloading .csv = easier, but takes more time
# QUERY: Queens only, 1/1/23 @ 12:00 AM to 12/31/23 @ 11:59:59PM


# Importing data to dataframe "reports311"
# Remember to remove brackets
reports311 <- read.csv("[file or URL]")


# Filtering flood reports & flood indicators separately (!)
  # Uses mutate function to create Y/M/D columns from the "Created.Date" field in reports311
# Below code uses dplyr library
# "|" = OR, "&" = AND

  # FLOOD REPORTS
rep_floods <- reports311 %>%
  filter(Agency.Name=="Department of Transportation" | Agency.Name=="Department of Environmental Protection") %>%
  filter(Descriptor=="Highway Flooding (SH)" | Descriptor=="Street Flooding (SJ)" | Descriptor=="Flooding on Highway" | Descriptor=="Flooding on Street") %>%
#Run below with above code only if you didn't query for your Borough on NYCOD's website first.
  # filter(Borough=="[Your Borough Here]")

  rep_floods <- rep_floods %>%
  mutate(Y = substring(rep_floods$Created.Date,9,10),
         M = substring(rep_floods$Created.Date,1,2),
         D = substring(rep_floods$Created.Date,4,5))
#Run below only if you didn't query for 2023 on NYCOD's website first.
  # rep_floods <- rep_floods %>%  
    # filter(Y=="23")

  # FLOOD INDICATORS 
rep_indicators <- reports311 %>%
  filter(Agency.Name=="Department of Environmental Protection") %>%
  filter(Descriptor=="Sewer Backup (Use Comments) (SA)" | Descriptor=="Catch Basin Clogged/Flooding (Use Comments) (SC)" | Descriptor=="Manhole Overflow (Use Comments) (SA1)" | Descriptor=="Backup" | Descriptor=="Catch Basin Clogged") %>%
  mutate(Y = substring(rep_indicators$Created.Date,9,10),
         M = substring(rep_indicators$Created.Date,1,2),
         D = substring(rep_indicators$Created.Date,4,5))


# Data exported --> Excel
# Remember to remove brackets

write_xlsx(rep_floods, "[Your filepath here]")
write_xlsx(rep_indicators, "[Your filepath here]")


# In excel: table split into tabs by month ; duplicates removed in each month w/ Remove Duplicates tool
  # Remove Duplicates tool: Incident.Address and Location fields selected simultaneously.
