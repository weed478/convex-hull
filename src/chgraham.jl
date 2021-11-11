module Graham

export mkgraham,
       GrahamStep

using ..Geometry
using ..CH

struct GrahamStep{T}
    remaining::Vector{Point{T}}
    ch::Vector{Point{T}}
    current::Point{T}
    ok::Bool
end

GrahamStep(; remaining, ch, current, ok) = GrahamStep(
    remaining,
    ch,
    current,
    ok
)

function mkgraham(orientfn, detfn, e)
    orient(A, B, C) = orientfn(detfn, e, A, B, C)

    function ltorient(pnts, ia)
        function (ib, ic)
            if ic == ia
                return false
            elseif ib == ia
                return true
            end
            orient(pnts[[ia, ib, ic]]...) > 0
        end
    end

    function sortbyangle(pnts, i0)
        lt = ltorient(pnts, i0)

        function merge(t1, t2)
            t = empty(t1)
            
            i1 = 1
            n1 = length(t1)
            
            i2 = 1
            n2 = length(t2)

            while i1 <= n1 || i2 <= n2

                # if one array empty

                if i2 > n2
                    push!(t, t1[i1])
                    i1 += 1
                    continue
                end

                if i1 > n1
                    push!(t, t2[i2])
                    i2 += 1
                    continue
                end

                # if one element < other

                if lt(t1[i1], t2[i2])
                    push!(t, t1[i1])
                    i1 += 1
                    continue
                end

                if lt(t2[i2], t1[i1])
                    push!(t, t2[i2])
                    i2 +=1
                    continue
                end

                # equal orient

                normAB = abs(pnts[i0] - pnts[t1[i1]])
                normAC = abs(pnts[i0] - pnts[t2[i2]])

                if normAB > normAC
                    push!(t, t1[i1])
                else
                    push!(t, t2[i2])
                end
                i1 += 1
                i2 += 1
            end

            t
        end

        function sort(t)
            n = length(t)
            if n < 2
                return t
            end

            imid = (1 + length(t)) ÷ 2
            left = t[1:imid]
            right = t[imid+1:end]
            merge(sort(left), sort(right))
        end

        sort(1:length(pnts))
    end

    function chgraham(pnts::Vector{Point{T}}; steps=missing)::Vector{Point{T}} where T
        function pushstep!(step)
            if !ismissing(steps)
                push!(steps, step)
            end
            nothing
        end

        i0 = getbottomleftpoint(pnts)
        inds = sortbyangle(pnts, i0)
        @assert i0 == inds[1]
        
        ch = inds[1:3]
        i = 4
        while i <= length(inds)
            if orient(pnts[[ch[end-1:end]; inds[i]]]...) > 0
                pushstep!(GrahamStep(
                    remaining=pnts[inds[i+1:end]],
                    ch=pnts[ch],
                    current=pnts[inds[i]],
                    ok=true,
                ))
                push!(ch, inds[i])
                i += 1
            else
                pushstep!(GrahamStep(
                    remaining=pnts[inds[i+1:end]],
                    ch=pnts[ch],
                    current=pnts[inds[i]],
                    ok=false,
                ))
                pop!(ch)
            end
        end

        pushstep!(GrahamStep(
            remaining=Vector{Point{T}}(),
            ch=pnts[[ch; ch[1]]],
            current=pnts[ch[1]],
            ok=true,
        ))

        pnts[ch]
    end
end # makegraham

end # module
