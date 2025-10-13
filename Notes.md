# Use Case Notes
<p>
Contains notes on any issues/limitations from running TaskTide during each use-case. Depending on the type, these lead to repdeployment to verify change(s).
</p>


## 1). Workflow
<ul>
    <li>How would config validator look?</li>
    <li>Configure log dirs</li>
    <li>Open resetting by step</li>
    <li>Best use of wrapper script</li>
    <li>Target is ManagerClient twice, keep below</li>
    <li>Better make global, is common between these two</li>
    <li>Manager client only imports</li>
    <li>Target step not picked up in either of the clients</li>
    <li>File path not picked up on command-line</li>
</ul>


## 2). Task Binding
<p>
Story is in the use-cases workflow development, and deployment. Where even with some Spark/Distributed
 session, can be case the rollout can be benefitted by transparency offered by TaskTide.
</p>
<ul>
    <li>Need for REST API</li>
    <li>Ideal use is not arbitrary function runner (Hadoop). But workflow orchestration</li>
    <li>Provided development oppurtunities</li>
    <li>ManagerTask JSON & WorkItem converter</li>
    <li>ItemTaskExecutor can apply results file if annotated on ItemTask with 'Results Path'</li>
    <li>Manager Task has nestLabel field to denote task collection for WI?</li>
    <li>User defined wrapper for running TaskScript</li>
    <li>Terminating engine loop in favour of TaskTide-Client</li>
<ul>