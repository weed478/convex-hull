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
using DataFrames

function manualdet(M::Matrix{T})::T where T
    if size(M) == (2, 2)
        M[1,1] * M[2,2] - M[1,2] * M[2,1]
    elseif size(M) == (3, 3)
          M[1,1] * M[2,2] * M[3,3] + M[1,2] * M[2,3] * M[3,1] + M[1,3] * M[2,1] * M[3,2] - M[3,1] * M[2,2] * M[1,3] - M[3,2] * M[2,3] * M[1,1] - M[3,3] * M[2,1] * M[1,2]
    else
        error("Invalid matrix size $(size(M))")
    end
end

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

    e = eps(1000.)
    algos = [
        mkjarvis(orient2x2, manualdet, e),
        mkgraham(orient2x2, manualdet, e),
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
            Tuple.([ch; ch[1]]),
            label=false,
        )
        savefig("output/$algo-$name")
    end
end

function runbenchmarks()
    mkds = [
        n -> gendataseta(Float64, n, -100., 100.),
        n -> gendatasetb(Float64, n, Point(0., 0.), 10.),
        n -> gendatasetc(Float64, n, Point(-10., -10.), Point(10., 10.)),
        n -> gendatasetd(Float64, n, n, Point(0., 0.), Point(10., 10.)),
    ]

    e = eps(1000.)
    mkalgos = [
        function jarvis() mkjarvis(orient2x2, manualdet, e) end,
        function graham() mkgraham(orient2x2, manualdet, e) end,
    ]

    df = DataFrame(:n => 10:10:1000)
    
    for mkd=mkds, mkalgo=mkalgos
        T = zeros(Float64, length(df.n))
        dname = mkd(1).name
        for ni=1:length(df.n)
            algo = mkalgo()
            d = mkd(df.n[ni])
            t1 = @elapsed algo(d.pnts)
            t2 = @elapsed algo(d.pnts)
            T[ni] = min(t1, t2)
        end
        insertcols!(df, "$(dname)-$mkalgo" => T)
    end

    for d='A':'D'
        plot(
            df.n[2:end],
            df[2:end, "$d-graham"],
            label="graham",
            title="Dataset $d",
        )
        plot!(
            df.n[2:end],
            df[2:end, "$d-jarvis"],
            label="jarvis",
        )
        savefig("output/bench-$d")
    end
end

function main()
    visualizedatasets()
    runalgos()
    runbenchmarks()

    nothing
end

end # module
