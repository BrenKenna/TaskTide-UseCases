
# Module imports
suppressMessages({
  library(SparkR)
  library(jpeg)
  library(png)
})



# -----------------------------------------------------------------------------
#'
#' A SparkR application that leverages Spark-RAPIDS to perform GPU-accelerated
#' image stacking.
#' 
#' Fields:
#'   - output_image : character, path where the images are stacked to
#'   - width        : integer, image width
#'   - height       : integer, image height
#'   - clazz        : character, fully qualified class identifier for logging
#'   - logger       : logger class
#'
#' 
#' Methods:
#'    - initialize()
#'
#' 
#' @name ImageStacker
#' @export
#'
# -----------------------------------------------------------------------------
ImageStacker <- setRefClass(
    "ImageStacker",
    fields = list(
        output_image = "character",
        width = "numeric",
        height = "numeric",
        clazz = "character",
        logger = "ANY"
    )
)



# -------------------------------------------------------------------------
#'
#' Constructor
#' 
#' @param output_image Path to the generated image file
#' @param width width of the image
#' @param height height of the image
#' @return Initialized ImageStacker instance
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
    initialize = function(output_image, width, height) {
        .self$output_image <- output_image
        .self$width <- width
        .self$height <- height
        .self$clazz <- "UseCases.ImageAnalysis.ImageStacker"
        .self$logger <- NULL
    }
)



# -------------------------------------------------------------------------
#'
#' Set new value for width
#' 
#' @param width
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
    setWidth = function(newVal) {
        .self$width = newVal
    }
)



# -------------------------------------------------------------------------
#'
#' Get value for width
#' 
#' @return width
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
    getWidth = function() {
        return(.self$width)
    }
)



# -------------------------------------------------------------------------
#'
#' Set new value for height
#' 
#' @param height
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
    setHeight = function(newVal) {
        .self$height = newVal
    }
)



# -------------------------------------------------------------------------
#'
#' Get value for width
#' 
#' @param height
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
    getHeight = function() {
        return(.self$height)
    }
)



# -------------------------------------------------------------------------
#'
#' Lazy load logger
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
  getLogger = function() {
    if (is.null(.self$logger)) {
      .self$logger <- Logger$new()
    }
    return(.self$logger)
  }
)



