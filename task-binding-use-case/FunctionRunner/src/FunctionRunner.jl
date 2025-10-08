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


# Include utility and SerDe
include("./FunctionRunnerUtils.jl")
using .FunctionRunnerUtils
const Utils = FunctionRunnerUtils

include("./FunctionRunnerSerDe.jl")
using .FunctionRunnerSerDe
const SerDe = FunctionRunnerSerDe


# Configure exports
export invokeFunction, deserializeFunction,
    deserializeFunctionParams, serializeToBase64,
    handleEnvArg, Utils, SerDe


"""
`logFormat(args, kwargs, msg) -> String`

Configures Logging format
"""
function logFormat(args, kwargs, msg)
    level, _module, group, id, file, line = args
    timestamp = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
    return "$timestamp $(lpad(string(level), 5)) [$_module -> $group]: $msg"
end


"""
`setupLogging(logFile="app.log")`

Sets up logging
"""
function setupLogging(logFile="app.log")
    if isnothing(FUNCTIONRUNNER_LOGGER[])
        logger = FileLogger(logFile) do io, args, kwargs, msg
            println(io, logFormat(args, kwargs, msg))
        end
        FUNCTIONRUNNER_LOGGER[] = TeeLogger(ConsoleLogger(stderr), logger)
        global_logger(FUNCTIONRUNNER_LOGGER[])
    end
end


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
            action = :store_false
    end

    # Parse and return
    return parse_args(parser)
end


"""
`
sinkToFile(data::String, file::String)
`

Sinks argument to provided file
"""
function sinkToFile(data, file)
    open(file, "w") do io
        println(io, data)
    end
end


#=
4). Fetch program dependancies
=#

"""
`addPathToEnv(envPath::String)`

Adds current directory to LOAD_PATH
"""
function addPathToEnv(envPath)
    @info "Package path added to LOAD_PATH:\t'$envPath'" _module="FunctionRunner.jl" group="FunctionRunner.addPathToEnv"
    push!(LOAD_PATH, envPath)
end


"""
`fetchUrl(url::String)`

Download, and unpack archive from provided URL
"""
function fetchUrl(url)
    # Fetch url
    @info "Downloading function dependency:\t'$url'" _module="FunctionRunner.jl" group="FunctionRunner.fetchFromUrl"
    base = basename(url)
    Downloads.download(url, base)
    
    # Unpack
    @info "Unpacking '$base'" _module="FunctionRunner.jl" group="FunctionRunner.fetchFromUrl"
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


#=
5). Running as program
=#

"""
`main()`

Runs program
"""
function main()

    # Parse arguments
    @info "Parsing command-line arguments" _module="FunctionRunner.jl" group="FunctionRunner.main"
    args = parseArgs()

    # Configure dependancies if supplied
    if args["packageUrl"]
        @info "Fetching function depenancies" _module="FunctionRunner.jl" group="FunctionRunner.main"
        handleEnvArg(args["packageUrl"])
    end

    # Deserialize
    @info "Deserializing & invoking function" _module="FunctionRunner.jl" group="FunctionRunner.main"
    func = SerDe.deserializeFunction(args["operation"])
    if args["parameters"]
        @info "Deserializing function parameters" _module="FunctionRunner.jl" group="FunctionRunner.main"
        params = deserializeFunctionParams(args["parameters"])
        result = SerDe.invokeFunction(func, params)
    else
        @info "Invoking function with no parameters" _module="FunctionRunner.jl" group="FunctionRunner.main"
        result = SerDe.invokeFunction(func)
    end

    # Handles output serialization
    @info "Determining whether to serialize results" _module="FunctionRunner.jl" group="FunctionRunner.main"
    if args["serializeOutput"]
        @info "Serializing results to base64 encode byte array" _module="FunctionRunner.jl" group="FunctionRunner.main"
        result = SerDe.serializeToBase64(result)
    end

    # Determine where to put results
    targetFile = args["output"]
    @info "Determing where to direct results" _module="FunctionRunner.jl" group="FunctionRunner.main"
    if isnothing(targetFile)
        @info "No target file provided, returning result" _module="FunctionRunner.jl" group="FunctionRunner.main"
        @info "--- BEGIN OUTPUT ---" _module="FunctionRunner.jl" group="FunctionRunner.main"
        println()
        @info "--- END OUTPUT ---" _module="FunctionRunner.jl" group="FunctionRunner.main"
        return result
    else
        @info "Sinking results to file '$targetFile'" _module="FunctionRunner.jl" group="FunctionRunner.main"
        sinkToFile(result, targetFile)
    end
end


# Launch program, also allowing import
if abspath(PROGRAM_FILE) == @__FILE__
    setupLogging()
    main()
end

# Close module
end