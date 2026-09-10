
library(imageAnalysis)


imagePath = "./stacker-image.png"
parquetPath = "./stacker-parquet"
height = 350
width = 625


app <- imageAnalysis:::ImageStacker$new(
    output_image = imagePath,
    height = height,
    width = width
)

app$run(
    redExpr = "0", greenExpr = "CAST(x * 255 / 3000 AS INT)", blueExpr = "CAST(y * 255 / 1500 AS INT)",
    parquetPath = parquetPath, imagePath = imagePath
)



# Read the Parquet into a Spark DataFrame
df <- read.df("part-00000-fc539461-c752-45df-b487-caef3455ed6b-c000.snappy.parquet", source = "parquet")
createOrReplaceTempView(df, "image_table")
printSchema(df)

'''
root
 |-- imageRows: array (nullable = true)
 |    |-- element: struct (containsNull = true)
 |    |    |-- yVals: integer (nullable = true)
 |    |    |-- rowPixels: array (nullable = true)
 |    |    |    |-- element: struct (containsNull = true)
 |    |    |    |    |-- xVals: integer (nullable = true)
 |    |    |    |    |-- redVals: integer (nullable = true)
 |    |    |    |    |-- greenVals: integer (nullable = true)
 |    |    |    |    |-- blueVals: integer (nullable = true)
'''


pixelDF <- sql("
  SELECT row.yVals, px.xVals, px.redVals, px.greenVals, px.blueVals
  FROM image_table
  LATERAL VIEW explode(imageRows) AS row
  LATERAL VIEW explode(row.rowPixels) AS px
  LIMIT 10
")
showDF(pixelDF)

'''
+-----+-----+-------+---------+--------+
|yVals|xVals|redVals|greenVals|blueVals|
+-----+-----+-------+---------+--------+
|    1|    1|    255|        0|       0|
|    1|    2|    255|        0|       0|
|    1|    3|    255|        0|       0|
|    1|    4|    255|        0|       0|
|    1|    5|    255|        0|       0|
|    1|    6|    255|        0|       0|
|    1|    7|    255|        0|       0|
|    1|    8|    255|        0|       0|
|    1|    9|    255|        0|       0|
|    1|   10|    255|        0|       0|
+-----+-----+-------+---------+--------+

'''


rgbCheck <- sql("
  SELECT 
    min(px.redVals) AS min_red, max(px.redVals) AS max_red,
    min(px.greenVals) AS min_green, max(px.greenVals) AS max_green,
    min(px.blueVals) AS min_blue, max(px.blueVals) AS max_blue
  FROM image_table
  LATERAL VIEW explode(imageRows) AS row
  LATERAL VIEW explode(row.rowPixels) AS px
")
showDF(rgbCheck)

'''
+-------+-------+---------+---------+--------+--------+
|min_red|max_red|min_green|max_green|min_blue|max_blue|
+-------+-------+---------+---------+--------+--------+
|    255|    255|        0|        0|       0|       0|
+-------+-------+---------+---------+--------+--------+
'''


# Collect table
df <- collect(sql("SELECT * FROM image_table"))


app$startSpark()
app$createPixelGrid()
app$colorize(redExpr = "255", greenExpr = "0", blueExpr = "0")
app$stitchImage()

df <- SparkR::collect(SparkR::sql("SELECT * FROM processedImage"))

str(df, max.level = 2)
str(df$imageRows[[1]][[1]], max.level = 1)
head(df$imageRows[[1]][[1]]$rowPixels, 3)

'''

data.frame:   1 obs. of  1 variable:
 $ imageRows:List of 1
  ..$ :List of 350

List of 2
 $ yVals    : int 1
 $ rowPixels:List of 625
 - attr(*, "class")= chr "struct"

'''


# Check app method
img <- df$imageRows[[1]]


# Initialize output array
actual_height <- length(img)
actual_width <- if (actual_height > 0) length(img[[1]]$row_pixels) else 0

cat("Class fields - width:", app$width, "height:", app$height, "\n")
cat("Actual data - width:", actual_width, "height:", actual_height, "\n")


# Populate image array
img_array <- array(0, dim = c(app$height, app$width, 3))
for (r in seq_len(app$height)) {
    row <- img[[r]]$rowPixels
    for (c in seq_len(app$width)) {
        px <- row[[c]]
        img_array[r, c, ] <- c(px$redVals, px$greenVals, px$blueVals) / 255
    }
}

png::writePNG(img_array, app$output_image)


# Inspect
str(img_array)
img_array[1, 1:5, ]
img_array[175, 312, ]

any(img_array > 0)

'''
num [1:350, 1:625, 1:3] 0 0 0 0 0 0 0 0 0 0 ...
[1] 350 625   3

First Pixel:
     [,1] [,2] [,3]
[1,]    1    0    0
[2,]    1    0    0
[3,]    1    0    0
[4,]    1    0    0
[5,]    1    0    0


Middle Pixel:
[1] 1 0 0

'''
