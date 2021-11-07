module Jarvis

export chjarvis

using ..Geometry
using ..CH

using LinearAlgebra: det

const e = 1e-4
orient(a, b, c) = orient3x3(det, e, Segment(a, b), c)

function getnextpoint(pnts, i0)
    A = pnts[i0]
    i1 = i0 == 1 ? 2 : 1

    for i in filter(i -> i != i0, 1:length(pnts))
        B = pnts[i1]
        C = pnts[i]

        o = orient(A, B, C) 

        if o < 0
            i1 = i
        elseif o == 0
            normAB = sqrt((A.x - B.x)^2 + (A.y - B.y)^2)
            normAC = sqrt((A.x - C.x)^2 + (A.y - C.y)^2)
            if normAC > normAB
                i1 = i
            end
        end
    end

    i1
end

function chjarvis(pnts::AbstractVector{Point{T}})::AbstractVector{Point{T}} where T
    i0 = getbottomleftpoint(pnts)
    i = getnextpoint(pnts, i0)

    ch::Vector{Point{T}} = [
        pnts[i0],
        pnts[i],
    ]

    while i != i0
        i = getnextpoint(pnts, i)
        push!(ch, pnts[i])
    end

    ch
end

end # module
