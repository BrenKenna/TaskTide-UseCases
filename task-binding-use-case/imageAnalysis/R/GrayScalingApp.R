#!/usr/bin/env Rscript


# Module imports
suppressMessages({
  library(SparkR)
  library(jpeg)
  library(png)
})


# -----------------------------------------------------------------------------
#' 
#' Class: GrayScaleApp
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
#'
#' 
#' Methods:
#'    - initialize()
#'    - startSpark(),
#'    - loadImage(),
#'    - toDataFrame(),
#'    - registerGrayscaleUDF(),
#'    - computeGrayscale(),
#'    - saveImage(),
#'    - run()
#' 
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
  ),
  methods = list(
    initialize = function(input_image, output_image) {
      .self$input_image <- input_image
      .self$output_image <- output_image
      .self$clazz <- "UseCases.ImageAnalysis.GrayScaleApp"
      .self$logger <- Logger$new()
    },

    startSpark = function() {
      Logger$info(clazz, "startSpark", "Starting Spark session with RAPIDS enabled")
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

    loadImage = function() {
      Logger$info(clazz, "loadImage", paste("Loading input image:", input_image))
      if (grepl("\\.png$", input_image, ignore.case = TRUE)) {
        img <- readPNG(input_image)
      }
      else {
        img <- readJPEG(input_image)
      }
      return(img)
    },

    toDataFrame = function(img) {
      logger$info(clazz, "toDataFrame", "Converting image matrix into Spark DataFrame")
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
    },

    registerGrayscaleUDF = function() {
      logger$info(clazz, "registerGrayscaleUDF", "Registering grayscale UDF on Spark")
      grayscale <- function(r, g, b) {
        0.299 * r + 0.587 * g + 0.114 * b
      }
      registerUDF("grayscale", grayscale, "double")
    },

    computeGrayscale = function(df) {
      logger$info(clazz, "computeGrayscale", "Executing GPU-accelerated grayscale transformation")
      df_gray <- withColumn(df, "gray", callUDF("grayscale", df$r, df$g, df$b))
      collect(df_gray)
    },

    saveImage = function(res, h, w) {
        logger$info(clazz, "saveImage", paste("Saving grayscale output to:", output_image))
        mat <- matrix(res$gray, nrow = h, ncol = w, byrow = TRUE)
        writeJPEG(mat, output_image)
    },

    run = function() {
        tryCatch({
          logger$info(clazz, "run", "================ Initiating Grayscale Job ================")

          .self$startSpark()
          img <- .self$loadImage()
          h <- dim(img)[1]
          w <- dim(img)[2]

          df <- .self$toDataFrame(img)
          .self$registerGrayscaleUDF()

          logger$info(clazz, "run", "Performing transformation...")
          res <- .self$computeGrayscale(df)

          .self$saveImage(res, h, w)

          logger$info(clazz, "run", "================ Job Completed Successfully ================")

          sparkR.session.stop()
        },
        error = function(e) {
          logger$error(clazz, "run", paste("Job failed with error:", e$message))
          sparkR.session.stop()
          quit(status = 1)
        })
    }
  )
)