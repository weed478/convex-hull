module hull

include("geometry.jl")
include("data.jl")
include("chgraham.jl")
include("chjarvis.jl")

using .Geometry
using .Data
using .Jarvis

using Plots

gendefa() = gendataseta(Float64, 100, -100., 100.)
gendefb() = gendatasetb(Float64, 100, Point(0., 0.), 10.)
gendefc() = gendatasetc(Float64, 100, Point(-10., -10.), Point(10., 10.))
gendefd() = gendatasetd(Float64, 25, 20, Point(0., 0.), Point(10., 10.))

function visualizedatasets()
    ds = [
        gendefa(),
        gendefb(),
        gendefc(),
        gendefd(),
    ]

    for d in ds
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

function runjarvis()
    ds = [
        gendefa(),
        gendefb(),
        gendefc(),
        gendefd(),
    ]
    
    for d=ds
        name = d.name

        ch = chjarvis(d.pnts)

        scatter(
            Tuple.(d.pnts),
            ratio=1,
            label=false,
            caption="Jarvis $name",
        )
        plot!(
            Tuple.(ch),
            label=false,
        )
        savefig("output/jarvis-$name")
    end
end

function main()
    visualizedatasets()
    runjarvis()

    nothing
end

end # module
