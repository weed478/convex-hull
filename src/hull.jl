module hull

include("geometry.jl")
include("data.jl")
include("chgraham.jl")
include("chjarvis.jl")

using .Geometry
using .Data

using Plots

function visualizedatasets()
    da = gendataseta(Float64, 100, -100., 100.)
    db = gendatasetb(Float64, 100, Point(0., 0.), 10.)
    dc = gendatasetc(Float64, 100, Point(-10., -10.), Point(10., 10.))
    dd = gendatasetd(Float64, 25, 20, Point(0., 0.), Point(10., 10.))

    for d in [da, db, dc, dd]
        name = d.name
        scatter(
            Tuple.(d.pnts),
            ratio=1,
            label=false,
            caption="Dataset $name",
        )
        savefig("output/dataset-$name")
    end

    nothing
end

function main()
    visualizedatasets()

    nothing
end

end # module
