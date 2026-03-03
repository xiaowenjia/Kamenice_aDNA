library(magrittr)

kernel_grid <- purrr::map_dfr(
  list.files(
    path = "/mnt/archgen/users/xiaowen/Kamenice/1024/mobest/para_prep/hpc_crossvalidation021225WE",
    pattern = "*.csv",
    full.names = TRUE
  ),
  function(x) {
    readr::read_csv(x, show_col_types = FALSE)
  }
)

kernel_grid %>%
  dplyr::group_by(dependent_var_id) %>%
  dplyr::slice_min(order_by = mean_squared_difference, n = 1) %>%
  dplyr::ungroup()