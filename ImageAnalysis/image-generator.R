# Import image analysis app
library(SparkR)
library(imageAnalysis)

SparkR::sparkR.session()


# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
imagePath           <- args[1]
parquetPath         <- args[2]

redExpression       <- args[3]
greenExpression     <- args[4]
blueExpression      <- args[5]


# Default image size
height = 350
width = 625


# Configure application with provided parameters
app <- imageAnalysis:::ImageStacker$new(
    output_image = imagePath,
    height = height,
    width = width
)


# Generate target image with RGB expressions
app$run(
    redExpr = redExpression,
    greenExpr = greenExpression,
    blueExpr = blueExpression,
    parquetPath = parquetPath,
    imagePath = imagePath
)