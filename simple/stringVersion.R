
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1) {
  cat("Usage:", commandArgs(trailingOnly = FALSE)[1], "<string>\n")
  quit(status = 1)
}

cat("R version:", R.version.string, "\n")
cat("Provided string:", args[1], "\n")