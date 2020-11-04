## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- message=FALSE-----------------------------------------------------------
# load isoreader package
library(isoreader)

## -----------------------------------------------------------------------------
# all available examples
iso_get_reader_examples() %>% rmarkdown::paged_table()

## -----------------------------------------------------------------------------
# read all available examples
di_files <- iso_read_dual_inlet(iso_get_reader_examples_folder())

# save as r data storage (read back in with iso_read_dual_inlet)
iso_save(di_files, filepath = "di_save")

# export to excel
iso_export_to_excel(di_files, filepath = "di_export")

## -----------------------------------------------------------------------------
# read all available examples
cf_files <- iso_read_continuous_flow(iso_get_reader_examples_folder())

# save as r data storage (read back in with iso_read_continuous_flow)
iso_save(cf_files, filepath = "cf_save")

# export to excel
iso_export_to_excel(cf_files, filepath = "cf_export")

## -----------------------------------------------------------------------------
# read all available examples
scan_files <- iso_read_scan(iso_get_reader_examples_folder())

# save as r data storage (read back in with iso_read_scan)
iso_save(scan_files, filepath = "scan_save")

# export to excel
iso_export_to_excel(scan_files, filepath = "scan_export")

