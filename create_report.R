# =============================================================================
# Create report for running a basic model multi-level model by survey modules
# =============================================================================

# To run this report, you will need to have a paradata_clean.csv file ready. 
# For instructions on how to create this file, go to Tool 1: Paradata Module Stats. 

# -----------------------------------------------------------------------------
# 1) Load Required Packages
# -----------------------------------------------------------------------------

setwd(here::here()) 

# load packages and functions
source("R/0_load_requirements.R")

# -----------------------------------------------------------------------------
# 2) Create Household-Level Module Dataset 
# -----------------------------------------------------------------------------

data <- data.table::fread("data/04_created/paradata_clean.csv") # Get clean data. 

# List sections that are household modules. 
unique(data$section[data$ind_mod==0])

# Delete modules that you would not like to include in the results. 
data <- data[section!="section name excluded", ]

source("1_multilevel_hh_data.R")

# -----------------------------------------------------------------------------
# 3) Create Individual-Level Module Dataset
# -----------------------------------------------------------------------------

data <- data.table::fread("paradata_clean.csv") # Get clean data. 

# List sections that are household modules. 
unique(data$section[data$ind_mod==1])

# Delete modules that you would not like to include in the results. 
data <- data[section!="18. Apartment", ]

source("2_multilevel_ind_data.R")

# -----------------------------------------------------------------------------
# 4) Output Report
# -----------------------------------------------------------------------------

quarto::quarto_render(input = "R/Paradata_Report_Multilevel_Model.qmd")

fs::file_move(
    path = "R/Paradata_Report_Multilevel_Model.html",
    new_path = "data/04_created/Paradata_Report_Multilevel_Model.html"
)

# Your report is ready in the new path specified. 
