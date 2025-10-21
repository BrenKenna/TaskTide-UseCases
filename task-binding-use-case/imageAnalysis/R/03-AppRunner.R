#!/usr/bin/env Rscript


# -----------------------------------------------------------------------------
#' 
#' Runs Image Scrambler application
#' 
#' @name AppRunner
#' 
#' @export
#' 
# -----------------------------------------------------------------------------
runImageScrambler <- function(input_image, output_image) {

    # Scramble the input image, to the output image
    logger <- Logger$new()
    logger$info(
        "UseCases.ImageAnalysis.AppRunner",
        "runImageScrambler",
        sprintf("Begining execution with '%s' directing results to '%s'", input_image, output_image)
    )
    app <- ImageScrambler$new(
        input_image = input_image,
        output_image = output_image
    )
    app$run()
    logger$info("UseCases.ImageAnalysis.AppRunner", "runImageScrambler", sprintf("Execution complete see results in '%s'", output_image))
}



# -----------------------------------------------------------------------------
#' 
#' Runs Image Stacker Application
#' 
#' @name AppRunner
#' 
#' @export
#' 
# -----------------------------------------------------------------------------
runImageStacker <- function(
    redExpr = "255", greenExpr = "0", blueExpr = "0",
    parquetPath = NA, imagePath = NA, height = 0, width = 0
) {

    # Scramble the input image, to the output image
    logger <- Logger$new()
    logger$info(
        "UseCases.ImageAnalysis.AppRunner",
        "runImageStacker",
        sprintf("Begining execution with '%s' directing results to '%s'", input_image, output_image)
    )
    app <- ImageStacker$new(
        output_image = imagePath,
        height = heigth,
        width = width
    )
    app$run(parquetPath = parquetPath, imagePath = imagePath)
    logger$info("UseCases.ImageAnalysis.AppRunner", "runImageStacker", sprintf("Execution complete see results in '%s'", output_image))
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
                "--analysis 'ImageScrambler | ImageStacker' is a required argument"
            )
            quit(status = 1)
        }

        # Determine if scramble app is to be run
        analysis <- args[which(args == "--analysis") + 1]
        if (analysis == "scramble") {

            # Fetch args
            input_image  <- args[which(args == "--input-image") + 1]
            output_image <- args[which(args == "--output-image") + 1]

            logger$info("UseCases.ImageAnalysis.AppRunner", "runImageScrambler", "Starting Spark session with RAPIDS enabled")
            runImageScrambler(input_image, output_image)
            logger$info("UseCases.ImageAnalysis.AppRunner", "runImageScrambler", "Analysis complete")
        }

        # Otherwise run image stacker
        else {

            # Fetch core args
            height <- args[which(args == "--heigth") + 1]
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
                redExpr = "255", greenExpr = "0", blueExpr = "0",
                parquetPath = NA, imagePath = NA, height = 350, width = 625
            ) 
            logger$info("UseCases.ImageAnalysis.AppRunner", "runImageStacker", "Analysis complete")
        }
    }
}
