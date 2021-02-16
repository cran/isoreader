## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- message=FALSE-----------------------------------------------------------
# load isoreader package
library(isoreader)

## ---- message = FALSE---------------------------------------------------------
# all available examples
iso_get_reader_examples() %>% knitr::kable()

## -----------------------------------------------------------------------------
# read a few of the continuous flow examples
cf_files <-
  iso_read_continuous_flow(
    iso_get_reader_example("continuous_flow_example.cf"),
    iso_get_reader_example("continuous_flow_example.iarc"),
    iso_get_reader_example("continuous_flow_example.dxf")
  )

## -----------------------------------------------------------------------------
cf_files %>% iso_get_data_summary() %>% knitr::kable()

## -----------------------------------------------------------------------------
cf_files %>% iso_get_problems_summary() %>% knitr::kable()
cf_files %>% iso_get_problems() %>% knitr::kable()

## -----------------------------------------------------------------------------
# all file information
cf_files %>% iso_get_file_info(select = c(-file_root)) %>% knitr::kable()
# select file information
cf_files %>%
  iso_get_file_info(
    select = c(
       # rename sample id columns from the different file types to a new ID column
      ID = `Identifier 1`, ID = `Name`,
      # select columns without renaming
      Analysis, `Peak Center`, `H3 Factor`,
      # select the time stamp and rename it to `Date & Time`
      `Date & Time` = file_datetime
    ),
    # explicitly allow for file specific rename (for the new ID column)
    file_specific = TRUE
  ) %>% knitr::kable()

## -----------------------------------------------------------------------------
# select + rename specific file info columns
cf_files2 <- cf_files %>%
  iso_select_file_info(
    ID = `Identifier 1`, ID = `Name`, Analysis, `Peak Center`, `H3 Factor`,
    `Date & Time` = file_datetime,
    # recode to the same name in different files
    `Sample Weight` = `Identifier 2`, `Sample Weight` = `EA Sample Weight`,
    file_specific = TRUE
  )

# fetch all file info
cf_files2 %>% iso_get_file_info() %>% knitr::kable()

## -----------------------------------------------------------------------------
# find files that have 'acetanilide' in the new ID field
cf_files2 %>% iso_filter_files(grepl("acetanilide", ID)) %>%
  iso_get_file_info() %>%
  knitr::kable()

# find files that were run since 2015
cf_files2 %>%
  iso_filter_files(`Date & Time` > "2015-01-01") %>%
  iso_get_file_info() %>%
  knitr::kable()

## -----------------------------------------------------------------------------
cf_files3 <-
  cf_files2 %>%
  iso_mutate_file_info(
    # update existing column
    ID = paste("ID:", ID),
    # introduce new column
    `Run since 2015?` = `Date & Time` > "2015-01-01",
    # parse weight as a number and turn into a column with units
    `Sample Weight` = `Sample Weight` %>% parse_number() %>% iso_with_units("mg")
  )

cf_files3 %>%
  iso_get_file_info() %>%
  iso_make_units_explicit() %>%
  knitr::kable()

## -----------------------------------------------------------------------------
# this kind of information data frame is frequently read in from a csv or xlsx file
new_info <-
  dplyr::bind_rows(
    # new information based on new vs. old samples
    dplyr::tribble(
      ~file_id, ~`Run since 2015?`,  ~process,  ~info,
       NA,       TRUE,                "yes",     "new runs",
       NA,       FALSE,               "yes",     "old runs"
    ),
    # new information for a single specific file
    dplyr::tribble(
      ~file_id,        ~process,  ~note,
       "6617_IAEA600",  "no",      "did not inject properly"
    )
  )
new_info %>% knitr::kable()

# adding it to the isofiles
cf_files3 %>%
  iso_add_file_info(new_info, by1 = "Run since 2015?", by2 = "file_id") %>%
  iso_get_file_info(select = !!names(new_info)) %>%
  knitr::kable()

