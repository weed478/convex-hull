module Jarvis

export mkjarvis

using ..Geometry
using ..CH

struct JarvisStep

end

function mkjarvis(orientfn, detfn, e)
    orient(A, B, C) = orientfn(detfn, e, A, B, C)

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
                normAB = abs(A - B)
                normAC = abs(A - C)
                if normAC > normAB
                    i1 = i
                end
            end
        end

        i1
    end

    function chjarvis(pnts::Vector{Point{T}}; steps=missing)::Vector{Point{T}} where T
        i0 = getbottomleftpoint(pnts)
        i = getnextpoint(pnts, i0)

        ch::Vector{Point{T}} = [pnts[i0]]

        while i != i0
            push!(ch, pnts[i])
            i = getnextpoint(pnts, i)
        end

        ch
    end
end # makejarvis

end # module
