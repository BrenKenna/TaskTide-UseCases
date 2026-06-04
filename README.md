# TaskTide Use Cases
<p id="use-cases">
The selected use cases were chosen to evaluate TaskTide's usability across various scenarios encountered in research and production computing environments. Each use case was chosen to assess a specific aspect of the system, including workflow orchestration & execution-context tracking, task-binding semantics, and deployment portability. Together, these examples illustrate how TaskTide can coordinate scalable workflows across heterogeneous Infrastructure Layer Systems (ILS) while maintaining observability, fault tolerance, and backend-agnostic operation. Supporting software and implementation details for each use case are provided within the corresponding sections of the TaskTide repository.
</p>

---

## 1). Workflow Orchestration
<p id="use-cases-1">
Bioinformatic pipeline for sequence alignment, and variant calling. Targetted because of how it demonstrates ETL scale out. Where a set of programs Sequence Alignment, Variant Calling (ie steps of workflow). Are applied over a collection sequence data, inputs for each ETL. The output from each programs, serves as input for the next. The supporting database backend used for TaskTide is a daemonless SQLite database.
</p>


## 2). Task Binding Semantics

### a). Julia Function Runner SerDe
<p id="use-cases-2">
These examples reflect how Data Application Layer software can be developed. Also serves to demonstrate scenarios that are a good fit for TaskTide, and not within this process. Two programs are used here, one is a Julia Function-Runner. Where a function along with its parameters are serialized into a unit of work for TaskTide. Instances of TaskTide engine then run the same Julia program, deserialize the function and its parameters, and store them in configured local. While the use-case demonstrates that TaskTide can be used for early task binding. Tasktide would be more beneficial for longer running jobs, as this space is already solved very efficiently by Notebooks backed by Spark-Livy. The supporting database backend used for TaskTide is a daemonless RocksDB database.
</p>

---

### b). Image Analysis SparkR
<p id="use-cases-3">
The use here is demonstrate how TaskTide can be used inconjuction with Hadoop ecosystem. Where the previous Julia function runner, intentionally shows that TaskTide does not replace mature solutions like Spark-Livy. The following shows a Spark algorithm can be written in R, then each instance applied to a set of inputs. Allowing say a fleet of stand-alone sparkR containers to run the application. The example app performs various operations over an image, generates images, and stacks them into a parquet format. The supporting database backend used for TaskTide is a daemonless RocksDB database.
</p>

---

## 3). AI Train and Deployment
<p id="use-cases-4">
The use-case here is broader demsontrate TaskTide's utility in AI training and deployment. Where a Super Mario play time optimizer is trained with various parameters, and then each is then evaluated by being used to play the game. The use-case is run through containerized deployment and using couchDB as the backend database for TaskTide.
</p>