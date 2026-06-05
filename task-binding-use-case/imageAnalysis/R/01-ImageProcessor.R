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
#' various operations over provided image - Scrambling, Grayscaling
#' 
#' Fields:
#'   - input_image  : character, path to the input image file
#'   - output_image : character, path where the output scrambled image is written
#'   - mode         : 0 = scrambles image, 1 grayscales the image
#'   - clazz        : character, fully qualified class identifier for logging
#'
#' 
#' Methods:
#'    - initialize()
#'    - startSpark(),
#'    - loadImage(),
#'    - toDataFrame(),
#'    - registerGrayScaleUDF(),
#'    - scrambleImage(),
#'    - computeGrayScale(),
#'    - saveImage(),
#'    - run()
#' 
#' @name ImageProcessor
#' @export
#'
# -----------------------------------------------------------------------------
ImageProcessor <- setRefClass(
  "ImageProcessor",
  fields = list(
    input_image = "character",
    output_image = "character",
    mode = "numeric",
    clazz = "character",
    logger = "ANY"
))


# -------------------------------------------------------------------------
#'
#' Constructor
#' 
#' @param input_image Path to the input image file
#' @param output_image Path to the GrayScale output image file
#' @param mode        0 = grayscale, 1 = scrambler
#' @return Initialized ImageProcessor instance
#' 
#' @name ImageProcessor
#' 
# -------------------------------------------------------------------------
ImageProcessor$methods(
  initialize = function(input_image, output_image, mode = 0) {
    .self$input_image <- input_image
    .self$output_image <- output_image
    .self$mode <- mode
    .self$clazz <- "UseCases.ImageAnalysis.ImageProcessor"
    .self$logger <- NULL
  }
)



# -------------------------------------------------------------------------
#'
#' Lazy load logger
#' 
#' @name ImageProcessor
#' 
# -------------------------------------------------------------------------
ImageProcessor$methods(
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
#' @name ImageProcessor
#' 
# -------------------------------------------------------------------------
ImageProcessor$methods(
  startSpark = function() {
    lg <- .self$getLogger()
    lg$info(clazz, "startSpark", "Starting Spark session with RAPIDS enabled")
    SparkR::sparkR.session(
      master = "local-cluster[2,1,4096]",
      appName = "ImageProcessorRAPIDS",
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
#' @name ImageProcessor
#' 
# -------------------------------------------------------------------------
ImageProcessor$methods(
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
#' @name ImageProcessor
#' 
# -------------------------------------------------------------------------
ImageProcessor$methods(
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
    df <- SparkR::createDataFrame(pixels)
    return(df)
  }
)



# -------------------------------------------------------------------------
#'
#' Scrambles the pixels of the image by randomizing row order
#'
#' @param df Spark DataFrame with row, col, r, g, b
#' @return Local DataFrame with scrambled pixels
#' 
#' @name ImageProcessor
#' 
# -------------------------------------------------------------------------
ImageProcessor$methods(
  scrambleImage = function(df) {
    lg <- .self$getLogger()
    lg$info(clazz, "scrambleImage", "Randomizing pixel order via Spark SQL")

    # Add a random value column
    df <- SparkR::withColumn(df, "rand_val", rand())

    # Order by the random value to shuffle pixels
    df_shuffled <- SparkR::arrange(df, df$rand_val)

    # Drop the rand_val column to clean up
    df_shuffled <- SparkR::drop(df_shuffled, "rand_val")

    # Collect back to R
    res <- SparkR::collect(df_shuffled)
    return(res)
  }
)



# -------------------------------------------------------------------------
#'
#' Applies the registered GrayScale UDF on the Spark DataFrame.
#'
#' @param df Spark DataFrame with r, g, b channels
#' @return Local R DataFrame with GrayScale values
#' 
#' @name ImageProcessor
#' 
# -------------------------------------------------------------------------
ImageProcessor$methods(
  computeGrayScale = function(df) {
    lg <- .self$getLogger()
    lg$info(clazz, "computeGrayScale", "Executing GrayScale transformation via Spark SQL")

    # Register as temporary table
    SparkR::registerTempTable(df, "pixels")

    # Use Spark SQL to compute GrayScale
    df_gray <- SparkR::sql("
      SELECT
        row, col,
        (0.299 * r + 0.587 * g + 0.114 * b) AS gray
      FROM
        pixels
    ")

    # Collect results back to dataframe
    res <- SparkR::collect(df_gray)
    return(res)
  }
)



# -------------------------------------------------------------------------
#'
#' Writes the processed image matrix to the output file in JPEG format.
#'
#' @param res Local DataFrame containing image pixel values
#' @param h Image height
#' @param w Image width
#' 
#' @name ImageProcessor
#' 
# -------------------------------------------------------------------------
ImageProcessor$methods(
  saveImage = function(res, h, w) {
    lg <- .self$getLogger()
    lg$info(clazz, "saveImage", paste("Saving processed output to:", output_image))

    # Handle scrambling vs grayscaling image
    if (.self$mode == 0) {
      mat_r <- matrix(res$r, nrow = h, ncol = w, byrow = FALSE)
      mat_g <- matrix(res$g, nrow = h, ncol = w, byrow = FALSE)
      mat_b <- matrix(res$b, nrow = h, ncol = w, byrow = FALSE)
      mat <- array(c(mat_r, mat_g, mat_b), dim = c(h, w, 3))
    }
    else {
      mat <- matrix(res$gray, nrow = h, ncol = w, byrow = FALSE)
    }
    mat <- pmin(pmax(mat, 0), 1)

    # Handle writing JPEG vs PNG
    if (grepl("\\.png$", output_image, ignore.case = TRUE)) {
      png::writePNG(mat, output_image)
    } else {
      jpeg::writeJPEG(mat, output_image)
    }
  }
)



# -------------------------------------------------------------------------
#'
#' Entrypoint method for ImageProcessor app:
#'   - start Spark
#'   - load image
#'   - convert to DataFrame
#'   - register UDF
#'   - compute GrayScale
#'   - save output
#'
#' Includes structured logging and error handling.
#' 
#' @name ImageProcessor
#' 
# -------------------------------------------------------------------------
ImageProcessor$methods(
  run = function() {
    tryCatch({
      lg <- .self$getLogger()
      lg$info(clazz, "run", "================ Initiating ImageProcessor Job ================")

      # Load image
      .self$startSpark()
      img <- .self$loadImage()
      h <- dim(img)[1]
      w <- dim(img)[2]

      # Convert to RDD and process
      df <- .self$toDataFrame(img)
      res <- NA
      if ( .self$mode == 0 ) {
        lg$info(clazz, "run", "Scrambling image")
        res <- .self$scrambleImage(df)
      }
      else {
        lg$info(clazz, "run", "Grayscaling image.")
        res <- .self$computeGrayScale(df)
      }

      .self$saveImage(res, h, w)
      lg$info(clazz, "run", "================ Completed ImageProcessor Successfully ================")
      sparkR.session.stop()
    },

    error = function(e) {
      lg$error(clazz, "run", paste("Job failed with error:", e$message))
      sparkR.session.stop()
      quit(status = 1)
    })
  }
)