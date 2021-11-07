function orient3x3(detfn, e::T, a::Point{T}, b::Point{T}, c::Point{T})::Int where T
    M::Matrix{T} = [a.x a.y 1
                    b.x b.y 1
                    c.x c.y 1]

    d::T = detfn(M)

    if abs(d) < e
        0
    elseif d < 0
        -1
    else
        1
    end
end

function orient2x2(detfn, e::T, a::Point{T}, b::Point{T}, c::Point{T})::Int where T
    M::Matrix{T} = [(a.x - c.x) (a.y - c.y)
                    (b.x - c.x) (b.y - c.y)]

    d::T = detfn(M)

    if abs(d) < e
        0
    elseif d < 0
        -1
    else
        1
    end
end
