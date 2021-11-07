module CH

export getbottomleftpoint

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

end # module
