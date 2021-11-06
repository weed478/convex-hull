module Data

export Dataset,
       gendataseta,
       gendatasetb,
       gendatasetc,
       gendatasetd

using ..Geometry

struct Dataset{T}
    name::String
    pnts::AbstractVector{Point{T}}
end

Dataset(
    name::String,
    pnts::AbstractVector{Point{T}},
) where T = Dataset{T}(
    name,
    pnts,
)

Dataset(::Type{T}, d::Dataset{T}) where T = d
Dataset(::Type{T}, d::Dataset) where T = Dataset{T}(
    d.name,
    Point.(T, d.pnts),
)

# generate n random numbers in range [lo,hi]
function uniformrandom(::Type{T}, n::Integer, lo::T, hi::T)::Vector{T} where T
    rand(T, n) * (hi - lo) .+ lo
end

function gendataseta(::Type{T})::Dataset{T} where T
    Dataset{T}(
        "A",
        genpoints(
            T,
            Rect{T}(Point{T}(-1000, -1000), Point{T}(1000, 1000)),
            10^5
        ),
        Segment{T}(
            Point{T}(-1, 0),
            Point{T}(1, .1)
        ),
        T(100),
        T(0),
        T(200),
        1
    )
end

function gendatasetb(::Type{T})::Dataset{T} where T
    Dataset{T}(
        "B",
        genpoints(
            T,
            Rect{T}(Point{T}(-10^14, -10^14), Point{T}(10^14, 10^14)),
            10^5
        ),
        Segment{T}(
            Point{T}(-1, 0),
            Point{T}(1, .1)
        ),
        T(10e12),
        T(1e12),
        T(20e12),
        1
    )
end

function gendatasetc(::Type{T})::Dataset{T} where T
    Dataset{T}(
        "C",
        genpoints(
            T,
            Circle{T}(Point{T}(0, 0), 100),
            1000
        ),
        Segment{T}(
            Point{T}(-1, 0),
            Point{T}(1, .1)
        ),
        T(10),
        T(0),
        T(250),
        2
    )
end

function gendatasetd(::Type{T})::Dataset{T} where T
    # gen X coords
    xs = uniformrandom(T, 1000, T(-1000), T(1000))

    A = Point{T}(-1, 0)
    B = Point{T}(1, .1)

    # calculate line equation
    f = tofunction(Segment{T}(A, B))

    Dataset{T}(
        "D",
        # for each generated X calculate Y
        Point.(zip(xs, f.(xs))) |> collect,
        Segment{T}(
            Point{T}(-1, 0),
            Point{T}(1, .1)
        ),
        T(1e-15),
        T(0),
        T(2e-14),
        2
    )
end

end # module
