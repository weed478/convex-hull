module Jarvis

export mkjarvis,
       JarvisStep

using ..Geometry
using ..CH

struct JarvisStep{T}
    ch::Vector{Point{T}}
    current::Point{T}
    best::Point{T}
    isnewbest::Bool
end

function mkjarvis(orientfn, detfn, e)
    orient(A, B, C) = orientfn(detfn, e, A, B, C)

    function chjarvis(pnts::Vector{Point{T}}; steps=missing)::Vector{Point{T}} where T
        function pushstep!(step)
            if !ismissing(steps)
                push!(steps, step)
            end
            nothing
        end

        ch::Vector{Point{T}} = Vector{Point{T}}()

        function getnextpoint(i0)
            A = pnts[i0]
            i1 = i0 == 1 ? 2 : 1
    
            for i in filter(i -> i != i0, 1:length(pnts))
                B = pnts[i1]
                C = pnts[i]

                o = orient(A, B, C) 
    
                isnewbest = false

                if o < 0
                    isnewbest = true
                    i1 = i
                elseif o == 0
                    normAB = abs(A - B)
                    normAC = abs(A - C)
                    if normAC > normAB
                        isnewbest = true
                        i1 = i
                    end
                end

                pushstep!(JarvisStep(
                    copy(ch),
                    C,
                    pnts[i1],
                    isnewbest,
                ))
            end
    
            i1
        end

        i0 = getbottomleftpoint(pnts)
        push!(ch, pnts[i0])
        i = getnextpoint(i0)

        while i != i0
            push!(ch, pnts[i])
            i = getnextpoint(i)
        end

        pushstep!(JarvisStep(
            copy(ch),
            pnts[i],
            pnts[i],
            false,
        ))

        ch
    end
end # makejarvis

end # module
