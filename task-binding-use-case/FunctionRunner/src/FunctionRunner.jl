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

using ArgParse, Tar,
    LoggingExtras, Downloads

using Dates, Logging
const FUNCTIONRUNNER_LOGGER = Ref{Union{AbstractLogger, Nothing}}(nothing)


# Include utility and SerDe
include("./FunctionRunnerUtils.jl")
using .FunctionRunnerUtils
const Utils = FunctionRunnerUtils

include("./FunctionRunnerSerDe.jl")
using .FunctionRunnerSerDe
const SerDe = FunctionRunnerSerDe


# Configure exports
export handleEnvArg, Utils, SerDe

#=
2). Helper methods for argument parsing,
     sinking data to file, and function inovocation
=#

"""
`parseArgs() -> ArgParser`

Defines and parses command-line arguments
"""
function parseArgs()

    # Define arguments
    parser = ArgParseSettings()
    @add_arg_table parser begin
        "--operation"
            help = "Base64 encoded serailized Julia function"
            arg_type = String
            required = true

        "--parameters"
            help = "Base64 encoded serialized function params"
            arg_type = String
            required = false

        "--dependancies"
            help = "Add package dependancies, downloading and unpacking tar archive if contains '://'"
            arg_type = String
            required = false

        "--output"
            help = "File to write function result"
            arg_type = String

        "--serializeOutput"
            help = "Flag for whether output should be serialized"
            action = :store_true
    end

    # Parse and return
    return parse_args(parser)
end


#=
4). Fetch program dependancies
=#

"""
`addPathToEnv(envPath::String)`

Adds current directory to LOAD_PATH
"""
function addPathToEnv(envPath)
    # @info "Package path added to LOAD_PATH:\t'$envPath'" _module="FunctionRunner.jl" group="FunctionRunner.addPathToEnv"
    push!(LOAD_PATH, envPath)
end


"""
`fetchUrl(url::String)`

Download, and unpack archive from provided URL
"""
function fetchUrl(url)

    # Fetch url
    Utils.formatLogMessage(
        "Downloading function dependency:\t'$url'",
        "info",
        "FunctionRunner.jl",
        "FunctionRunner.fetchFromUrl"
    )
    # @info  _module="FunctionRunner.jl" group=
    base = basename(url)
    Downloads.download(url, base)
    
    # Unpack
    Utils.formatLogMessage(
        "Unpacking '$base'",
        "info",
        "FunctionRunner.jl",
        "FunctionRunner.fetchFromUrl"
    )
    Tar.extract(base, pwd())
end


"""
`handleEnvArg(envPath::String)`

Handles adding provided environment path to LOAD_PATH.
 If envPath is tar balled URL, resource is downloaded
   and current directory is added
"""
function handleEnvArg(envPath)
    if occursin("://", envPath)
        fetchUrl(envPath)
        addPathToEnv(pwd())
    end
    addPathToEnv(envPath)
end


# Launch program, also allowing import
if abspath(PROGRAM_FILE) == @__FILE__
    
    # Parse arguments
    #Base.flush_open(stdout)
    results = ""
    Utils.formatLogMessage(
        "Parsing command-line arguments",
        "info",
        "FunctionRunner.jl",
        "FunctionRunner.main"
    )
    args = parseArgs()

    # Configure dependancies if supplied
    if !isnothing(args["dependancies"])
        Utils.formatLogMessage(
            "Fetching function depenancies",
            "info",
            "FunctionRunner.jl",
            "FunctionRunner.main"
        )
        handleEnvArg(args["dependancies"])
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