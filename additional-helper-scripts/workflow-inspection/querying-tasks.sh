#!/bin/bash


# Fetch tasks and pilot label
echo -e "SELECT Payload FROM Items;" | \
    sqlite3 itemStoreRepo/sqlite/WORKITEM/master | \
    jq '{
        ItemName: .ItemName,
        Id: .Id,
        Annotations: .annotations.Annotations."Pilot Label"
    }'


# Fetch tasks, and process states
echo -e "SELECT Payload FROM Items;" | \
  sqlite3 ItemStoreRepository/sqlite/WORKITEM/master | \
  jq '{
    Id: .Id,
    State: .ItemState,
    TaskMap: (
      .Workload.TaskMap 
      | to_entries 
      | map({
          Id: .value.id,
          TaskName: .key,
          ExitCode: .value["Task Log"]["Exit Code"],
          ProcessId: .value["Task Log"]["Process Id"],
          TaskState: .value["Task Log"]["Task State"],
          ThreadName: .value["Task Log"]["Thread Name"],
          EndTime: .value["Task Log"]["End Time"],
          StartTime: .value["Task Log"]["Start Time"]
        })
    )}'