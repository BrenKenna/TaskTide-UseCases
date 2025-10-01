#!/usr/bin/env Rscript

# Import app & logger
suppressMessages({
    source("logger.R")
    source("GrayScalingApp.R")
})


# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)
if(
    !("--input-image" %in% args) || !("--output-image" %in% args)
) {
    log_error(
        "UseCases.ImageAnalysis.GrayscaleAppRunner", "main",
        "Usage: grayscale.R --input-image <file> --output-image <file>\n"
    )
    quit(status = 1)
}


# Fetch & log args
inputImage <- args[which(args == "--input-image") + 1]
outputImage <- args[which(args == "--output-image") + 1]
log_info(
    "UseCases.ImageAnalysis.GrayscaleAppRunner", "main",
    sprintf("Input Image = '%s', Output Image = '%s'", inputImage, outputImage
))


# Grayscale the input image, to the output image
log_info("UseCases.ImageAnalysis.GrayscaleAppRunner", "main", "Begining execution")
app <- GrayscaleApp$new(input_image, output_image)
app$run()
log_info("UseCases.ImageAnalysis.GrayscaleAppRunner", "main", "Execution complete")