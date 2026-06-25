module Kwaterniony
using StaticArrays
export Quaternion,convert,promote_rule,j,k,show,+,-,*,zero,one,conj,abs2,abs,/,Matrix,number_from_matrix,obrót

#konstruktor typu
"""
    Quaternion{T<:Real}

Quaternion to typ liczbowy, reprezentujący kwaternion – liczbę z częścią rzeczywistą oraz trzema częściami urojonymi typu T.

Niniejsza implementacja zakłada równoważność jednostki urojonej "im_i" oraz jednostki urojonej liczb zespolonych (im).
```julia
Quaternion(re, im_i, im_j, im_k)   # Funkcja konstruuje kwaternion
Quaternion(re)                     # Funkcja konstruuje kwaternion z zerowymi częściami urojonymi
Quaternion(comp)                   # Funkcja konstruuje kwaternion z zerowymi częściami urojonymi "im_j" oraz "im_k"
```
# Przykłady
```jldoctest
julia> Quaternion(1.0, 3.0, 2.0, 5.1)
1.0 + 3.0im + 2.0j + 5.1k

julia> Quaternion(1//2)
1//2 + 0//1im + 0//1j + 0//1k

julia> Quaternion(2+im)
2 + 1im + 0j + 0k
```

"""
struct Quaternion{T<:Real} <: Number
    re::T
    im_i::T
    im_j::T
    im_k::T
end

function Quaternion(re::Real, im_i::Real, im_j::Real, im_k::Real)
    T = promote_type(typeof(re), typeof(im_i), typeof(im_j), typeof(im_k))
    return Quaternion{T}(re, im_i, im_j, im_k)
end

function Quaternion(re::Real)
    return Quaternion{typeof(re)}(re, 0, 0, 0)
end

function Quaternion(comp::Complex)
    return Quaternion{typeof(real(comp))}(real(comp), imag(comp), 0, 0)
end

#rzutowanie liczb rzeczywistych i zespolonych na kwaterniony
function Base.convert(::Type{Quaternion{T}}, x::Quaternion{S}) where {T<:Real,S<:Real}
    return Quaternion{T}(T(x.re), T(x.im_i), T(x.im_j), T(x.im_k))
end

Base.convert(::Type{Quaternion{T}}, x::Real) where {T<:Real} =
    Quaternion{T}(T(x), zero(T), zero(T), zero(T))

Base.convert(::Type{Quaternion{T}}, z::Complex) where {T<:Real} =
    Quaternion{T}(T(real(z)), T(imag(z)), zero(T), zero(T))

Base.promote_rule(::Type{Quaternion{T}},::Type{Quaternion{S}}) where {S<:Real, T<:Real}=Quaternion{promote_type(S,T)}

Base.promote_rule(::Type{Quaternion{T}},::Type{S}) where {S<:Real, T<:Real}=Quaternion{promote_type(S,T)}

Base.promote_rule(::Type{Quaternion{T}},::Type{Complex{S}}) where {S<:Real, T<:Real}=Quaternion{promote_type(S,T)}

#jednostki urojone
"""
    j
Jest to jedna z jednostek urojonych kwaternionów. 
# Przykłady
```jldoctest
julia> j*j
-1 + 0im + 0j + 0k
julia> j*im
0 + 0im + 0j - 1k
```
"""
const j = Quaternion(false, false, true, false)

"""
    k
Jest to jedna z jednostek urojonych kwaternionów. 
# Przykłady
```jldoctest
julia> k*k
-1 + 0im + 0j + 0k
julia> k*i
0 + 0im + 1j + 0k
```
"""
const k = Quaternion(false, false, false, true)

#pokazywanie
function Base.show(io::IO, q::Quaternion)
    print(io, q.re)

    for (coef, symbol) in ((q.im_i, "im"), (q.im_j, "j"), (q.im_k, "k"))
        if coef < 0
            print(io, " - ", abs(coef), symbol)
        else
            print(io, " + ", coef, symbol)
        end
    end
end

#dodawanie
Base.:+(q1::Quaternion, q2::Quaternion) =
    Quaternion(
        q1.re + q2.re,
        q1.im_i + q2.im_i,
        q1.im_j + q2.im_j,
        q1.im_k + q2.im_k
    )

#odejmowanie
Base.:-(q1::Quaternion, q2::Quaternion) =
    Quaternion(
        q1.re - q2.re,
        q1.im_i - q2.im_i,
        q1.im_j - q2.im_j,
        q1.im_k - q2.im_k
    )

#liczba przeciwna
Base.:-(q::Quaternion) =
    Quaternion(-q.re, -q.im_i, -q.im_j, -q.im_k)

