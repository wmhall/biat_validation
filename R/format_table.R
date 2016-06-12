
fixed_digits <- function(xs, n = 2) {
  formatC(xs, digits = n, format = "f")
}

fixed_zero <- . %>%  fixed_digits(n=0)

remove_leading_zero <- function(xs) {
  # Problem if any value is greater than 1.0
  digit_matters <- xs %>% as.numeric %>%
    abs %>% magrittr::is_greater_than(1)
  if (any(digit_matters, na.rm =T)) {
    warning("Non-zero leading digit")
  }
  stringr::str_replace(xs, "^(-?)0", "\\1")
}


format_pval <- function(ps) {
  v_tiny <- "< .001"
  #tiny <- "<.01"
  #v_small <- "<.05"
  
  ps_chr <- ps %>% fixed_digits(3) %>%
    remove_leading_zero
  #ps_chr[ps < 0.05] <- v_small
  #ps_chr[ps < 0.01] <- tiny
  ps_chr[ps < 0.001] <- v_tiny
  ps_chr
}
