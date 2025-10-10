"""
`FunctionRunner.jl`

The purpose of this Julia script is to demonstrate that
 TaskTide is also usable as a function runner, across
 different programming languages. Where output is sank
 into an output file.

```text
Example Usage:
    julia \\
       FunctionRunner.jl \\
       --operation "BASE64_BYTE" \\
       --parameters "BASE64_BYTE" \\
       --packageUrl "http/s3/gsiftp://some/path/myTar.gz \\
       --output "result.txt" \\
       --serializeOutput

Exports:
    Methods - invokeFunction, deserializeFunction,
        deserializeFunctionParams, serializeToBase64,
        handleEnvArg
    
    Modules - FunctionRunnerUtils as Utils,
        FunctionRunnerSerDe as SerDe
```
"""
module FunctionRunner

println("Importing Modules")
flush(stdout)


# Include utility and SerDe
println("Importing FunctionRunner")
flush(stdout)

include("./FunctionRunnerUtils.jl")
using .FunctionRunnerUtils
const Utils = FunctionRunnerUtils

include("./FunctionRunnerSerDe.jl")
using .FunctionRunnerSerDe
const SerDe = FunctionRunnerSerDe


# Configure exports
println("Configuring exports")
flush(stdout)
export Utils, SerDe


# Launch program, also allowing import
if abspath(PROGRAM_FILE) == @__FILE__
    
    # Parse arguments
    results = ""
    Utils.formatLogMessage(
        "Parsing command-line arguments",
        "info",
        "FunctionRunner.jl",
        "FunctionRunner.main"
    )
    args = Utils.parseArgs()

    # Configure dependancies if supplied
    if !isnothing(args["dependancies"])
        Utils.formatLogMessage(
            "Fetching function depenancies",
            "info",
            "FunctionRunner.jl",
            "FunctionRunner.main"
        )
        Utils.handleEnvArg(args["dependancies"])
    end

    # Deserialize
    Utils.formatLogMessage(
            "Deserializing function",
            "info",
            "FunctionRunner.jl",
            "FunctionRunner.main"
    )
    func = SerDe.deserializeFunction(args["operation"])
    Utils.formatLogMessage(
            "Deserializied function shown below:  $func\n\n$(methods(func))\n",
            "info",
            "FunctionRunner.jl",
            "FunctionRunner.main"
    )
    if !isnothing(args["parameters"])
        Utils.formatLogMessage(
            "Deserializing function parameters",
            "info",
            "FunctionRunner.jl",
            "FunctionRunner.main"
        )
        params = SerDe.deserializeFunctionParams(args["parameters"])
        Utils.formatLogMessage(
            "$params",
            "info",
            "FunctionRunner.jl",
            "FunctionRunner.main"
        )
        results = func(params...)
    else
        Utils.formatLogMessage(
            "Invoking function with no parameters",
            "info",
            "FunctionRunner.jl",
            "FunctionRunner.main"
        )
        results = func()
    end

    # Handles output serialization
    Utils.formatLogMessage(
        "Determining whether to serialize results",
        "info",
        "FunctionRunner.jl",
        "FunctionRunner.main"
    )
    if args["serializeOutput"]
        Utils.formatLogMessage(
            "Serializing results to base64 encode byte array",
            "info",
            "FunctionRunner.jl",
            "FunctionRunner.main"
        )
        println(args)
        results = SerDe.serializeToBase64(result)
    end

    # Determine where to put results
    targetFile = args["output"]
    Utils.formatLogMessage(
        "Determining where to direct results to",
        "info",
        "FunctionRunner.jl",
        "FunctionRunner.main"
    )
    if isnothing(targetFile)
        Utils.formatLogMessage(
            "No target file provided, returning result",
            "info",
            "FunctionRunner.jl",
            "FunctionRunner.main"
        )
        Utils.formatLogMessage(
            "--- FUNCTION RUNNER OUTPUT ---\n\n$results\n\n--- FUNCTION RUNNER OUTPUT ---",
            "info",
            "FunctionRunner.jl",
            "FunctionRunner.main"
        )
    else
        Utils.formatLogMessage(
            "Sinking results to:\t'$targetFile'",
            "info",
            "FunctionRunner.jl",
            "FunctionRunner.main"
        )
        Utils.sinkToFile(results, targetFile)
    end
    
    Utils.formatLogMessage(
        "Processing completed",
        "info",
        "FunctionRunner.jl",
        "FunctionRunner.main"
    )
end

# Close module
end