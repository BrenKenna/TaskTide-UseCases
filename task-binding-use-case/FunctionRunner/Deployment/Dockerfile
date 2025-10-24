FROM julia:trixie

WORKDIR /opt/julia

ENV JULIA_DEPOT_PATH=/opt/julia/.julia
COPY Project.toml Manifest.toml ./
COPY src ./src
COPY test-invocation.jl ./

RUN julia -e 'using Pkg; cd("/opt/julia"); Pkg.activate("./"); Pkg.instantiate(); Pkg.precompile(); using FunctionRunner; FunctionRunner.Utils'

ENTRYPOINT ["julia", "--project=."]