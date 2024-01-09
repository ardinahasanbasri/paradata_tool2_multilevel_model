# =============================================================================
# Install packages
# =============================================================================

# -----------------------------------------------------------------------------
# Install packages used for provisioning other packages
# -----------------------------------------------------------------------------

# for package installation
if (!require("pak")) {
    install.packages("pak")
}

# for iteration over list of packages
if (!require("purrr")) {
    install.packages("purrr")
}

if (!require("stringr")) {
  install.packages("stringr")
}

# Notes: stringr code has to be added. Susopara and susometa had to be manually installed. 

# -----------------------------------------------------------------------------
# Install any missing requirements
# -----------------------------------------------------------------------------

#' Install package if missing on system
#' 
#' @param package Character. Name of package to install.
install_if_missing <- function(package) {

    # strip out package name from repo address
    slash_pattern <- "\\/"
    if (stringr::str_detect(string = package, pattern = slash_pattern) ) {
        slash_position <- stringr::str_locate(
            string = package,
            pattern = slash_pattern
        )
        package <- stringr::str_sub(
            string = package,
            start = slash_position[[1]] + 1
        )
    }

    if (!require(package, character.only = TRUE)) {
        pak::pak(package)
    }

}

# enumerate packages required
required_packages <- c(
    # file management
    "here",
    "fs",
    # defensive programming, error messages
    "cli",
    "testit",
    # painless iteration
    "purrr",
    # data manipulation
    "dplyr",
    "data.table",
    "readr",
    "tidytable",
    # SuSo paradata and metadata
    "arthur-shaw/susopara",
    "lsms-worldbank/susometa",
    # compute statistics
    "mosaic",
    # compose charts
    "ggplot2",
    "plotly",
    # compose display tables
    "gt",
    "reactable", 
    "reactablefmtr",
    "scales",
    # ingest Stata data
    "haven",
    # multi-level model
    "lme4",
    "performance",
    # create initial report
    "quarto",
    "htmltools",
    "crosstalk"
)

# install any missing requirements
purrr::walk(
    .x = required_packages,
    .f = ~ install_if_missing(.x)
)
# =============================================================================
# Load packages where functions cannot be namespaced
# =============================================================================

library(dplyr)

# =============================================================================
# Load internal functions
# =============================================================================

