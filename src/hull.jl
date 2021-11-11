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
    algos = [
        mkjarvis(orient2x2, manualdet, e),
        mkgraham(orient2x2, manualdet, e),
    ]

    df = DataFrame(:n => 10:10:1000)
    
    for mkd=mkds, algo=algos
        T = fill(Inf, length(df.n))
        ds = mkd.(df.n)
        dname = ds[1].name
        for sample=1:4, i=1:length(ds)
            d = ds[i]
            t = @elapsed algo(d.pnts)
            T[i] = min(T[i], t)
        end
        insertcols!(df, "$dname-$algo" => T)
    end

    for d='A':'D'
        plot(
            df.n,
            df[:, "$d-chgraham"],
            xlabel="Number of points",
            ylabel="Time [s]",
            label="graham",
            title="Dataset $d",
        )
        plot!(
            df.n,
            df[:, "$d-chjarvis"],
            xlabel="Number of points",
            ylabel="Time [s]",
            label="jarvis",
        )
        savefig("output/bench-$d")
    end
end

function visualizegraham()
    ds = [
        gendefa(),
        gendefb(),
        gendefc(),
        gendefd(),
    ]

    e = eps(1000.)
    algo = mkgraham(orient2x2, manualdet, e)
    
    for d=ds
        name = d.name
        mkpath("output/anim-graham-$name")
        steps = Vector{GrahamStep}()
        algo(d.pnts, steps=steps)

        scatter(
            Tuple.(d.pnts),
            color=:blue,
            ratio=1,
            title="Step 0",
        )
        savefig("output/anim-graham-$name/0")
        for (i, step)=enumerate(steps)
            scatter(
                Tuple.(d.pnts),
                color=:blue,
                opacity=0.2,
                ratio=1,
                title="Step $i",
                label=false,
            )
            scatter!(
                Tuple.(step.ch),
                color=:green,
                label="Hull"
            )
            plot!(
                Tuple.(step.ch),
                color=:green,
                line=:arrow,
                label=false,
            )
            scatter!(
                Tuple.([step.current]),
                color=step.ok ? :green : :red,
                markersize=5,
                label="Current ($(step.ok ? "good" : "bad"))"
            )
            savefig("output/anim-graham-$name/$i")
        end
    end
end

function main()
    visualizedatasets()
    runalgos()
    runbenchmarks()
    visualizegraham()

    nothing
end

end # module
