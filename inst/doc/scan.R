## ----setup, include = FALSE---------------------------------------------------
# global knitting options for code rendering
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>")

## ---- message=FALSE-----------------------------------------------------------
# load isoreader package
library(isoreader)

## ---- message=FALSE-----------------------------------------------------------
# all available examples
iso_get_reader_examples() %>% knitr::kable()

## -----------------------------------------------------------------------------
# read scan examples
scan_files <-
  iso_read_scan(
    iso_get_reader_example("peak_shape_scan_example.scn"),
    iso_get_reader_example("background_scan_example.scn"),
    iso_get_reader_example("full_scan_example.scn"),
    iso_get_reader_example("time_scan_example.scn")
  )

## -----------------------------------------------------------------------------
scan_files %>% iso_get_data_summary() %>% knitr::kable()

## -----------------------------------------------------------------------------
scan_files %>% iso_get_problems_summary() %>% knitr::kable()
scan_files %>% iso_get_problems() %>% knitr::kable()

## -----------------------------------------------------------------------------
# all file information
scan_files %>% iso_get_file_info(select = c(-file_root)) %>% knitr::kable()

## -----------------------------------------------------------------------------
# select + rename specific file info columns
scan_files2 <- scan_files %>%
  iso_select_file_info(-file_root) %>%
  iso_rename_file_info(`Date & Time` = file_datetime)

# fetch all file info
scan_files2 %>% iso_get_file_info() %>% knitr::kable()

## -----------------------------------------------------------------------------
# find files that have 'CIT' in the new ID field
scan_files2 %>%
  iso_filter_files(type == "High Voltage") %>%
  iso_get_file_info() %>%
  knitr::kable()

## -----------------------------------------------------------------------------
scan_files3 <- scan_files2 %>%
  iso_mutate_file_info(
    # introduce new column
    `Run in 2019?` = `Date & Time` > "2019-01-01" & `Date & Time` < "2020-01-01"
  )

scan_files3 %>%
  iso_get_file_info() %>%
  knitr::kable()

## -----------------------------------------------------------------------------
scan_files %>% iso_get_resistors() %>% knitr::kable()

## -----------------------------------------------------------------------------
# get raw data with default selections (all raw data, no additional file info)
scan_files %>% iso_get_raw_data() %>% head(n=10) %>% knitr::kable()
# get specific raw data and add some file information
scan_files %>%
  iso_get_raw_data(
    # select just time and the two ions
    select = c(x, x_units, v44.mV, v45.mV),
    # include the scan type and rename the column
    include_file_info = c(`Scan Type` = type)
  ) %>%
  # look at first few records only
  head(n=10) %>% knitr::kable()

## -----------------------------------------------------------------------------
all_data <- scan_files %>% iso_get_all_data()
# not printed out because this data frame is very big

## -----------------------------------------------------------------------------
# export to R data archive
scan_files %>% iso_save("scan_files_export.scan.rds")

# read back the exported R data storage
iso_read_scan("scan_files_export.scan.rds")

## -----------------------------------------------------------------------------
# export to excel
scan_files %>% iso_export_to_excel("scan_files_export")

# data sheets available in the exported data file:
readxl::excel_sheets("scan_files_export.scan.xlsx")

## -----------------------------------------------------------------------------
# export to feather
scan_files %>% iso_export_to_feather("scan_files_export")

# exported feather files
list.files(pattern = ".scan.feather")