#mnożenie
Base.:*(q1::Quaternion, q2::Quaternion) =
    Quaternion(
        q1.re*q2.re - q1.im_i*q2.im_i - q1.im_j*q2.im_j - q1.im_k*q2.im_k,
        q1.re*q2.im_i + q1.im_i*q2.re + q1.im_j*q2.im_k - q1.im_k*q2.im_j,
        q1.re*q2.im_j - q1.im_i*q2.im_k + q1.im_j*q2.re + q1.im_k*q2.im_i,
        q1.re*q2.im_k + q1.im_i*q2.im_j - q1.im_j*q2.im_i + q1.im_k*q2.re
    )

#element zerowy, jedynka
Base.zero(q::Quaternion{T}) where {T<:Real} =
    Quaternion{T}(zero(T), zero(T), zero(T), zero(T))

Base.one(q::Quaternion{T}) where {T<:Real} =
    Quaternion{T}(one(T), zero(T), zero(T), zero(T))

#sprzężenie
Base.conj(q::Quaternion) =
    Quaternion(q.re, -q.im_i, -q.im_j, -q.im_k)

#moduł
Base.abs2(q::Quaternion) = q.re^2 + q.im_i^2 + q.im_j^2 + q.im_k^2

Base.abs(q::Quaternion) = sqrt(abs2(q))


#liczba odwrotna
function Base.inv(q::Quaternion)
    if iszero(abs2(q))
        throw(DivideError())
    end
    return conj(q)*(1/abs2(q))
end

#dzielenie
function Base.:/(q1::Quaternion, q2::Quaternion) 
    if abs(q2) == 0 
        throw(DivideError())
    end
    return q1 * inv(q2)
end

#potęgowanie
function Base.:^(q::Quaternion,n::Integer)
    if n==0
        return one(q)
    elseif n>0
        q_pocz=q
        for i∈1:(n-1)
            q*=q_pocz
        end
        return q
    else
        return inv(q)^(-n)
    end
end   
 
#postać macierzy zespolonej
function Base.Matrix(q::Quaternion)
    return @SMatrix [
        q.re + q.im_i*im      q.im_j + q.im_k*im;
       -q.im_j + q.im_k*im    q.re - q.im_i*im
    ]
end

#postać macierzowa liczb zespoloynch
function Base.Matrix(comp::Complex)
    return @SMatrix [
    real(comp)      -imag(comp);
       imag(comp)    real(comp)
    ]
end

# zamiana z postaci macierzowej na liczbę
"""
    number_from_matrix(M::AbstractMatrix)
Funkcja zwraca reprezentację liczbową macierzy 2x2.
# Przykłady
```jldoctest
julia> number_from_matrix([1 -3; 3 1])
1 + 3im

julia> number_from_matrix([1+2im  3+4im; -3+4im  1-2im])
1 + 2im + 3j + 4k
```
"""
function number_from_matrix(M::AbstractMatrix)
    if size(M)==(2,2) && M[1,1]==M[2,2] && M[2,1]==-M[1,2]
        return M[1,1]+(imag(M[1,1]))im
    elseif size(M)==(2,2) && M[1,1]==conj(M[2,2]) && M[2,1]==-conj(M[1,2])
        return real(M[1,1])+imag(M[1,1])im+(real(M[1,2]))j+(imag(M[1,2]))k
    else
        throw(ArgumentError("Brak reprezentacji liczbowej"))
    end
end

#obroty
"""
    obrót(punkt::Vector, kąt::Number, oś::Vector)
Funkcja jako argumenty przyjmuje 3-elementowy wektor współrzędnych punktu, kąt w radianach oraz
3-elementowy wektor kierunku osi (oś przechodzi przez środek układu współrzędnych).

Funkcja zwraca 3-elementowy wektor – obraz punktu po obrocie o zadany kąt względem podanej osi.
# Przykład
```jldoctest
julia> obrót([0,1,0],π,[1,0,0])
3-element Vector{Float64}:
  0.0
 -1.0
  1.2246467991473532e-16
```
"""
function obrót(punkt::Vector, kąt::Number, oś::Vector)
    p=Quaternion(0,punkt[1],punkt[2],punkt[3])
    
    długość_osi=sqrt(sum(oś.^2))
    if iszero(długość_osi)
        throw(ArgumentError("Oś obrotu nie może być wektorem zerowym."))
    end
    
    oś=oś/długość_osi
    q=cos(kąt/2)+sin(kąt/2)*Quaternion(0,oś[1],oś[2],oś[3])
    obraz=q*p*conj(q)
    return [obraz.im_i,obraz.im_j,obraz.im_k]
end
end
