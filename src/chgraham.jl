module Graham

export mkgraham,
       GrahamStep

using ..Geometry
using ..CH

# przechowuje etapy wykonywania do późniejszej animacji
struct GrahamStep{T}
    remaining::Vector{Point{T}}
    ch::Vector{Point{T}}
    current::Point{T}
    ok::Bool
end

# konstruktor aby można było używać keyword arguments
GrahamStep(; remaining, ch, current, ok) = GrahamStep(
    remaining,
    ch,
    current,
    ok
)

# funckja "buduje" algorytm o zadanych parametrach (orient, wyznacznik, epsilon)
# zwraca funkcję będącą samym algorytmem
function mkgraham(orientfn, detfn, e)

    # funkcja orient z ustaloną funkcją wyznacznika oraz epsilonem
    orient(A, B, C) = orientfn(detfn, e, A, B, C)

    # funkcja zwraca komparator (funkcję) dla zadanego punktu ia i tablicy punktów pnts
    function ltorient(pnts, ia)
        # komparator (is less than) dla dwóch punktów ib, ic
        function (ib, ic)
            if ic == ia
                return false
            elseif ib == ia
                return true
            end
            # ia, ib, ic to indeksy więc wydostajemy same punkty z tablicy pnts
            orient(pnts[[ia, ib, ic]]...) > 0
        end
    end

    # funckja zwraca posortowaną tablicę indeksów
    function sortbyangle(pnts, i0)
        # zbudowanie skonfigurowanej funkcji komparatora
        lt = ltorient(pnts, i0)

        # funckja pracuje na tablicach indeksów
        function merge(t1, t2)
            # pusta tablica wyjściowa
            t = empty(t1)
            
            i1 = 1
            n1 = length(t1)
            
            i2 = 1
            n2 = length(t2)

            # zwykłe mergesort
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
                # przypadek kiedy punkty są wspóliniowe

                # odległości
                normAB = abs(pnts[i0] - pnts[t1[i1]])
                normAC = abs(pnts[i0] - pnts[t2[i2]])

                # bliższy punkt jest gubiony
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

        # do sort trafiają indeksy (liczby od 1 do length(pnts))
        sort(1:length(pnts))
    end

    # sam algorytm (bierze tablicę punktów)
    function chgraham(pnts::Vector{Point{T}}; steps=missing)::Vector{Point{T}} where T
        # helper do dodawania animacji
        function pushstep!(step)
            if !ismissing(steps)
                push!(steps, step)
            end
            nothing
        end

        i0 = getbottomleftpoint(pnts)
        inds = sortbyangle(pnts, i0)
        # inds zawiera indeksy punktów w kolejności według funkcji sortbyangle
        @assert i0 == inds[1]
        
        # algorytm grahama
        ch = inds[1:3]
        i = 4
        while i <= length(inds)
            # ostatnie 3 punkty w ch, zamiana indeksów na punkty
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

        # ch to indeksy, więc zwracamy same punkty
        pnts[ch]
    end
end # makegraham

end # module