# -------------------------------------------------------------------------
#'
#' Initializes a Spark session with Spark-RAPIDS plugin enabled.
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
  startSpark = function() {
    lg <- .self$getLogger()
    lg$info(clazz, "startSpark", "Starting Spark session with RAPIDS enabled")
    SparkR::sparkR.session(
      master = "local[*]",
      appName = "ImageStackerRAPIDS",
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
#' Create pixel grid where data is populated
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
    createPixelGrid = function() {

        # Initialixe data frame
        xDf <- SparkR::createDataFrame(data.frame(xVals = 1: .self$getWidth()))
        SparkR::createOrReplaceTempView(xDf, "xAxis")
        yDf <- SparkR::createDataFrame(data.frame(yVals = 1: .self$getHeight()))
        SparkR::createOrReplaceTempView(yDf, "yAxis")

        # Create image table
        SparkR::sql("
            CREATE OR REPLACE TEMP VIEW pixels AS
                SELECT
                    xAxis.xVals, yAxis.yVals
                FROM
                    xAxis
                CROSS JOIN 
                    yAxis
        ")
    }
)



# -------------------------------------------------------------------------
#'
#' Colorize pixels by expression.
#' 
#' Examples:
#'  - Solid blue
#'      img$colorize("0", "0", "255")
#' 
#'  - Horizontal gradient (red increases with x)
#'      img$colorize("CAST(x * 255 / 3000 AS INT)", "0", "0")
#' 
#'  - Diagonal green-blue blend
#       img$colorize("0", "CAST(x * 255 / 3000 AS INT)", "CAST(y * 255 / 1500 AS INT)")
#'  
#' 
#' @param redExpr   : expression for red column
#' @param greenExpr : expression for green column
#' @param blueExpr  : expression for blue column  
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
    colorize = function(redExpr = "255", greenExpr = "0", blueExpr = "0") {
        SparkR::sql(sprintf("
            CREATE OR REPLACE TEMP VIEW coloredPixels AS
                SELECT
                    xVals, yVals,
                    (%s) AS redVals,
                    (%s) AS greenVals,
                    (%s) AS blueVals
                FROM
                    pixels
        ", redExpr, greenExpr, blueExpr))
    }
)



# -------------------------------------------------------------------------
#'
#' Color image by thirds
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
    colorizeThirds = function() {
        SparkR::sql(sprintf("
            CREATE OR REPLACE TEMP VIEW coloredPixels AS
                SELECT
                    xVals, yVals,
                CASE WHEN
                    xVals <= %d/3 THEN 255 ELSE 0 END AS redVals,
                CASE WHEN
                    xVals > %d/3 AND xVals <= 2*(%d/3) THEN 255 ELSE 0 END AS greenVals,
                CASE WHEN
                    xVals > 2*(%d/3) THEN 255 ELSE 0 END AS blueVals
                FROM
                    pixels
        ", .self$width, .self$width, .self$width, .self$width))
    }
)



# -------------------------------------------------------------------------
#'
#' Stich image
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
    stitchImage = function() {

        # Order x-Axis
        SparkR::sql("
            CREATE OR REPLACE TEMP VIEW orderedPixels AS
                SELECT
                    yVals,
                    ARRAY_SORT(COLLECT_LIST(STRUCT(xVals, redVals, greenVals, blueVals))) AS rowPixels
                FROM
                    coloredPixels
                GROUP BY
                    yVals
        ")

        # Order y-Axis
        SparkR::sql("
            CREATE OR REPLACE TEMP VIEW processedImage AS
                SELECT
                    CURRENT_TIMESTAMP() AS imageId,
                    ARRAY_SORT(COLLECT_LIST(STRUCT(yVals, rowPixels))) AS imageRows
                FROM
                    orderedPixels
        ")
        }
)



# -------------------------------------------------------------------------
#'
#' Writes image to provided parquet file
#' 
#' @param path: fully qualified file path for image
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
    parquetExport = function(path) {
        SparkR::write.df(
            SparkR::sql("SELECT * FROM processedImage"),
            path = path,
            source = "parquet",
            mode = "append"
        )
    }
)



# -------------------------------------------------------------------------
#'
#' Writes image from parquet file, to output file
#' 
#' @param parquetPath: fully qualified file path for input parquet
#' @param outputImage: fully qualified file path for output image
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
    writeImage = function(parquetPath, outputImage, imageId = NA) {

        # Handle fetching image
        if ( is.na(imageId) ) {
            df <- SparkR::collect(SparkR::sql("SELECT * FROM processedImage"))
            img <- df$imageRows[[1]]
        }

        # Fetch by id
        else {
            df <- SparkR::collect(SparkR::sql(sprintf(
                "SELECT * FROM processedImage WHERE imageId = '%s'", imageId
            )))
            img <- df$imageRows[[1]]
        }

        # Populate image array
        img_array <- array(0, dim = c(height, width, 3))
        for (r in seq_len(height)) {
            row <- img[[r]]$rowPixels
            for (c in seq_len(width)) {
                px <- row[[c]]
                img_array[r, c, ] <- c(px$redVals, px$greenVals, px$blueVals)
            }
        }

        # Write to provided file
        #save(df, file = paste0(output_image + "-df.RData"))
        #save(img_array, file = paste0(output_image + "-img_arr.RData"))
        # cat("img_array saved to:", paste0(output_image, ".RData"), "\n")
        png::writePNG(img_array / 255, outputImage)
    }
)



# -------------------------------------------------------------------------
#'
#' Runs ImageStacker pipeline
#' 
#' @param redExpr       : expression for red column
#' @param greenExpr     : expression for green column
#' @param blueExpr      : expression for blue column
#' @param parquetPath   : fully qualified file path for input parquet
#' @param outputImage   : fully qualified file path for output image
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
    run = function(
        redExpr = "255", greenExpr = "0", blueExpr = "0",
        parquetPath = NA, imagePath = NA
    ) {
        tryCatch({

            # Configure logger and spark session
            lg <- .self$getLogger()
            lg$info(clazz, "run", "================ Initiating ImageStacker Job ================")
            .self$startSpark()

            # Create pixel grid
            lg$info(clazz, "run", "Creating pixel grid")
            .self$createPixelGrid()

            # Colorize pixels from iput expressions
            lg$info(clazz, "run", "Colorizing image")
            .self$colorize(redExpr, greenExpr, blueExpr)

            # Stich into image for export
            lg$info(clazz, "run", "Stiching image for parquet/png export")
            .self$stitchImage()

            # Export to parquet
            if ( !is.na(parquetPath) ) {
                lg$info(clazz, "run", "Storing image to parquet")
                .self$parquetExport(parquetPath)

                if ( !is.na(imagePath) ) {
                    lg$info(clazz, "run", "Saving image from parquet to file")
                    .self$writeImage(parquetPath, imagePath)
                }
            }

            # Log completion
            lg$info(clazz, "run", "================ Completed ImageStacker Job Successfully ================")
            sparkR.session.stop()
        },

        error = function(e) {
            lg$error(clazz, "run", paste("Job failed with error:", e$message))
            sparkR.session.stop()
            quit(status = 1)
        })
    }
)