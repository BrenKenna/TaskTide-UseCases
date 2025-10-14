#!/usr/bin/env Rscript


# Module imports
suppressMessages({
    library(SparkR)
    library(jpeg)
    library(png)
    source("Logger.R")  
})


# -----------------------------------------------------------------------------
#' Class: GrayscaleApp
#'
#' A SparkR application that leverages Spark-RAPIDS to perform GPU-accelerated
#' grayscale conversion of input images. The class handles Spark initialization,
#' image loading, DataFrame conversion, grayscale transformation, and output
#' persistence.
#'
#' Fields:
#'   - input_image  : character, path to the input image file
#'   - output_image : character, path where the output grayscale image is written
#'   - clazz        : character, fully qualified class identifier for logging
# -----------------------------------------------------------------------------
GrayscaleApp <- setRefClass(
  "GrayscaleApp",
  fields = list(
    input_image = "character",
    output_image = "character",
    clazz = "character"
  ),
  methods = list(


    # -------------------------------------------------------------------------
    #' Constructor
    #'
    #' @param input_image Path to the input image file
    #' @param output_image Path to the grayscale output image file
    #' @return Initialized GrayscaleApp instance
    # -------------------------------------------------------------------------
    initialize = function(input_image, output_image) {
      .self$input_image <- input_image
      .self$output_image <- output_image
      .self$clazz <- "UseCases.ImageAnalysis.GrayscaleApp"
    },


    # -------------------------------------------------------------------------
    #' Start Spark
    #'
    #' Initializes a Spark session with Spark-RAPIDS plugin enabled.
    # -------------------------------------------------------------------------
    startSpark = function() {
      log_info(clazz, "startSpark", "Starting Spark session with RAPIDS enabled")
      sparkR.session(
        master = "local[*]",
        appName = "GrayscaleImageRAPIDS",
        sparkConfig = list(
          spark.plugins = "com.nvidia.spark.SQLPlugin",
          spark.rapids.sql.enabled = "true",
          spark.executor.resource.gpu.amount = "1",
          spark.task.resource.gpu.amount = "0.5"
        )
      )
    },


    # -------------------------------------------------------------------------
    #' Load Image
    #'
    #' Reads the input image from disk into a matrix. Supports PNG and JPEG.
    #'
    #' @return Numeric array representing the input image
    # -------------------------------------------------------------------------
    loadImage = function() {
      log_info(clazz, "loadImage", paste("Loading input image:", input_image))
      if (grepl("\\.png$", input_image, ignore.case = TRUE)) {
        img <- readPNG(input_image)
      } else {
        img <- readJPEG(input_image)
      }
      return(img)
    },


    # -------------------------------------------------------------------------
    #' Convert to DataFrame
    #'
    #' Converts an image matrix into a Spark DataFrame of pixel values.
    #'
    #' @param img Numeric array of the input image
    #' @return Spark DataFrame with columns: row, col, r, g, b
    # -------------------------------------------------------------------------
    toDataFrame = function(img) {
      log_info(clazz, "toDataFrame", "Converting image matrix into Spark DataFrame")
      h <- dim(img)[1]
      w <- dim(img)[2]
      pixels <- data.frame(
        row = rep(1:h, each = w),
        col = rep(1:w, times = h),
        r = as.vector(img[,,1]),
        g = as.vector(img[,,2]),
        b = as.vector(img[,,3])
      )
      createDataFrame(pixels)
    },


    # -------------------------------------------------------------------------
    #' Register Grayscale UDF
    #'
    #' Registers a Spark SQL UDF that computes grayscale pixel intensity using
    #' the luminance formula: 0.299*R + 0.587*G + 0.114*B.
    # -------------------------------------------------------------------------
    registerGrayscaleUDF = function() {
      log_info(clazz, "registerGrayscaleUDF", "Registering grayscale UDF on Spark")
      grayscale <- function(r, g, b) {
        return(0.299 * r + 0.587 * g + 0.114 * b)
      }
      registerUDF("grayscale", grayscale, "double")
    },


    # -------------------------------------------------------------------------
    #' Compute Grayscale
    #'
    #' Applies the registered grayscale UDF on the Spark DataFrame.
    #'
    #' @param df Spark DataFrame with r, g, b channels
    #' @return Local R DataFrame with grayscale values
    # -------------------------------------------------------------------------
    computeGrayscale = function(df) {
      log_info(clazz, "computeGrayscale", "Executing GPU-accelerated grayscale transformation")
      df_gray <- SparkR::sql(
        "SELECT row, col, grayscale(r, g, b) as gray FROM tableName"
      )
      collect(df_gray)
    },


    # -------------------------------------------------------------------------
    #' Save Image
    #'
    #' Writes the grayscale matrix to the output file in JPEG format.
    #'
    #' @param res Local DataFrame containing grayscale pixel values
    #' @param h Image height
    #' @param w Image width
    # -------------------------------------------------------------------------
    saveImage = function(res, h, w) {
      log_info(clazz, "saveImage", paste("Saving grayscale output to:", output_image))
      mat <- matrix(res$gray, nrow = h, ncol = w, byrow = TRUE)
      writeJPEG(mat, output_image)
    },


    # -------------------------------------------------------------------------
    #' Run
    #'
    #' Orchestrates the entire grayscale pipeline:
    #'   - start Spark
    #'   - load image
    #'   - convert to DataFrame
    #'   - register UDF
    #'   - compute grayscale
    #'   - save output
    #'
    #' Includes structured logging and error handling.
    # -------------------------------------------------------------------------
    run = function() {
      tryCatch({
        log_info(clazz, "run", "================ Initiating Grayscale Job ================")

        .self$startSpark()
        img <- .self$loadImage()
        h <- dim(img)[1]
        w <- dim(img)[2]

        df <- .self$toDataFrame(img)
        .self$registerGrayscaleUDF()

        log_info(clazz, "run", "Performing transformation...")
        res <- .self$computeGrayscale(df)

        .self$saveImage(res, h, w)

        log_info(clazz, "run", "================ Job Completed Successfully ================")

        sparkR.session.stop()
      }, error = function(e) {
        log_error(clazz, "run", paste("Job failed with error:", e$message))
        sparkR.session.stop()
        quit(status = 1)
      })
    }
  )
)