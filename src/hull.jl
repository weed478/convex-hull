# Główny plik programu

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
        # dla macierzy 2x2 licz mnożeniem na krzyż
        M[1,1] * M[2,2] - M[1,2] * M[2,1]
    elseif size(M) == (3, 3)
        # dla 3x3 licz wzorem Sarrusa
        M[1,1] * M[2,2] * M[3,3] + M[1,2] * M[2,3] * M[3,1] + M[1,3] * M[2,1] * M[3,2] - M[3,1] * M[2,2] * M[1,3] - M[3,2] * M[2,3] * M[1,1] - M[3,3] * M[2,1] * M[1,2]
    else
        error("Invalid matrix size $(size(M))")
    end
end

# generatory danych jak w temacie zadania
gendefa() = gendataseta(Float64, 100, -100., 100.)
gendefb() = gendatasetb(Float64, 100, Point(0., 0.), 10.)
gendefc() = gendatasetc(Float64, 100, Point(-10., -10.), Point(10., 10.))
gendefd() = gendatasetd(Float64, 25, 20, Point(0., 0.), Point(10., 10.))

# rysuje punkty w zbiorach danych
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

# podstawowe obliczanie otoczek dla domyślnych zbiorów
function runalgos()
    ds = [
        gendefa(),
        gendefb(),
        gendefc(),
        gendefd(),
    ]

    e = 1e-20
    algos = [
        mkjarvis(orient2x2, manualdet, e),
        mkgraham(orient2x2, manualdet, e),
    ]

    algonames = [
        "Jarvis",
        "Graham",
    ]
    
    for d=ds, (algo, algoname)=zip(algos, algonames)
        name = d.name

        ch = algo(d.pnts)

        # zapisz punkty otoczki w pliku
        savech("output/$algo-$name.txt", ch)

        # nanieś punkty zbioru
        scatter(
            Tuple.(d.pnts),
            ratio=1,
            label=false,
            title="$algoname, Dataset $name",
        )
        # następnie punkty otoczki zaznacz na czerwono
        scatter!(
            Tuple.(ch),
            color=:red,
            markersize=5,
            label=false,
        )
        # połącz punkty otoczki linią
        plot!(
            Tuple.([ch; ch[1]]),
            label=false,
        )
        savefig("output/$algo-$name")
    end
end

function runbenchmarks()
    # tablica funkcji tworzących zbiory o podanej (n) liczbie punktów
    mkds = [
        n -> gendataseta(Float64, n, -100., 100.),
        n -> gendatasetb(Float64, n, Point(0., 0.), 10.),
        n -> gendatasetc(Float64, n, Point(-10., -10.), Point(10., 10.)),
        n -> gendatasetd(Float64, n, n, Point(0., 0.), Point(10., 10.)),
    ]

    e = 1e-20
    algos = [
        mkjarvis(orient2x2, manualdet, e),
        mkgraham(orient2x2, manualdet, e),
    ]

    # tabela będzie zawierać wyniki benchmarków
    df = DataFrame(:n => 10:10:1000)

    # dla każdej kombinacji zbioru i algorytmu
    for mkd=mkds, algo=algos
        # tablica czasów wykonania dla każdego n
        T = fill(Inf, length(df.n))

        # wygeneruj zbiór
        ds = mkd.(df.n)
        dname = ds[1].name

        # wykonaj 4 próby dla każdego n
        for sample=1:4, i=1:length(ds)
            d = ds[i]
            # zmierz czas wykonania
            t = @elapsed algo(d.pnts)
            T[i] = min(T[i], t)
        end

        # dodaj wynik dla tego algorymu
        insertcols!(df, "$dname-$algo" => T)
    end

    # rysuje wykresy czasu wykonania
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
    # zbiory danych
    ds = [
        gendefa(),
        gendefb(),
        gendefc(),
        gendefd(),
    ]

    e = 1e-20
    algo = mkgraham(orient2x2, manualdet, e)
    
    # dla każdego zbioru
    for d=ds
        name = d.name
        # folder na klatki animacji
        mkpath("output/anim-graham-$name")

        # wykonaj algorytm i zapisuj etapy do tablicy steps
        steps = Vector{GrahamStep}()
        algo(d.pnts, steps=steps)

        anim = Animation()

        # narysuj punkty zbioru
        scatter(
            Tuple.(d.pnts),
            color=:blue,
            ratio=1,
            title="Step 0",
        )
        frame(anim)
        savefig("output/anim-graham-$name/0")

        # budowanie animacji
        for (i, step)=enumerate(steps)
            # pozostałe punkty do rozważenia na niebiesko
            scatter(
                Tuple.(step.remaining),
                color=:blue,
                opacity=0.3,
                ratio=1,
                title="Step $i",
                label="Remaining",
            )
            # punkty otoczki na zielono
            scatter!(
                Tuple.(step.ch),
                color=:green,
                label="Hull"
            )
            # połącz punkty otoczki i narysuj strzałkę do ostatniego
            plot!(
                Tuple.(step.ch),
                color=:green,
                line=:arrow,
                label=false,
            )
            # zaznacz aktualnie rozważany punkt na zielono lub niebiesko (jeśli zostanie zaraz dodany do otoczki)
            scatter!(
                Tuple.([step.current]),
                color=step.ok ? :green : :red,
                markersize=5,
                label="Current ($(step.ok ? "good" : "bad"))"
            )
            frame(anim)
            savefig("output/anim-graham-$name/$i")
        end

        gif(anim, "output/anim-graham-$name.gif", fps=15)
    end
