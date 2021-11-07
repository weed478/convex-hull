module hull

include("geometry.jl")
include("data.jl")
include("ch.jl")
include("chgraham.jl")
include("chjarvis.jl")

using .Geometry
using .Data
using .CH
using .Jarvis
using .Graham

using Plots
using LinearAlgebra: det

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
            title="Dataset $name",
        )
        savefig("output/dataset-$name")
    end

    nothing
end

function runalgos()
    ds = [
        gendefa(),
        gendefb(),
        gendefc(),
        gendefd(),
    ]

    e = 1e-4
    algos = [
        mkjarvis(orient3x3, det, e),
        mkgraham(orient3x3, det, e),
    ]
    
    for d=ds, algo=algos
        name = d.name

        ch = algo(d.pnts)
        savech("output/$algo-$name.txt", ch)

        scatter(
            Tuple.(d.pnts),
            ratio=1,
            label=false,
            title="$algo $name",
        )
        scatter!(
            Tuple.(ch),
            color=:red,
            markersize=5,
            label=false,
        )
        plot!(
            Tuple.(ch),
            label=false,
        )
        savefig("output/$algo-$name")
    end
end

function main()
    visualizedatasets()
    runalgos()

    nothing
end

end # module
