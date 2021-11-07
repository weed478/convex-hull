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

for f in (:+, :-)
    @eval function Base.$f(A::Point{T}, B::Point{T})::Point{T} where T
        Point($f(A.x, B.x), $f(A.y, B.y))
    end
end

function Base.abs(A::Point{T})::T where T
    sqrt(abs2(A))
end

function Base.abs2(A::Point{T})::T where T
    A.x^2 + A.y^2
end
