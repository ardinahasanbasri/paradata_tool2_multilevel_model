#-------------------------------------------------------------
# Step 1: Clean "responsible" to get interviewer identifier. 
#-------------------------------------------------------------

unique(data[,responsible])

data <- data[responsible!="", ] # Drop responsible that is missing, can also clean other responsible values if needed. 

# Some responsible are missing, but these are only for the event "AnsweredRemoved" and can be ignored. 

# Keep only household modules. 
data <- data[ind_mod==0, ]

#------------------------------------------------------------------------------------
# Step 2: Calculate time per per-person/household module and replace
#------------------------------------------------------------------------------------

# Aggregate the data into per-person module time. 

data <- data[ ,list(tot_minutes=sum(elapsed_min)), by=c("interview__id", "section", "responsible", "person_ID")] 

#-------------------------------------------
# Step 3: Add controls from Stata datafiles 
#-------------------------------------------

# In the 03_microdata folder, create interview_id_merge.dta
# The file consist of interview__id and interview__key data that merges paradata with survey data

setwd(here::here("data", "03_microdata")) 
ID <- haven::read_dta("interview_id_merge.dta")

# Now add individual and household characteristics. 
data_add_hh <- data.table::fread("covar_hh.csv")

#----------------------------------------------------------------------
# This function checks for column present in the datasets that's added

check_column_present <- function(df, colname) {
  if (!colname %in% names(data)) {
    cli::cli_abort(
      message = c(
        "Expected variable missing from data.",
        "x" = "Cannot find {.var {colname}} in dataset."
      ),
      call = rlang::caller_env()
    )
  } 
}
#------------------------------------------------------------------------

# Before merging check that required columns are present
# ID variables
check_column_present(df = ID, colname = "interview__id")
check_column_present(df = data_add_hh, colname = "person_ID")
# outcome variable
check_column_present(df = data, colname = "tot_minutes")
# attribute variables
#check_column_present(df = ID, colname = "area") # doesn't work even if its there
check_column_present(df = data, colname = "responsible")

data <- merge(data, ID)
data <- merge(data, data_add_hh, by=c("interview__key")) 

#------------------------------------------------------------------------------------
# Step 4: Conduct multi-level model with lmer command
#------------------------------------------------------------------------------------

data[, unique_id := .GRP, by=.(interview__id, person_ID)] # Create unique household and ind id

# Save dataset ready for use. 
data.table::fwrite(
  data, 
  file = fs::path(here::here("data", "04_created", "data_hh_sections.csv"))
)
