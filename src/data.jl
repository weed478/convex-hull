module Data

export Dataset,
       gendataseta,
       gendatasetb,
       gendatasetc,
       gendatasetd

using ..Geometry

import Random

const SEED = 42

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
function runif(::Type{T}, n::Integer, lo::T, hi::T)::Vector{T} where T
    rand(T, n) * (hi - lo) .+ lo
end

function gendataseta(::Type{T}, n::Integer, lo::T, hi::T)::Dataset{T} where T
    Random.seed!(SEED)
    Dataset{T}(
        "A",
        Point.(zip(runif(T, n, lo, hi), runif(T, n, lo, hi))),
    )
end

function gendatasetb(::Type{T}, n::Integer, O::Point{T}, r::T)::Dataset{T} where T
    Random.seed!(SEED)
    Dataset{T}(
        "B",
        map(runif(T, n, T(0), T(2pi))) do phi
            x::T = O.x + r * cos(phi)
            y::T = O.y + r * sin(phi)
            Point{T}(x, y)
        end,
    )
end

function gendatasetc(::Type{T}, n::Integer, A::Point{T}, B::Point{T})::Dataset{T} where T
    Random.seed!(SEED)
    circ = 2abs(A.x - B.x) + 2abs(A.y - B.y)
    sidehorizprob = abs(A.x - B.x) / circ
    sidevertprob = abs(A.y - B.y) / circ
    Dataset{T}(
        "C",
        map(runif(T, n, T(0), T(1))) do scale
            side = rand(T)
            if side < sidehorizprob
                side = 1
            elseif side < 2sidehorizprob
                side = 2
            elseif side < 2sidehorizprob + sidevertprob
                side = 3
            else
                side = 4
            end
            Point(
                if side == 1
                    #  A*---*
                    #
                    #   *   *B
                    A.x + scale * (B.x - A.x),
                    A.y
                elseif side == 2
                    #  A*   *
                    #
                    #   *---*B
                    A.x + scale * (B.x - A.x),
                    B.y
                elseif side == 3
                    #  A*   *
                    #   |
                    #   *   *B
                    A.x,
                    A.y + scale * (B.y - A.y)
                elseif side == 4
                    #  A*   *
                    #       |
                    #   *   *B
                    B.x,
                    A.y + scale * (B.y - A.y)
                end
            )
        end,
    )
end

function gendatasetd(::Type{T}, n1::Integer, n2::Integer, A::Point{T}, B::Point{T})::Dataset{T} where T
    Random.seed!(SEED)
    Dataset{T}(
        "D",
        [
            Point(A.x, A.y);
            Point(A.x, B.y);
            Point(B.x, A.y);
            Point(B.x, B.y);
            map(runif(T, n1, T(0), T(1))) do scale
                A.x + scale * (B.x - A.x),
                A.y
            end;
            map(runif(T, n1, T(0), T(1))) do scale
                A.x,
                A.y + scale * (B.y - A.y)
            end;
            map(runif(T, n2, T(0), T(1))) do scale
                A.x + scale * (B.x - A.x),
                A.y + scale * (B.y - A.y)
            end;
            map(runif(T, n2, T(0), T(1))) do scale
                B.x + scale * (A.x - B.x),
                A.y + scale * (B.y - A.y)
            end
        ],
    )
end

end # module
