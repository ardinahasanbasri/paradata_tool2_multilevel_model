# =============================================================================
# Create report for running a basic model multi-level model by survey modules
# =============================================================================

# To run this report, you will need to have a paradata_clean.csv file ready. 
# For instructions on how to create this file, go to Tool 1: Paradata Module Stats. 

# -----------------------------------------------------------------------------
# 1) Load Required Packages
# -----------------------------------------------------------------------------

# load packages and functions
source("R/0_load_requirements.R")

# -----------------------------------------------------------------------------
# 2) Create Household-Level Module Dataset 
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# 3) Create Individual-Level Module Dataset
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# 4) Output Report
# -----------------------------------------------------------------------------

quarto::quarto_render(input = "R/Paradata_Report_Multilevel_Model.qmd")

fs::file_move(
    path = "R/Paradata_Report_Multilevel_Model.html",
    new_path = "data/04_created/Paradata_Report_Multilevel_Model.html"
)

# Your report is ready in the new path specified. 
