import Pkg
Pkg.activate("$(@__DIR__)/..")
Pkg.instantiate()

cd("$(@__DIR__)/..")
include("hull.jl")
rm("output", force=true, recursive=true)
mkpath("output")
hull.main()
