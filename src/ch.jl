module CH

export getbottomleftpoint,
       savech

function getbottomleftpoint(pnts)
    i0 = 1
    for i in 2:length(pnts)
        if pnts[i].y < pnts[i0].y ||
           (pnts[i].y == pnts[i0].y && pnts[i].x < pnts[i0].x)
            i0 = i
        end
    end
    i0
end

function savech(output, ch)
    open(output, "w") do f
        println(f, length(ch))
        for p in ch
            println(f, "$(p.x) $(p.y)")
        end
    end
end

end # module
