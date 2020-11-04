## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- message=FALSE-----------------------------------------------------------
# load isoreader package
library(isoreader)

## -----------------------------------------------------------------------------
# list all suported file types
iso_get_supported_file_types() %>%
  dplyr::select(extension, software, description, type) %>%
  knitr::kable()

## -----------------------------------------------------------------------------
# read a file in the default verbose mode
iso_get_reader_example("dual_inlet_example.did") %>%
  iso_read_dual_inlet() %>%
  iso_select_file_info(file_datetime, `Identifier 1`) %>%
  iso_get_file_info() %>%
  knitr::kable()

# read the same file but make the read process quiet
iso_get_reader_example("dual_inlet_example.did") %>%
  iso_read_dual_inlet(quiet = TRUE) %>%
  iso_select_file_info(file_datetime, `Identifier 1`) %>%
  iso_get_file_info() %>%
  knitr::kable()

# read the same file but turn all isoreader messages off
iso_turn_info_messages_off()
iso_get_reader_example("dual_inlet_example.did") %>%
  iso_read_dual_inlet(quiet = TRUE) %>%
  iso_select_file_info(file_datetime, `Identifier 1`) %>%
  iso_get_file_info() %>%
  knitr::kable()

# turn message back on
iso_turn_info_messages_on()

## -----------------------------------------------------------------------------
# cleanup reader cache
iso_cleanup_reader_cache()

# read a new file (notice the time elapsed)
cf_file <- iso_get_reader_example("continuous_flow_example.dxf") %>%
  iso_read_continuous_flow()

# re-read the same file much faster (it will be read from cache)
cf_file <- iso_get_reader_example("continuous_flow_example.dxf") %>%
    iso_read_continuous_flow()

# turn reader caching off
iso_turn_reader_caching_off()

# re-read the same file (it will NOT be read from cache)
cf_file <- iso_get_reader_example("continuous_flow_example.dxf") %>%
  iso_read_continuous_flow()

# turn reader caching back on
iso_turn_reader_caching_on()

## -----------------------------------------------------------------------------
# read 3 files in parallel (note that this is usually not a large enough file number to be worth it)
di_files <-
  iso_read_dual_inlet(
    iso_get_reader_example("dual_inlet_example.did"),
    iso_get_reader_example("dual_inlet_example.caf"),
    iso_get_reader_example("dual_inlet_nu_example.txt"),
    nu_masses = 49:44,
    parallel = TRUE
  )

## -----------------------------------------------------------------------------
# all 3 di_files read above
di_files

# only one of the files (by index)
di_files[[2]]

# only one of the files (by file_id)
di_files$dual_inlet_example.did

# a subset of the files (by index)
di_files[c(1,3)]

# a subset of the files (by file_id)
di_files[c("dual_inlet_example.did", "dual_inlet_example.caf")]

# same result using iso_filter_files (more flexible + verbose output)
di_files %>% iso_filter_files(
  file_id %in% c("dual_inlet_example.did", "dual_inlet_example.caf")
)

# recombining subset files
c(
  di_files[3],
  di_files[1]
)

## -----------------------------------------------------------------------------
# read two files, one of which is erroneous
iso_files <-
  iso_read_continuous_flow(
    iso_get_reader_example("continuous_flow_example.dxf"),
    system.file("errdata", "cf_without_data.dxf", package = "isoreader")
  )

# retrieve problem summary
iso_files %>% iso_get_problems_summary() %>% knitr::kable()

# retrieve problem details
iso_files %>% iso_get_problems() %>% knitr::kable()

# filter out erroneous files
iso_files <- iso_files %>% iso_filter_files_with_problems()

## -----------------------------------------------------------------------------
# re-read the 3 dual inlet files from their original location if any have changed
di_files %>%
  iso_reread_changed_files()

# update the file_root for the files before re-read (in this case to a location
# that does not hold these files and hence will lead to a warning)
di_files %>%
  iso_set_file_root(root = ".") %>%
  iso_reread_all_files()

## -----------------------------------------------------------------------------
# strip all units
cf_file %>%
  iso_get_vendor_data_table(select = c(`Ampl 28`, `rIntensity 28`, `d 15N/14N`)) %>%
  iso_strip_units() %>% head(3)

# make units explicit
cf_file %>%
  iso_get_vendor_data_table(select = c(`Ampl 28`, `rIntensity 28`, `d 15N/14N`)) %>%
  iso_make_units_explicit() %>% head(3)

# introduce new unit columns e.g. in the file info
cf_file %>%
  iso_mutate_file_info(weight = iso_with_units(0.42, "mg")) %>%
  iso_get_vendor_data_table(select = c(`Ampl 28`, `rIntensity 28`, `d 15N/14N`),
                            include_file_info = weight) %>%
  iso_make_units_explicit() %>% head(3)

# or turn a column e.g. with custom format units in the header into implicit units
cf_file %>%
  iso_mutate_file_info(weight.mg = 0.42) %>%
  iso_get_vendor_data_table(select = c(`Ampl 28`, `rIntensity 28`, `d 15N/14N`),
                            include_file_info = weight.mg) %>%
  iso_make_units_implicit(prefix = ".", suffix = "") %>% head(3)

## -----------------------------------------------------------------------------
# concatenation example with single values
iso_format(
   pi = 3.14159,
   x = iso_with_units(42, "mg"),
   ID = "ABC",
   signif = 4,
   sep = " | "
)

# example inside a data frame
cf_file %>%
  iso_get_vendor_data_table(select = c(`Nr.`, `Ampl 28`, `d 15N/14N`)) %>%
  dplyr::select(-file_id) %>%
  head(3) %>%
  # introduce new label columns using iso_format
  dplyr::mutate(
    # default concatenation of values
    label_default = iso_format(
      `Nr.`, `Ampl 28`, `d 15N/14N`,
      sep = ", "
    ),
    # concatenate with custom names for each value
    label_named = iso_format(
      `#` = `Nr.`, A = `Ampl 28`, d15 = `d 15N/14N`,
      sep = ", "
    ),
    # concatenate just the values and increase significant digits
    label_value = iso_format(
      `Nr.`, `Ampl 28`, `d 15N/14N`,
      sep = ", ", format_names = NULL, signif = 6
    )
  )

