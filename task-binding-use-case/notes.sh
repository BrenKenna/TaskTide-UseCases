export PATH="/mnt/c/Users/Brendan Kenna/Documents/GitHub/TaskTide/tasktide/use-cases/task-binding-use-case/Early-Task-Binding/tasktide-0.9.0/bin:$PATH"
export PATH="/mnt/c/Users/Brendan Kenna/Documents/GitHub/TaskTide/tasktide/use-cases/task-binding-use-case/Early-Task-Binding/tasktide-0.9.0/lib:$PATH"



sudo apt update
curl -fsSL https://install.julialang.org | sh

julia-1.12.0-linux-x86_64.tar.gz

sudo snap install julia --classic


```
julia> funcSrc = """
           myFunc(x, y) = return x * y
"""
julia> ops = "N0pMGgQAAAA5ISAgICAgbXlGdW5jKHgsIHkpID0gcmV0dXJuIHggKiB5Cg=="
function deserializeFunction(operation)
    codeStr = String(base64decode(operation))
    return eval(Meta.parse(codeStr))
end

String(base64decode(ops))
"7JL\x1a\x04\0\0\09!     myFunc(x, y) = return x * y\n"


julia> result = run(importCmd)

'''

  _____         _      _____ _     _
 |_   _|_ _ ___| | __ |_   _(_) __| | ___
   | |/ _` / __| |/ /   | | | |/ _` |/ _ \
   | | (_| \__ \   <    | | | | (_| |  __/
   |_|\__,_|___/_|\_\   |_| |_|\__,_|\___|

TaskTide-v0.9.0
_________________________________________________

2025-10-08 18:27:28 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Configuring the CDI Container Provider
2025-10-08 18:27:28 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.configureCdiInstance ]: Starting 'Weld' container



----> Seq tasks were fine

2025-10-10 12:58:17 DEBUG [ pool-3-thread-1 -> org.tasktide.engine.worker.executor.ProcessExecutor.execute ]: Displaying TaskLogging:
{
    "CPU Duration": 0,
    "End Time": 1760097497582,
    "Exit Code": 0,
    "Process Id": 3221,
    "Process Log": {
        "Stderr": [
            "1",
            "2",
            "3"
        ],
        "Stdout": [
            "1",
            "2",
            "3"
        ],
        "id": "ProcessLog-49b6f970-d173-4449-a5a7-a847acb0d042"
    },
    "Start Time": 1760097497521,
    "Thread Name": "pool-3-thread-1",
    "id": "TaskLogging-2b5ab81c-68a0-457c-b22f-8acfd6959624"
}


---> Test running a julia script

julia> run(`bash -c 'set -ex; seq 3'`)
+ seq 3
1
2
3
Process(`bash -c 'set -ex; seq 3'`, ProcessExited(0))

'''



# Debug in jshell
sudo apt install openjdk-17-jdk-headless

jshell

String[] task = {
  "bash", "-c",
  "set -ex; julia --debug \"/mnt/c/Users/Brendan Kenna/Documents/GitHub/TaskTide/tasktide/use-cases/task-binding-use-case/FunctionRunner/src/FunctionRunner.jl\" --operation=\"N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo=\" --parameters=\"N0pMHgQAAAAhBTE2IDIw\" --output=\"/mnt/c/Users/Brendan Kenna/Documents/GitHub/TaskTide/tasktide/use-cases/task-binding-use-case/Early-Task-Binding/results/Multiplication-2.txt\" " 
};

ProcessBuilder pb = new ProcessBuilder(task);
Process process = pb.start();
process ==> Process[pid=6913, exitValue="not exited"]

process.waitFor();
$5 ==> 0

jshell> try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
   ...>     reader.lines().forEach(System.out::println);
   ...> }

'''
Importing Modules
Importing FunctionRunner
Configuring exports
2025-10-10 13:34:35 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Parsing command-line arguments
2025-10-10 13:34:36 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializing function
2025-10-10 13:34:36 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializied function shown below:  mySerdeFunc

# 1 method for generic function "mySerdeFunc" from Main.FunctionRunner.FunctionRunnerSerDe:
 [1] mySerdeFunc(params...; ParseToType)
     @ none:1

2025-10-10 13:34:36 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializing function parameters
2025-10-10 13:34:36 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         SubString{String}["16", "20"]
2025-10-10 13:34:36 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Determining whether to serialize results
2025-10-10 13:34:36 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Determining where to direct results to
2025-10-10 13:34:36 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Sinking results to:     '/mnt/c/Users/Brendan Kenna/Documents/GitHub/TaskTide/tasktide/use-cases/task-binding-use-case/Early-Task-Binding/results/Multiplication-2.txt'
2025-10-10 13:34:36 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Processing completed
'''


# Fails with 1, result looks like a mess because space in directory name
String task = "julia --debug /home/bren/FunctionRunner/src/FunctionRunner.jl --operation=N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo= --parameters=N0pMHgQAAAAhBDE5IDM= --output=/home/bren/Early-Task-Binding/results/Multiplication-0.txt ";


ProcessBuilder pb = new ProcessBuilder(task.replace("\"", "").split(" "));
Process process = pb.start();
process.waitFor();

try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
    reader.lines().forEach(System.out::println);
}

# Run engine as a service
tasktide \
  engine \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "FunctionRunner" \
  --execution-policy "service"