end

function visualizejarvis()
    # zbiory danych, dla B weź mniej punktów aby zmniejszyć rozmiar animacji
    ds = [
        gendefa(),
        gendatasetb(Float64, 10, Point(0., 0.), 10.),
        gendefc(),
        gendefd(),
    ]

    e = 1e-20
    algo = mkjarvis(orient2x2, manualdet, e)
    
    # identycznie jak dla grahama
    for d=ds
        name = d.name
        mkpath("output/anim-jarvis-$name")
        steps = Vector{JarvisStep}()
        algo(d.pnts, steps=steps)

        anim = Animation()

        scatter(
            Tuple.(d.pnts),
            color=:blue,
            ratio=1,
            title="Step 0",
        )
        frame(anim)
        savefig("output/anim-jarvis-$name/0")

        for (i, step)=enumerate(steps)
            scatter(
                Tuple.(d.pnts),
                color=:blue,
                opacity=0.3,
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
                label=false,
            )
            scatter!(
                Tuple.([step.best]),
                color=:red,
                markersize=8,
                label="Best",
            )
            plot!(
                Tuple.([step.ch[end], step.best]),
                color=:red,
                line=:arrow,
                label=false,
            )
            scatter!(
                Tuple.([step.current]),
                color=[step.isnewbest ? :green : :orange],
                markersize=8,
                label="Current$(step.isnewbest ? " (new best)" : ""))",
            )
            plot!(
                Tuple.([step.ch[end], step.current]),
                color=:orange,
                line=:arrow,
                label=false,
            )
            frame(anim)
            savefig("output/anim-jarvis-$name/$i")
        end

        gif(anim, "output/anim-jarvis-$name.gif", fps=30)
    end
end

# funkcja pomocnicza rysująca otoczkę
function plotch(d, algo, ch)
    name = d.name
    # punkty zbioru
    scatter(
        Tuple.(d.pnts),
        ratio=1,
        label=false,
        title="$algo, Dataset $name",
    )
    # punkty otoczki
    scatter!(
        Tuple.(ch),
        color=:red,
        markersize=5,
        label=false,
    )
    # połącz linią
    plot!(
        Tuple.([ch; ch[1]]),
        label=false,
    )
end

# przypadek kiedy algorytmy nie działają
function breakthings()
    # zbiory danych generowane typem Float32
    ds = [
        gendatasetc(Float32, 100, Point(-1f20, -1f20), Point(1f20, 1f20)),
        gendatasetd(Float32, 25, 20, Point(0f0, 0f0), Point(1f20, 1f20)),
    ]

    # algorytm również dobrany do typu Float32
    algo = mkgraham(orient2x2, det, 1f-20)

    # kilka rysunków
    ch = algo(ds[1].pnts)
    savech("output/broken-graham-C.txt", ch) # zapis punktów do pliku
    plotch(ds[1], "Graham", ch)
    savefig("output/broken-graham-C")

    ch = algo(ds[2].pnts)
    savech("output/broken-graham-D.txt", ch)
    plotch(ds[2], "Graham", ch)
    savefig("output/broken-graham-D")

    algo = mkjarvis(orient2x2, det, 1f-20)

    ch = algo(ds[1].pnts)
    savech("output/broken-jarvis-C.txt", ch)
    plotch(ds[1], "Jarvis", ch)
    savefig("output/broken-jarvis-C")

    ch = algo(ds[2].pnts)
    savech("output/broken-jarvis-D.txt", ch)
    plotch(ds[2], "Jarvis", ch)
    savefig("output/broken-jarvis-D")
end

function main()
    visualizedatasets()
    runalgos()
    runbenchmarks()
    visualizegraham()
    visualizejarvis()
    breakthings()

    nothing
end

end # module
