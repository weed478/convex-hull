module Jarvis

export chjarvis

using ..Geometry

using LinearAlgebra: det

const e = 1e-4
orient(a, b, c) = orient3x3(det, e, Segment(a, b), c)

function getfirstpoint(pnts)
    i0 = 1
    for i in 2:length(pnts)
        if pnts[i].y < pnts[i0].y ||
           (pnts[i].y == pnts[i0].y && pnts[i].x < pnts[i0].x)
            i0 = i
        end
    end
    i0
end

function getnextpoint(pnts, i0)
    i1 = i0 == 1 ? 2 : 1

    for i in filter(i -> i != i0, 1:length(pnts))
        if orient(pnts[i0], pnts[i1], pnts[i]) < 0
            i1 = i
        end
    end

    i1
end

function chjarvis(pnts::AbstractVector{Point{T}})::AbstractVector{Point{T}} where T
    i0 = getfirstpoint(pnts)
    i1 = getnextpoint(pnts, i0)

    ch::Vector{Point{T}} = [
        pnts[i0],
        pnts[i1],
    ]

    while i1 != i0
        i1 = getnextpoint(pnts, i1)
        push!(ch, pnts[i1])
    end

    ch
end

end # module
