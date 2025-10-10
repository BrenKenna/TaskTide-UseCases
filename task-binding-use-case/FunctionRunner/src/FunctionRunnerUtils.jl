"""
`FunctionRunnerUtils.jl`

A set of methods supporting use of TaskTide
    in Julia as an Arbitrary Function Runner

```text
Exports:
    Methods - writeTasksToJsonFile, randomNumbers

    Modules - FunctionRunnerSerDe as SerDe
```
"""
module FunctionRunnerUtils

using JSON, Random,
    Printf, Dates

using ArgParse, Tar,
    LoggingExtras, Downloads


include("./FunctionRunnerSerDe.jl")
using .FunctionRunnerSerDe
const SerDe = FunctionRunnerSerDe

PACKAGE_DIR = @__DIR__
export writeTasksToJsonFile, randomNumbers, SerDe


"""
`
randomNumbers(size::Int, min::Int, max::Int)
    -> [ (Int, Int) ]
`

Produce randomized 2D array of numbers
"""
function randomNumbers(size, min, max)
    return [
        (rand(min:max), rand(min:max)) for _ in 1:size
    ]
end



"""
`
writeTasksToJsonFile(
    taskDir::String, taskName::String, stepName::String, 
    annotation::String, func::String,
    listOfTupledParams::Vector{Tuple{Vararg{String}}}
) -> String
`

Write a list of pre-defined parameters to file for import
"""
function writeTasksToJsonFile(
    taskDir, taskName, stepName, 
    annotation, func, listOfTupledParams
)
    
    # Encode function
    encFunc = SerDe.serializeToBase64(func)
    
    # Setup tasks for each parameter
    counter = 0
    taskCollection = []
    for param in listOfTupledParams

        # Define labels
        taskDict = makeTaskDict(
            taskName, counter,
            param, annotation,
            taskDir, encFunc,
            stepName
        )
        
        # Push to json array
        push!(taskCollection, taskDict)
        counter += 1
    end

    # Write collection to file
    writeJson(taskName, taskCollection, taskDir)
end


"""
`
makeTaskDict(
      taskName::String, counter::Int,
      param::String, annotation::Dict,
      taskDir::String, encFunc::String,
      stepName::String
) -> Dict
`

Represent task parameters as a dictionary/json
"""
function makeTaskDict(
    taskName, counter,
    param, annotation,
    taskDir, encFunc,
    stepName
)

    # Configure task
    label= "$taskName-$counter"
    encParam = SerDe.serializeToBase64(join(param, " "))
    task = """julia --debug "$PACKAGE_DIR/FunctionRunner.jl" --operation="$encFunc" --parameters="$encParam" --output="$taskDir/results/$label.txt" """

    # Represent as an object
    taskDict = Dict(
        "Task Name" => taskName,
        "Step Name" => stepName,
        "Annotations" => annotation,
        "Task Script" => task
    )
    return taskDict
end


"""
`
writeJson(taskName::String, taskCollection::Vector{Dict}, taskDir::String)
`

Dump task collection to json file
"""
function writeJson(taskName, taskCollection, taskDir)
    outFile = "$taskDir/$(taskName)-tasks.json"
    open(outFile, "w") do io
        JSON.print(io, taskCollection)
    end
    println("Tasks written to:\t'$outFile'")
end


"""
`
sinkToFile(data::String, file::String)
`

Sinks argument to provided file
"""
function sinkToFile(data, file)

    # Create directory
    dir = dirname(file)
    if !isempty(dir) && !isdir(dir)
        mkpath(dir)
    end

    # Write file
    open(file, "w") do io
        println(io, data)
    end
end


"""
`
formatLogMessage(msg, level, __module, __method)
`

Formats log message as '< TIME > < LEVEL > [< CLASS > -> < METHOD >]:\\t< MSG >
"""
function formatLogMessage(msg, level, __module, __method)
    timestamp = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
    println("$timestamp $(uppercase(level))  [ $__module -> $__method ]: \t$msg")
    flush(stdout)
end


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
    formatLogMessage(
        "Package path added to LOAD_PATH:\t'$envPath'",
        "info",
        "FunctionRunner.jl",
        "FunctionRunner.addPathToEnv"
    )
    push!(LOAD_PATH, envPath)
end


"""
`fetchUrl(url::String)`

Download, and unpack archive from provided URL
"""
function fetchUrl(url)

    # Fetch url
    formatLogMessage(
        "Downloading function dependency:\t'$url'",
        "info",
        "FunctionRunner.jl",
        "FunctionRunner.fetchFromUrl"
    )
    base = basename(url)
    Downloads.download(url, base)
    
    # Unpack
    formatLogMessage(
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


# Close module
end