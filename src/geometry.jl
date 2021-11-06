module Geometry

export Point,
       Segment,
       tofunction,
       orient3x3,
       orient2x2

struct Point{T}
    x::T
    y::T
end

Point(x::T, y::T) where T = Point{T}(x, y)

# helpers to convert to/from tuple
Point(p::Tuple{T, T}) where T = Point{T}(p[1], p[2])
Tuple(p::Point) = (p.x, p.y)
Base.convert(::Type{Tuple{T, T}}, p::Point{T}) where T = Tuple(p)
Base.convert(::Type{Point{T}}, p::Tuple{T, T}) where T = Point(p)

# type conversion
Point(::Type{T}, p::Point{T}) where T = p
Point(::Type{T}, p::Point) where T = Point{T}(T(p.x), T(p.y))

# line between 2 points
struct Segment{T}
    A::Point{T}
    B::Point{T}
end

Segment(A::Point{T}, B::Point{T}) where T = Segment{T}(A, B)
Segment(::Type{T}, s::Segment{T}) where T = s
Segment(::Type{T}, s::Segment) where T = Segment{T}(Point(T, s.A), Point(T, s.B))

# convert segment to function f(x) = ax + b
# y = ax + b
# a = dy/dx
# b = y - ax
function tofunction(seg::Segment{T}) where T
    a::T = (seg.B.y - seg.A.y) / (seg.B.x - seg.A.x)
    b::T = seg.A.y - a * seg.A.x
    x::T -> a*x + b
end

# orientation functions

function orient3x3(detfn, e::T, l::Segment{T}, A::Point{T})::Int where T
    a::Point{T} = l.A
    b::Point{T} = l.B
    c::Point{T} = A

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

function orient2x2(detfn, e::T, l::Segment{T}, A::Point{T})::Int where T
    a::Point{T} = l.A
    b::Point{T} = l.B
    c::Point{T} = A

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

end # module
