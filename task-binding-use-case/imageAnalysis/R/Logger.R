#!/usr/bin/env Rscript


# Import logger
suppressMessages({
    library("futile.logger")
})


# -----------------------------------------------------------------------------
#' Logging class
#' 
#' Provides a simple logging utility using futile.logger
#' 
#' Methods:
#'  - info
#'  - warn
#'  - error
#' 
#' @export
# -----------------------------------------------------------------------------
Logger <- setRefClass("Logger")


# Format log messages
Logger$methods(
  format = function(level, clazz, method, msg) {
      ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      sprintf("%s %-5s [ %s.%s ]: \t%s", ts, level, clazz, method, msg)
  }
)


# Info level messages
Logger$methods(
  info = function(clazz, method, msg, appName) {
      flog.info(log_format("INFO", clazz, method, msg), name = appName)
  }
)


# Warning level messages
Logger$methods(
  warn = function(clazz, method, msg, appName) {
      flog.warn(log_format("WARN", clazz, method, msg), name = appName)
  }
)


# Error level messages
Logger$methods(
  error = function(clazz, method, msg, appName) {
    flog.error(log_format("ERROR", clazz, method, msg), name = appName)
  }
)