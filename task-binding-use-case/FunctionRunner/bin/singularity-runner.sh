#!/bin/bash


. ~/start.sh >> /dev/null
. ~/conda-env.sh

conda activate singularity_env
which singularity

set -ex
singularity exec \
  --writable \
  --pwd /opt/julia \
  --env JULIA_DEPOT_PATH=/opt/julia/.julia \
  --env JULIA_PKG_PRECOMPILE_DIR=/opt/julia/.julia/compiled \
  $JULIA_MODULES/FunctionRunnerSandBox \
  julia --project=. $@