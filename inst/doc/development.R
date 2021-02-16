## ----setup, include = FALSE---------------------------------------------------
library(isoreader)
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
new_reader <- function(ds, options = list()) {
  isoreader:::log_message("this is the new reader!")
  str(ds)
  return(ds)
}

# register new reader
readers <- iso_register_dual_inlet_file_reader(".new.did", "new_reader")
knitr::kable(readers)

# copy an example file from the package with the new extension
iso_get_reader_example("dual_inlet_example.did") %>% file.copy(to = "example.new.did")

# read the file
iso_read_dual_inlet("example.new.did", read_cache = FALSE)
file.remove("example.new.did")

## -----------------------------------------------------------------------------
isoreader:::set_read_file_event_expr({
  isoreader:::log_message(sprintf("starting file #%.d, named '%s'", file_n, basename(path)))
})
isoreader:::set_finish_file_event_expr({
  isoreader:::log_message(sprintf("finished file #%.d", file_n))
})

c(
  iso_get_reader_example("dual_inlet_example.did"),
  iso_get_reader_example("dual_inlet_example.caf")
) %>% iso_read_dual_inlet(read_cache = FALSE)

isoreader:::initialize_options() # reset all isoreader options

## -----------------------------------------------------------------------------
# turn on debug mode
isoreader:::iso_turn_debug_on()
# read example file
ex <- iso_get_reader_example("dual_inlet_example.did") %>%  
  iso_read_dual_inlet(quiet = TRUE)
# access binary
bin <- ex$binary
# use structure mapping
bin %>%
  isoreader:::move_to_pos(1340) %>%
  isoreader:::map_binary_structure(length = 200)

## -----------------------------------------------------------------------------
isoreader:::get_ctrl_blocks_config_df()

## -----------------------------------------------------------------------------
bin$C_blocks

## -----------------------------------------------------------------------------
bin %>%
  isoreader:::move_to_C_block("CMethod") %>%
  isoreader:::map_binary_structure(length = 200)

