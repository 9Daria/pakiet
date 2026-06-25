# Kwaterniony

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://9Daria.github.io/Kwaterniony.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://9Daria.github.io/Kwaterniony.jl/dev/)
[![Build Status](https://github.com/9Daria/Kwaterniony.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/9Daria/Kwaterniony.jl/actions/workflows/CI.yml?query=branch%3Amain)

Pakiet **Kwaterniony.jl** dostarcza implementację algebry kwaternionów w języku Julia. Wspiera:
- **Rzutowanie typów:** automatyczne rzutowanie i reguły promocji (`convert`, `promote_rule`), które pozwalają na bezproblemowe łączenie kwaternionów z wbudowanymi w Julię liczbami rzeczywistymi (`Real`) i zespolonymi (`Complex`).
- **Arytmetykę kwaternionów:** podstawowe operacje (dodawanie `+`, odejmowanie `-`, mnożenie `*`, dzielenie `/`, potęgowanie `^`), wyznaczanie sprzężenia (`conj`), elementu odwrotnego (`inv`), modułu i jego kwadratu (`abs`, `abs2`) oraz elementów neutralnych (`zero`, `one`).
- **Reprezentację macierzową:** dwukierunkowe mapowanie kwaternionów na zespolone macierze 2x2 za pomocą funkcji `Matrix` oraz `number_from_matrix`. Kwaternion zapisany jako `q = a + b*im + c*j + d*k` można zrzutować do postaci:
  ```julia
  @SMatrix [ a + b*im    c + d*im;
   -c + d*im    a - b*im ]
  ```
- **Obroty 3D:** funkcja `obrót(punkt, kąt, oś)` do obliczania obrotów w przestrzeni trójwymiarowej wokół dowolnie zadanej osi przechodzącej przez środek układu współrzędnych.

## Instalacja

Aby zainstalować pakiet, wejdź w tryb menedżera pakietów (wciskając `]`) w REPL Julii i wpisz:

```julia
pkg> add https://github.com/9Daria/pakiet
```
