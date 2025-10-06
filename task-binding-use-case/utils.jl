using TableReader, JSON, Printf, Base64

function serializeToBase64(param)
    ioBuff = IOBuffer()
    serialize(ioBuff, param)
    return base64encode(take!(ioBuff))
end


# Write list of pre-defined parameters to file for import
function writeToFile(
    taskDir, taskName, stepName, 
    annotation, func, listOfTupledParams
)
    
    # Encode function
    encFunc = serializeToBase64(func)
    
    counter = 0
    workItems = []
    for param in listOfTupledParams

        label= "$taskName-$counter"
        encParam = serializeToBase64(join(param, " "))
        task = "function-runner.jl --operation=$encFunc --parameters=$encParam --output=$taskDir/$label.txt"

        workItem = Dict(
            "task_name" => taskName,
            "step_name" => stepName,
            "annotation" => annotation,
            "task" => task
        )
        
        push!(tasks, Dict(
            "task_name" => taskName,
            "step_name" => stepName,
            "annotation" => annotation,
            "task" => task
        ))
        
    end
    
    outFile = "$(taskName)-tasks.json"
    open(outFile, "w") do io
        JSON.print(io, tasks; indent=4)
    end
    
end



# Write 
