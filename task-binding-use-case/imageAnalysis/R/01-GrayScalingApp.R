#!/usr/bin/env Rscript


# Module imports
suppressMessages({
  library(SparkR)
  library(jpeg)
  library(png)
})


# -----------------------------------------------------------------------------
#'
#' A SparkR application that leverages Spark-RAPIDS to perform GPU-accelerated
#' GrayScale conversion of input images. The class handles Spark initialization,
#' image loading, DataFrame conversion, GrayScale transformation, and output
#' persistence.
#' 
#' Fields:
#'   - input_image  : character, path to the input image file
#'   - output_image : character, path where the output GrayScale image is written
#'   - clazz        : character, fully qualified class identifier for logging
#'
#' 
#' Methods:
#'    - initialize()
#'    - startSpark(),
#'    - loadImage(),
#'    - toDataFrame(),
#'    - registerGrayScaleUDF(),
#'    - computeGrayScale(),
#'    - saveImage(),
#'    - run()
#' 
#' @name GrayScalingApp
#' @export
#'
# -----------------------------------------------------------------------------
GrayScaleApp <- setRefClass(
  "GrayScaleApp",
  fields = list(
    input_image = "character",
    output_image = "character",
    clazz = "character",
    logger = "ANY"
))


# -------------------------------------------------------------------------
#'
#' Constructor
#' 
#' @param input_image Path to the input image file
#' @param output_image Path to the GrayScale output image file
#' @return Initialized GrayScaleApp instance
#' 
#' @name GrayScalingApp
#' 
# -------------------------------------------------------------------------
GrayScaleApp$methods(
  initialize = function(input_image, output_image) {
    .self$input_image <- input_image
    .self$output_image <- output_image
    .self$clazz <- "UseCases.ImageAnalysis.GrayScaleApp"
    .self$logger <- NULL
  }
)


# -------------------------------------------------------------------------
#'
#' Lazy load logger
#' 
#' @name GrayScalingApp
#' 
# -------------------------------------------------------------------------
GrayScaleApp$methods(
  getLogger = function() {
    if (is.null(.self$logger)) {
      .self$logger <- Logger$new()
    }
    .self$logger
  }
)


# -------------------------------------------------------------------------
#'
#' Initializes a Spark session with Spark-RAPIDS plugin enabled.
#' 
#' @name GrayScalingApp
#' 
# -------------------------------------------------------------------------
GrayScaleApp$methods(
  startSpark = function() {
    lg <- .self$getLogger()
    lg$info(clazz, "startSpark", "Starting Spark session with RAPIDS enabled")
    SparkR::sparkR.session(
      master = "local[*]",
      appName = "GrayScaleImageRAPIDS",
      sparkConfig = list(
        spark.plugins = "com.nvidia.spark.SQLPlugin",
        spark.rapids.sql.enabled = "true",
        spark.executor.resource.gpu.amount = "1",
        spark.task.resource.gpu.amount = "0.5"
      )
    )
  }
)


# -------------------------------------------------------------------------
#'
#' Reads the input image from disk into a matrix. Supports PNG and JPEG.
#'
#' @return Numeric array representing the input image
#' 
#' @name GrayScalingApp
#' 
# -------------------------------------------------------------------------
GrayScaleApp$methods(
  loadImage = function() {
    lg <- .self$getLogger()
    lg$info(clazz, "loadImage", paste("Loading input image:", input_image))
    if (grepl("\\.png$", input_image, ignore.case = TRUE)) {
      img <- png::readPNG(input_image)
    }
    else {
      img <- png::readJPEG(input_image)
    }
    return(img)
  }
)


# -------------------------------------------------------------------------
#'
#' Converts an image matrix into a Spark DataFrame of pixel values.
#'
#' @param img Numeric array of the input image
#' @return Spark DataFrame with columns: row, col, r, g, b
#' 
#' @name GrayScalingApp
#' 
# -------------------------------------------------------------------------
GrayScaleApp$methods(
  toDataFrame = function(img) {
    lg <- .self$getLogger()
    lg$info(clazz, "toDataFrame", "Converting image matrix into Spark DataFrame")
    h <- dim(img)[1]
    w <- dim(img)[2]
    pixels <- data.frame(
      row = rep(1:h, each = w),
      col = rep(1:w, times = h),
      r = as.vector(img[,,1]),
      g = as.vector(img[,,2]),
      b = as.vector(img[,,3])
    )
    df <- createDataFrame(pixels)
    df  # Return Spark DataFrame
  }
)


# -------------------------------------------------------------------------
#'
#' Applies the registered GrayScale UDF on the Spark DataFrame.
#'
#' @param df Spark DataFrame with r, g, b channels
#' @return Local R DataFrame with GrayScale values
#' 
#' @name GrayScalingApp
#' 
# -------------------------------------------------------------------------
GrayScaleApp$methods(
  computeGrayScale = function(df) {
    lg <- .self$getLogger()
    lg$info(clazz, "computeGrayScale", "Executing GrayScale transformation via Spark SQL")

    # Register as temporary table
    SparkR::registerTempTable(df, "pixels")

    # Use Spark SQL to compute GrayScale
    df_gray <- SparkR::sql("
      SELECT row, col,
             (0.299 * r + 0.587 * g + 0.114 * b) AS gray
      FROM pixels
    ")

    # Collect results back to dataframe
    res <- SparkR::collect(df_gray)
    res
  }
)


# -------------------------------------------------------------------------
#'
#' Writes the GrayScale matrix to the output file in JPEG format.
#'
#' @param res Local DataFrame containing GrayScale pixel values
#' @param h Image height
#' @param w Image width
#' 
#' @name GrayScalingApp
#' 
# -------------------------------------------------------------------------
GrayScaleApp$methods(
  saveImage = function(res, h, w) {
    lg <- .self$getLogger()
    lg$info(clazz, "saveImage", paste("Saving GrayScale output to:", output_image))
    mat <- matrix(res$gray, nrow = h, ncol = w, byrow = FALSE)
    mat <- pmin(pmax(mat, 0), 1)

    if (grepl("\\.png$", output_image, ignore.case = TRUE)) {
      png::writePNG(mat, output_image)
    } else {
      jpeg::writeJPEG(mat, output_image)
    }
  }
)


# -------------------------------------------------------------------------
#'
#' Entrypoint method for GrayScale app:
#'   - start Spark
#'   - load image
#'   - convert to DataFrame
#'   - register UDF
#'   - compute GrayScale
#'   - save output
#'
#' Includes structured logging and error handling.
#' 
#' @name GrayScalingApp
#' 
# -------------------------------------------------------------------------
GrayScaleApp$methods(
  run = function() {
    tryCatch({
      lg <- .self$getLogger()
      lg$info(clazz, "run", "================ Initiating GrayScale Job ================")

      .self$startSpark()
      img <- .self$loadImage()
      h <- dim(img)[1]
      w <- dim(img)[2]

      df <- .self$toDataFrame(img)

      lg$info(clazz, "run", "Performing transformation...")
      res <- .self$computeGrayScale(df)

      .self$saveImage(res, h, w)
      lg$info(clazz, "run", "================ Job Completed Successfully ================")
      sparkR.session.stop()
    },

    error = function(e) {
      lg$error(clazz, "run", paste("Job failed with error:", e$message))
      sparkR.session.stop()
      quit(status = 1)
    })
  }
)