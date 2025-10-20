#!/usr/bin/env Rscript


# -----------------------------------------------------------------------------
#' 
#' Runs Image Analysis Applications
#' 
#' @name AppRunner
#' 
#' @export
#' 
# -----------------------------------------------------------------------------
runImageScrambler <- function(
    input_image,
    output_image
) {

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

        
        analysis <- args[which(args == "--analysis") + 1]

        # Determine which one to run
        if (analysis == "scramble") {

            # Fetch args
            input_image  <- args[which(args == "--input-image") + 1]
            output_image <- args[which(args == "--output-image") + 1]

            logger$info("UseCases.ImageAnalysis.AppRunner", "runImageScrambler", "Starting Spark session with RAPIDS enabled")
            runImageScrambler(input_image, output_image)
            logger$info("UseCases.ImageAnalysis.AppRunner", "runImageScrambler", "Analysis complete")
        }

        else {
            logger$info("UseCases.ImageAnalysis.AppRunner", "runImageStacker", "Starting Spark session with RAPIDS enabled")
            #
            #
            #
            logger$info("UseCases.ImageAnalysis.AppRunner", "runImageStacker", "Analysis complete")
        }
    }
}