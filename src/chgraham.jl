module Graham

export chgraham

using ..Geometry
using ..CH

using LinearAlgebra: det

const e = 1e-4
orient(a, b, c) = orient3x3(det, e, a, b, c)

function ltorient(pnts, ia) where T
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
    sort(1:length(pnts), lt=ltorient(pnts, i0))
end

function chgraham(pnts::AbstractVector{Point{T}})::AbstractVector{Point{T}} where T
    i0 = getbottomleftpoint(pnts)
    inds = sortbyangle(pnts, i0)
    pnts[inds]
end

end # module
