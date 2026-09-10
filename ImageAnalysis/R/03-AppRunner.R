#!/usr/bin/env Rscript


# -----------------------------------------------------------------------------
#' 
#' Runs ImageProcessor application
#' 
#' @name AppRunner
#' 
#' @export
#' 
# -----------------------------------------------------------------------------
runImageProcessor <- function(input_image, output_image, mode = 0, height = 700) {

    # Scramble the input image, to the output image
    logger <- Logger$new()
    logger$info(
        "UseCases.ImageAnalysis.AppRunner",
        "runImageProcessor",
        sprintf("Begining execution with '%s' directing results to '%s'", input_image, output_image)
    )
    app <- ImageProcessor$new(
        input_image = input_image,
        output_image = output_image,
        mode = mode
    )
    app$run()
    logger$info(
        "UseCases.ImageAnalysis.AppRunner",
        "runImageProcessor",
        sprintf("Execution complete see results in '%s'", output_image)
    )
}



# -----------------------------------------------------------------------------
#' 
#' Runs Image Stacker application
#' 
#' @name AppRunner
#' 
#' @export
#' 
# -----------------------------------------------------------------------------
runImageStacker <- function(
    redExpr = "255", greenExpr = "0", blueExpr = "0",
    parquetPath = NA, imagePath = NA, height = 350, width = 625
) {

    # Scramble the input image, to the output image
    logger <- Logger$new()
    logger$info(
        "UseCases.ImageAnalysis.AppRunner",
        "runImageStacker",
        sprintf("Begining ImageStacker execution directing results to '%s'", imagePath)
    )
    app <- ImageStacker$new(
        output_image = imagePath,
        height = height,
        width = width
    )
    app$run(
        redExpr = redExpr, greenExpr = greenExpr, blueExpr = blueExpr,
        parquetPath = parquetPath, imagePath = imagePath
    )
    logger$info("UseCases.ImageAnalysis.AppRunner", "runImageStacker", sprintf("Execution complete see results in '%s'", imagePath))
}



# -------------------------------------------------------------------------
#'
#' Depending on session context, run as a command-line program
#' 
#' @name AppRunner
# -------------------------------------------------------------------------
if (
    interactive() == FALSE && identical(Sys.getenv("R_CMD_CHECK"), "") 
) {

    # Parse command line args
    args <- commandArgs(trailingOnly = TRUE)
    if ( length(args) > 0 ) {

        # Validate arguments
        logger <- Logger$new()
        if (
            !( "--anaylsis" %in% args)
        ) {
            logger$error(
                "UseCases.ImageAnalysis.AppRunner", "main",
                "--analysis 'Grayscale | ImageStacker' is a required argument"
            )
            quit(status = 1)
        }

        # Determine if scramble app is to be run
        analysis <- args[which(args == "--analysis") + 1]
        if (analysis == "Grayscale") {

            # Fetch args
            input_image  <- args[which(args == "--input-image") + 1]
            output_image <- args[which(args == "--output-image") + 1]
            mode <- args[which(args == "--mode") + 1]

            logger$info("UseCases.ImageAnalysis.AppRunner", "runGrayScale", "Starting Spark session with RAPIDS enabled")
            runImageProcessor(input_image, output_image, mode)
            logger$info("UseCases.ImageAnalysis.AppRunner", "runGrayScale", "Analysis complete")
        }

        # Otherwise run image stacker
        else {

            # Fetch core args
            height <- args[which(args == "--height") + 1]
            width <- args[which(args == "--width") + 1]
            parquetPath <- args[which(args == "--parquet-path") + 1]
            imagePath <- args[which(args == "--image-path") + 1]
            
            # Fetch image processing args
            redExpr <- args[which(args == "--redVal-expression") + 1]
            greenExpr <- args[which(args == "--greenVal-expression") + 1]
            blueExpr <- args[which(args == "--blueVal-expression") + 1]

            # Run the app
            logger$info("UseCases.ImageAnalysis.AppRunner", "runImageStacker", "Starting Spark session with RAPIDS enabled")
            runImageStacker(
                redExpr = redExpr, greenExpr = greenExpr, blueExpr = blueExpr,
                parquetPath = parquetPath, imagePath = imagePath, height = height, width = width
            ) 
            logger$info("UseCases.ImageAnalysis.AppRunner", "runImageStacker", "Analysis complete")
        }
    }
}