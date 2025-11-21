# Use Case Notes
<p>
Contains notes on any issues/limitations from running TaskTide during each use-case. Depending on the type, these lead to redeployment to verify change(s), in addition to unit-tests.
</p>

<p>
Story is in the use-cases workflow development, and deployment. Where even with some Spark/Distributed
 session, can be case the rollout can be benefitted by transparency offered by TaskTide.
</p>


## 1). Workflow Orchestration
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


## 2). Task Binding
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
<ul>