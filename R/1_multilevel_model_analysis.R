# Directory of Dataset # 

setwd(here::here("data", "04_created")) 
data <- data.table::fread("paradata_clean.csv") # Get clean data. 

# Show only 4 numbers, the total and share of each component instead of the total. 

#-------------------------------------------------------------
# Step 1: Clean "responsible" to get interviewer identifier. 
#-------------------------------------------------------------

unique(data[,responsible])

data <- data[responsible!="", ] # Drop responsible that is missing, can also clean other responsible values if needed. 

# Some responsible are missing, but these are only for the event "AnsweredRemoved" and can be ignored. 

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

data_add    <- data.table::fread("covar_ind.csv")
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
# check_column_present(df = ID, colname = "area") # The column is in the dataset, not sure what is going on here. 
check_column_present(df = data, colname = "responsible")

data <- merge(data, ID)
data <- merge(data, data_add, by=c("interview__key", "person_ID")) # did not include #x.all=TRUE since want to compare different models with the same obs. Reduction of obs is quite small. 
data <- merge(data, data_add_hh, by=c("interview__key")) 

#------------------------------------------------------------------------------------
# Step 4: Conduct multi-level model with lmer command
#------------------------------------------------------------------------------------

data[, tot_minutes:=scale(tot_minutes)] # Normalized total minutes

data[, unique_id := .GRP, by=.(interview__id, person_ID)] # Create unique household and ind id

section_list <- unique(data$section)

# Delete certain sections where you don't want the model to run.  
# Apartment section has too few obs and thus have to be deleted. Position 13 is deleted and new list is saved.    

section_list <- section_list[-13] 

model_name  <-section_list
model_label <-section_list

#model_label  <- c("ind_available", "edu", "internal migration", "international migration", "livestock", "durables", 
#                   "mobile phones", "fin assets", "health", "employment", "ind land", "time use")

# Run for each module: unique(data$module)
for (x in 1:length(section_list)) {
Model <- lme4::lmer(tot_minutes ~ 1 + (1|responsible)  + (1|area), REML=FALSE, data=data[section==section_list[x],])
assign(model_name[x], Model)
}
rm(Model)

#-----------------------------------------------------------------
# Step 5: Saving important statistics and make accessible outputs 
#-----------------------------------------------------------------

stats_basic <- data.frame(c("area", "responsible", "residual", "area/total", "responsible/total"))

# Get statistics of remaining models.  

for (x in model_name) {
  var   <- data.frame(lme4::VarCorr(get(x)))
  icc   <- performance::icc(get(x), by_group = TRUE)
  aux   <- data.frame(mapply(c, var[c(1,4)], icc))
  stats_basic <- cbind(stats_basic, aux[2])
}
names(stats_basic) <- c("statistics", model_label)

#-----------------------------------------------------------------
# Step 6: Ready to Analyze Results 
#-----------------------------------------------------------------

# Reshape the data and make numeric. 

# For basic model
stats_basic2 <- setNames(data.frame(t(stats_basic[,-1])), stats_basic[,1])
stats_basic2 <- mutate_at(stats_basic2, 1:5, as.numeric)
stats_basic2["Sum of Variances"] <- stats_basic2["area"] + stats_basic2["responsible"] + stats_basic2["residual"] 
stats_basic2["ICC area"]  <- stats_basic2["area"]/(stats_basic2["responsible"] + stats_basic2["area"]) 
stats_basic2["ICC responsible"]  <- stats_basic2["responsible"]/(stats_basic2["responsible"] + stats_basic2["area"]) 

stats_basic2 <- mutate_if(stats_basic2, is.numeric, round, digits = 3)

reactable_theme <- reactable::reactableTheme(
  borderColor = "#dfe2e5",
  stripedColor = "#f6f8fa",
  highlightColor = "#B0D4F3",
  cellPadding = "8px 12px",
  style = list(
    fontFamily = "-apple-system, BlinkMacSystemFont, Segoe UI, Helvetica, Arial, sans-serif"
  ),
  searchInputStyle = list(width = "100%")
)

stats_basic2 %>%
  reactable::reactable(
    defaultSorted = c("Sum of Variances"),
    defaultColDef = reactable::colDef(
      format = reactable::colFormat(digits = 2)
    ),
    columns = list(
      'total var' = reactable::colDef(
        name="total var", 
        cell =  reactablefmtr::data_bars(
          fill_color = "#FDB833", 
          stats_basic2, 
          text_position = "outside-base", 
          round_edges = TRUE,
          number_fmt = scales::number_format(accuracy = 0.1)
        ),
        defaultSortOrder = "desc"
      )), 
    searchable = TRUE,
    striped = TRUE,
    showSortable = TRUE,
    highlight = TRUE,
    bordered = TRUE,
    theme = reactable_theme
  )


#require(gridExtra)
#fig1_all <- grid.arrange(plot(Model_s01), plot(Model_s02), plot(Model_s03), plot(Model_s04),
#                         plot(Model_s05), plot(Model_s06), plot(Model_s07), plot(Model_s08),
#                         plot(Model_s09), plot(Model_s10), plot(Model_s11), 
#                         ncol = 4, nrow = 3)
