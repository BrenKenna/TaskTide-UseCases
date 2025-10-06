
using TableReader, JSON, Printf


# Import tasks
importCmd = """
    tasktide \
       manager \
       --repository-type "sqlite" \
       --file-path "./itemStoreRepo/sqlite" \
       --method "Import" \
       --delimiter "|" \
       --target "WORKITEM" \
       --step-name "FunctionRunner" \
       --target-file "./FunctionRunnerTasks.txt"
"""

result = run(pipeline(
      importCommand,
      stdout = stdout,
      stderr = stderr
))



# Gather
jobDir = "somePath"
resultFiles = [
    joinpath(root, file)
    for (root, dirs, files) in walkdir(jobDir)
        for file in files
]
results = mapreduce(
    TableReader.readcsv,
    vcat,
    resultFiles
)