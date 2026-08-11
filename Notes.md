# Use Case Notes
<p>
Contains notes on any issues/limitations from running TaskTide during each use-case. Depending on the type, these lead to redeployment to verify change(s), in addition to unit-tests. Entries would ideally be a little higher level than those in the <a href="/CHANGELOG.adoc">change log</a>, because want to catch and collect these for version-1. Allows the MVP from first use-case, to be compared to version-1 artifact, and plan out v2 deliverables.
</p>


## 1). Workflow Orchestration - Sept/2025
<ul>
    <li>How would config validator look?</li>
    <li>Configure log dirs</li>
    <li>Open resetting by step</li>
    <li>Best use of wrapper script</li>
    <li>Make client choice global</li>
    <li>Exapand manage client CRUD operation</li>
    <li>Target step not picked up in either of the clients</li>
    <li>Make input file references as file path stream, not resource stream</li>
</ul>


## 2). Task Binding - Oct/2025 -> Apr/2026
<ul>
    <li>Need for REST API</li>
    <li>Ideal use is not arbitrary function runner (Hadoop). But workflow orchestration</li>
    <li>ManagerTask JSON & WorkItem converter</li>
    <li>ItemTaskExecutor can apply results file if annotated on ItemTask with 'Results Path'</li>
    <li>Manager Task has nestLabel field to denote task collection for WI?</li>
    <li>User defined wrapper for running TaskScript</li>
    <li>Terminating engine loop in favour of TaskTide-Client</li>
    <li>Multi-threaded rocksDB bug not caught locally</li>
    <li>Import Job Environment, and attach Id to WorkItem/ItemTask</li>
    <li>Each thread should process their own list, instead of full whack</li>
    <li>Task ordering should be configurable, defaulting to shuffled</li>
    <li>Job Environment DB created, but no data</li>
    <li>Tasks seen but not processed in service mode</li>
    <li>Reserved annotation keys</li>
    <li>Some edge case in parallelism not handled, build up components and return</li>
    <li>WebAPI will make the deployment use-case make more sense</li>
    <li>A lot of time spent on Mutex - Need bucketing and connection pool strategy</li>
    <li>Interfaces & implementation for buketing and pool strategy work nicely</li>
    <li>Refine applying to TaskTide carefully for v2</li>
</ul>


## 3). Deployment - May/2026 -> Aug/2026
<ul>
    <li>Adjusted engine into a Worker, which Acquires workload, Traverses that Workload and Process then Executes workload</li>
    <li>New engine is much neater, and easier to test and resolve parallelism bug</li>
    <li>Acquisition interface made "slipping in" the Workflow aspect very fluid</li>
    <li>Acquisition interface supported Workflow configuration with different strategies-Sequenital, Round Robin</li>
    <li>WebAPI very nice addition to AI Agent use-case. Given the autentication strategy scheme, not too concerned about IdP atm</li>
    <li>Engine worker is a little busy, but this business is a little nuance and tricky. Should comeback with fresh v2 eyes</li>
    <li>Train and play workflow with automated enqueuing worked very nicely</li>
    <li>Publishing bare TaskTide, and TaskTide-Apptainer image will support a broader set of uses</li>
    <li>For v2 - Should make the client interface a low level spec that each lib can hold logic for, root TaskTide can then take main</li>
    <li>Combining the TaskTide-Reposiotry result set size with EngineWorker window size, gives nice way to fetch randomly sorted workload</li>
</ul>