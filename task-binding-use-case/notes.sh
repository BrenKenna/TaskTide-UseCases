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

'''