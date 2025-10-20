
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
        width = "integer",
        height = "integer",
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
        .self$output <- output_image
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
#' Set new value for heigth
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
    .self$logger
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
        xDf <- SparkR::createDataFrame(data.frame(x = 1: .self$getWidth()))
        SparkR::createOrReplaceTempView(xDf, "xAxis")
        yDf <- SparkR::createDataFrame(data.frame(y = 1: .self$getHeight()))
        SparkR::createOrReplaceTempView(yDf, "yAxis")

        # Create image table
        SparkR::sql("
            CREATE OR REPLACE TEMP VIEW pixels AS
                SELECT
                    xAxis.xVals, yAxis.yVale
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
            CREATE OR REPLACE TEMP VIEW processedImage AS
                SELECT
                    xVals, yVals,
                    (%s) AS redVals,
                    (%s) AS greenVals,
                    (%s) AS blueVals
                FROM
                    pixels
        ", .self$width, redVals, greenVals, blueVals))
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
    write_image_struct = function(path) {
        SparkR::write.df(
            SparkR::sql("SELECT * FROM processedImage"),
            path = path,
            source = "parquet",
            mode = "overwrite"
        )
    }
)



# -------------------------------------------------------------------------
#'
#' Writes image from parquet file, to output file
#' 
#' @param path: fully qualified file path for image
#' 
#' @name ImageStacker
#' 
# -------------------------------------------------------------------------
ImageStacker$methods(
    writeImage = function(parquetPath, outputImage) {

        # Fetch image
        df <- collect(read.df(parquetPath, "parquet"))
        img <- df$image_rows[[1]]

        # Initialize output array
        height <- length(img)
        width  <- length(img[[1]]$row_pixels)
        img_array <- array(0, dim = c(height, width, 3))

        # Populate image array
        for (r in seq_len(height)) {
            row <- img[[r]]$row_pixels
            for (c in seq_len(width)) {
                px <- row[[c]]
                img_array[r, c, ] <- c(px$R, px$G, px$B)
            }
        }

        # Write to provided file
        png::writePNG(img_array / 255, outputImage)
    }
)