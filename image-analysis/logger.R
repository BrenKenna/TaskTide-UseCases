#!/usr/bin/env Rscript


# Import logger
suppressMessages({
    library("futile.logger")
})


# Define logging template
log_format <- function(level, clazz, method, msg) {
  ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  sprintf("%s %-5s [ %s.%s ]: %s", ts, level, clazz, method, msg)
}


# Standard log msg
log_info <- function(clazz, method, msg) {
  flog.info(log_format("INFO", clazz, method, msg), name = "app")
}


# Warning message
log_warn <- function(clazz, method, msg) {
  flog.warn(log_format("WARN", clazz, method, msg), name = "app")
}

# Code breaking error message
log_error <- function(clazz, method, msg) {
  flog.error(log_format("ERROR", clazz, method, msg), name = "app")
}