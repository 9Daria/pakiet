module Kwaterniony
using StaticArrays

export Quaternion,convert,j,k,show,+,-,*,zero,one,conj,abs2,abs,/,Matrix,number_from_matrix,obrót
#konstruktor typu
struct Quaternion{T<:Real} <: Number
    re::T
    im_i::T
    im_j::T
    im_k::T
end

function Quaternion(re::Real, im_i::Real, im_j::Real, im_k::Real)
    T = promote_type(typeof(re), typeof(im_i), typeof(im_j), typeof(im_k))
    return Quaternion{T}(T(re), T(im_i), T(im_j), T(im_k))
end

#rzutowanie liczb rzeczywistych i zespolonych na kwaterniony
Base.convert(::Type{Quaternion{T}}, x::Real) where {T<:Real} =
    Quaternion{T}(T(x), zero(T), zero(T), zero(T))

Base.convert(::Type{Quaternion{T}}, z::Complex) where {T<:Real} =
    Quaternion{T}(T(real(z)), T(imag(z)), zero(T), zero(T))

#jednostki urojone
const j = Quaternion(0, 0, 1, 0)
const k = Quaternion(0, 0, 0, 1)

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
    return conj(q) * (one(abs2(q)) / abs2(q))
end

#dzielenie
function Base.:/(q1::Quaternion, q2::Quaternion) 
    if abs(q2) == 0 
        throw(DivideError())
    end
    return q1 * inv(q2)
end

#postać macierzy zespolonej
function Base.Matrix(q::Quaternion)
    return @SMatrix [
        q.re + q.im_i*im      q.im_j + q.im_k*im;
       -q.im_j + q.im_k*im    q.re - q.im_i*im
    ]
end

# zamiana z postaci macierzowej na liczbę
function number_from_matrix(M::Matrix{Complex})
    if size(M)==(2,2) && M[1,1]==conj(M[2,2]) && M[2,1]==-conj(M[1,2])
        return M[1,1]+(real(M[1,2]))j+(imag(M[1,2]))k
    else
        throw(ArgumentError("Brak reprezentacji liczbowej"))
    end
end

function number_from_matrix(M::Matrix{Real})
    if size(M)==(2,2) && M[1,1]==M[2,2] && M[2,1]==-M[1,2]
        return M[1,1]+(M[2,1])im
    else
        throw(ArgumentError("Brak reprezentacji liczbowej."))
    end
end

#obroty
function obrót(punkt,kąt,oś)
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