## -----------------------------------------------------------------------------
# use parsing and extraction in iso_mutate_file_info
cf_files2 %>%
  iso_mutate_file_info(
    # change type of Peak Center to logical
    `Peak Center` = parse_logical(`Peak Center`),
    # retrieve first word of file_id
    file_id_1st = extract_word(file_id),
    # retrieve second word of ID column
    file_id_2nd = extract_word(file_id, 2),
    # retrieve file extension from the file_id using regular expression
    name = extract_substring(ID, "(\\w+)-?(.*)?", capture_bracket = 1)
  ) %>%
  iso_get_file_info(select = c(matches("file_id"), ID, name, `Peak Center`)) %>%
  knitr::kable()

# use parsing in iso_filter_file_info
cf_files2 %>%
  iso_filter_files(parse_number(`H3 Factor`) > 2) %>%
  iso_get_file_info() %>%
  knitr::kable()

# use iso_parse_file_info for simplified parsing of column data types
cf_files2 %>%
  iso_parse_file_info(
    integer = Analysis,
    number = `H3 Factor`,
    logical = `Peak Center`
  ) %>%
  iso_get_file_info() %>%
  knitr::kable()

## -----------------------------------------------------------------------------
cf_files %>% iso_get_resistors() %>% knitr::kable()

## -----------------------------------------------------------------------------
# reference delta values without ratio values
cf_files %>% iso_get_standards(file_id:reference) %>% knitr::kable()
# reference values with ratios
cf_files %>% iso_get_standards() %>% knitr::kable()

## -----------------------------------------------------------------------------
# get raw data with default selections (all raw data, no additional file info)
cf_files %>% iso_get_raw_data() %>% head(n=10) %>% knitr::kable()
# get specific raw data and add some file information
cf_files %>%
  iso_get_raw_data(
    # select just time and the m/z 2 and 3 ions
    select = c(time.s, v2.mV, v3.mV),
    # include the Analysis number fron the file info and rename it to 'run'
    include_file_info = c(run = Analysis)
  ) %>%
  # look at first few records only
  head(n=10) %>% knitr::kable()

## -----------------------------------------------------------------------------
# entire vendor data table
cf_files %>% iso_get_vendor_data_table() %>% knitr::kable()
# get specific parts and add some file information
cf_files %>%
  iso_get_vendor_data_table(
    # select peak number, ret. time, overall intensity and all H delta columns
    select = c(Nr., Rt, area = `rIntensity All`, matches("^d \\d+H")),
    # include the Analysis number fron the file info and rename it to 'run'
    include_file_info = c(run = Analysis)
  ) %>%
  knitr::kable()

# the data table also provides units if included in the original data file
# which can be made explicit using the function iso_make_units_explicit()
cf_files %>%
  iso_get_vendor_data_table(
    # select peak number, ret. time, overall intensity and all H delta columns
    select = c(Nr., Rt, area = `rIntensity All`, matches("^d \\d+H")),
    # include the Analysis number fron the file info and rename it to 'run'
    include_file_info = c(run = Analysis)
  ) %>%
  # make column units explicit
  iso_make_units_explicit() %>%
  knitr::kable()

## -----------------------------------------------------------------------------
all_data <- cf_files %>% iso_get_all_data()
# not printed out because this data frame is very big

## -----------------------------------------------------------------------------
# export to R data archive
cf_files %>% iso_save("cf_files_export.cf.rds")

# read back the exported R data archive
cf_files <- iso_read_continuous_flow("cf_files_export.cf.rds")
cf_files %>% iso_get_data_summary() %>% knitr::kable()

## -----------------------------------------------------------------------------
# export to excel
cf_files %>% iso_export_to_excel("cf_files_export")

# data sheets available in the exported data file:
readxl::excel_sheets("cf_files_export.cf.xlsx")

## -----------------------------------------------------------------------------
# export to feather
cf_files %>% iso_export_to_feather("cf_files_export")

# exported feather files
list.files(pattern = ".cf.feather")

