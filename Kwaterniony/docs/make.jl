using Kwaterniony
using Documenter

DocMeta.setdocmeta!(Kwaterniony, :DocTestSetup, :(using Kwaterniony); recursive=true)

makedocs(;
    modules=[Kwaterniony],
    authors="Łukasz Kołaczek, Michał Nawłoka, Daria Szefer",
    sitename="Kwaterniony.jl",
    format=Documenter.HTML(;
        canonical="https://9Daria.github.io/Kwaterniony.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/9Daria/Kwaterniony.jl",
    devbranch="main",
)
