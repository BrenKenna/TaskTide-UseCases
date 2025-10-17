#!/usr/bin/env Rscript


# -----------------------------------------------------------------------------
#' 
#' Runs GrayScale Application
#' @name AppRunner
#' 
#' @export
#' 
# -----------------------------------------------------------------------------
runApp <- function(
    input_image,
    output_image
) {

    # Grayscale the input image, to the output image
    logger <- Logger$new()
    logger$info(
        "UseCases.ImageAnalysis.GrayscaleAppRunner",
        "main",
        sprintf("Begining execution with '%s' directing results to '%s'", input_image, output_image)
    )
    app <- GrayScaleApp$new(
        input_image = input_image,
        output_image = output_image
    )
    app$run()
    logger$info("UseCases.ImageAnalysis.GrayscaleAppRunner", "main", sprintf("Execution complete see results in '%s'", output_image))
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
        if (!("--input-image" %in% args) || !("--output-image" %in% args)) {
            logger$error(
                "UseCases.ImageAnalysis.GrayscaleAppRunner", "main",
                "Usage: Rscript -e 'imageAnalysis::run_grayscale(\"in.png\", \"out.jpg\")' \n"
            )
            quit(status = 1)
        }

        # Fetch args
        input_image  <- args[which(args == "--input-image") + 1]
        output_image <- args[which(args == "--output-image") + 1]

        run_grayscale(input_image, output_image)
    }
}