#!/usr/bin/env julia

#=
The purpose of this Julia script to demonstrate that
 TaskTide is also usable as a function runner, across
 different programming languages. Where output is sank
 into an output file.

Example Usage:
    julia \
        function-runner.jl \
        --operation "BASE64_BYTE" \
        --parameters "BASE64_BYTE" \
        --packageUrl "http/s3/gsiftp://some/path/myTar.gz \
        --output "result.txt" \
        --serializeOutput
=#
using ArgParse, Serialization,
    Base64, Logging, LoggingExtras,
    Dates, Downloads, Tar


#=
1). Configures Logging
=#
function logFormat(args, kwargs, msg)
    level, _module, group, id, file, line = args
    timestamp = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
    return "$timestamp $(lpad(string(level), 5)) [$_module -> $group]: $msg"
end
logger = FileLogger("app.log") do io, args, kwargs, msg
    println(io, logFormat(args, kwargs, msg))
end
global_logger(TeeLogger(ConsoleLogger(stderr), logger))


#=
2). Helper methods for argument parsing,
     sinking data to file, and function inovocation
=#

# Defines and parses command-line arguments
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


# Sinks argument to provided file
function sinkToFile(data, file)
    open(file, "w") do io
        println(io, data)
    end
end


# Invoke function 
function invokeFunction(func, args::Tuple = ())
    return func(args...)
end


#=
3). Base64 byte array Serde
=#

# Deserialize function base64 encoded byte array 
function deserializeFunction(operation)
    bytes = base64decode(operation)
    ioBuff = IOBuffer(bytes)
    return deserialize(ioBuff)
end

# Deserialize parameter base64 encoded byte array to tuple
function deserializeFunctionParams(params::Union{Nothing, String})
    if isnothing(params)
        return ()
    end
    bytes = base64decode(params)
    ioBuff = IOBuffer(bytes)
    return deserialize(ioBuff)
end


# Serailize argument to base64 encoded byte array
function serializeToBase64(param)
    ioBuff = IOBuffer()
    serialize(ioBuff, param)
    return base64encode(take!(ioBuff))
end


#=
4). Fetch program dependancies
=#
function addPathToEnv()
    @info "Package path added to LOAD_PATH:\t'$(pwd())'" _module="function-runner.jl" group="function-runner.addPathToEnv"
    push!(LOAD_PATH, pwd())
end

function fetchUrl(url)
    # Fetch url
    @info "Downloading function dependency:\t'$url'" _module="function-runner.jl" group="function-runner.fetchFromUrl"
    base = basename(url)
    Downloads.download(url, base)
    
    # Unpack
    @info "Unpacking '$base'" _module="function-runner.jl" group="function-runner.fetchFromUrl"
    Tar.extract(base, pwd())
end

function handleEnvArg(envPath)
    if occursin("://", envPath)
        fetchUrl(url)
    end
    addPathToEnv()
end


#=
5). Running as program
=#

# Entrypoint method
function main()

    # Parse arguments
    @info "Parsing command-line arguments" _module="function-runner.jl" group="function-runner.main"
    args = parseArgs()

    # Configure dependancies if supplied
    if args["packageUrl"]
        @info "Fetching function depenancies" _module="function-runner.jl" group="function-runner.main"
        handleEnvArg(args["packageUrl"])
    end

    # Deserialize
    @info "Deserializing & invoking function" _module="function-runner.jl" group="function-runner.main"
    func = deserializeFunction(args["operation"])
    if args["parameters"]
        @info "Deserializing function parameters" _module="function-runner.jl" group="function-runner.main"
        params = deserializeFunctionParams(args["parameters"])
        result = invokeFunction(func, params)
    else
        @info "Invoking function with no parameters" _module="function-runner.jl" group="function-runner.main"
        result = invokeFunction(func)
    end

    # Handles output serialization
    @info "Determining whether to serialize results" _module="function-runner.jl" group="function-runner.main"
    if args["serializeOutput"]
        @info "Serializing results to base64 encode byte array" _module="function-runner.jl" group="function-runner.main"
        result = serializeToBase64(result)
    end

    # Determine where to put results
    targetFile = args["output"]
    @info "Determing where to direct results" _module="function-runner.jl" group="function-runner.main"
    if isnothing(targetFile)
        @info "No target file provided, returning result" _module="function-runner.jl" group="function-runner.main"
        @info "--- BEGIN OUTPUT ---" _module="function-runner.jl" group="function-runner.main"
        println()
        @info "--- END OUTPUT ---" _module="function-runner.jl" group="function-runner.main"
        return result
    else
        @info "Sinking results to file '$targetFile'" _module="function-runner.jl" group="function-runner.main"
        sinkToFile(result, targetFile)
    end
end


# Launch program, also allowing import
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end