## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- message=FALSE-----------------------------------------------------------
# load isoreader package
library(isoreader)

## ---- message=FALSE-----------------------------------------------------------
# all available examples
iso_get_reader_examples() %>% knitr::kable()

## -----------------------------------------------------------------------------
# read dual inlet examples
di_files <-
  iso_read_dual_inlet(
    iso_get_reader_example("dual_inlet_example.did"),
    iso_get_reader_example("dual_inlet_example.caf"),
    iso_get_reader_example("dual_inlet_nu_example.txt"),
    nu_masses = 49:44
  )

## -----------------------------------------------------------------------------
di_files %>% iso_get_data_summary() %>% knitr::kable()

## -----------------------------------------------------------------------------
di_files %>% iso_get_problems_summary() %>% knitr::kable()
di_files %>% iso_get_problems() %>% knitr::kable()

## -----------------------------------------------------------------------------
# all file information
di_files %>% iso_get_file_info(select = c(-file_root)) %>% knitr::kable()
# select file information
di_files %>%
  iso_get_file_info(
    select = c(
      # rename sample id columns from the different file types to a new ID column
      ID = `Identifier 1`, ID = `Sample Name`,
      # select columns without renaming
      Analysis, Method, `Peak Center`,
      # select the time stamp and rename it to `Date & Time`
      `Date & Time` = file_datetime,
      # rename weight columns from the different file types
      `Sample Weight`, `Sample Weight` = `Weight [mg]`
    ),
    # explicitly allow for file specific rename (for the new ID column)
    file_specific = TRUE
  ) %>% knitr::kable()

## -----------------------------------------------------------------------------
# select + rename specific file info columns
di_files2 <- di_files %>%
  iso_select_file_info(
    ID = `Identifier 1`, ID = `Sample Name`, Analysis, Method,
    `Peak Center`, `Date & Time` = file_datetime,
    `Sample Weight`, `Sample Weight` = `Weight [mg]`,
    file_specific = TRUE
  )

# fetch all file info
di_files2 %>% iso_get_file_info() %>% knitr::kable()

## -----------------------------------------------------------------------------
# find files that have 'CIT' in the new ID field
di_files2 %>% iso_filter_files(grepl("CIT", ID)) %>%
  iso_get_file_info() %>%
  knitr::kable()

# find files that were run in 2017
di_files2 %>%
  iso_filter_files(`Date & Time` > "2017-01-01" & `Date & Time` < "2018-01-01") %>%
  iso_get_file_info() %>%
  knitr::kable()

## -----------------------------------------------------------------------------
di_files3 <- di_files2 %>%
  iso_mutate_file_info(
    # update existing column
    ID = paste("ID:", ID),
    # introduce new column
    `Run in 2017?` = `Date & Time` > "2017-01-01" & `Date & Time` < "2018-01-01",
    # parse weight as a number and turn into a column with units
    `Sample Weight` = `Sample Weight` %>% parse_number() %>% iso_with_units("mg")
  )

di_files3 %>%
  iso_get_file_info() %>%
  iso_make_units_explicit() %>%
  knitr::kable()

## -----------------------------------------------------------------------------
# this kind of information data frame is frequently read in from a csv or xlsx file
new_info <-
  dplyr::bind_rows(
    # new information based on new vs. old samples
    dplyr::tribble(
      ~Analysis, ~`Run in 2017?`,  ~process,  ~info,
       NA,       TRUE,              "yes",     "2017 runs",
       NA,       FALSE,             "yes",     "other runs"
    ),
    # new information for a single specific file
    dplyr::tribble(
      ~Analysis, ~process,  ~note,
       "16068",   "no",      "did not inject properly"
    )
  )
new_info %>% knitr::kable()

# adding it to the isofiles
di_files3 %>%
  iso_add_file_info(new_info, by1 = "Run in 2017?", by2 = "Analysis") %>%
  iso_get_file_info(select = !!names(new_info)) %>%
  knitr::kable()

## -----------------------------------------------------------------------------
# use parsing and extraction in iso_mutate_file_info
di_files2 %>%
  iso_mutate_file_info(
    # change type of Peak Center to logical
    `Peak Center` = parse_logical(`Peak Center`),
    # retrieve first word of Method column
    Method_1st = extract_word(Method),
    # retrieve second word of Method column
    Method_2nd = extract_word(Method, 2),
    # retrieve file extension from the file_id using regular expression
    extension = extract_substring(file_id, "\\.(\\w+)$", capture_bracket = 1)
  ) %>%
  iso_get_file_info(select = c(extension, `Peak Center`, matches("Method"))) %>%
  knitr::kable()

# use parsing in iso_filter_file_info
di_files2 %>%
  iso_filter_files(parse_integer(Analysis) > 1500) %>%
  iso_get_file_info() %>%
  knitr::kable()

# use iso_parse_file_info for simplified parsing of column data types
di_files2 %>%
  iso_parse_file_info(
    integer = Analysis,
    number = `Sample Weight`,
    logical = `Peak Center`
  ) %>%
  iso_get_file_info() %>%
  knitr::kable()

## -----------------------------------------------------------------------------
di_files %>% iso_get_resistors() %>% knitr::kable()

## -----------------------------------------------------------------------------
# reference delta values without ratio values
di_files %>% iso_get_standards(file_id:reference) %>% knitr::kable()
# reference values with ratios
di_files %>% iso_get_standards() %>% knitr::kable()

## -----------------------------------------------------------------------------
# get raw data with default selections (all raw data, no additional file info)
di_files %>% iso_get_raw_data() %>% head(n=10) %>% knitr::kable()
# get specific raw data and add some file information
di_files %>%
  iso_get_raw_data(
    # select just time and the two ions
    select = c(type, cycle, v44.mV, v45.mV),
    # include the Analysis number fron the file info and rename it to 'run'
    include_file_info = c(run = Analysis)
  ) %>%
  # look at first few records only
  head(n=10) %>% knitr::kable()

## -----------------------------------------------------------------------------
# entire vendor data table
di_files %>% iso_get_vendor_data_table() %>% knitr::kable()
# get specific parts and add some file information
di_files %>%
  iso_get_vendor_data_table(
    # select cycle and all carbon columns
    select = c(cycle, matches("C")),
    # include the Identifier 1 fron the file info and rename it to 'id'
    include_file_info = c(id = `Identifier 1`)
  ) %>% knitr::kable()

## -----------------------------------------------------------------------------
all_data <- di_files %>% iso_get_all_data()
# not printed out because this data frame is very big

## -----------------------------------------------------------------------------
# export to R data archive
di_files %>% iso_save("di_files_export.di.rds")

# read back the exported R data storage
iso_read_dual_inlet("di_files_export.di.rds")

## -----------------------------------------------------------------------------
# export to excel
di_files %>% iso_export_to_excel("di_files_export")

# data sheets available in the exported data file:
readxl::excel_sheets("di_files_export.di.xlsx")

## -----------------------------------------------------------------------------
# export to feather
di_files %>% iso_export_to_feather("di_files_export")

# exported feather files
list.files(pattern = ".di.feather")

