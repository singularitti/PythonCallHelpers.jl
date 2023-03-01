using PythonCallHelpers
using Documenter

DocMeta.setdocmeta!(PythonCallHelpers, :DocTestSetup, :(using PythonCallHelpers); recursive=true)

makedocs(;
    modules=[PythonCallHelpers],
    authors="singularitti <singularitti@outlook.com> and contributors",
    repo="https://github.com/singularitti/PythonCallHelpers.jl/blob/{commit}{path}#{line}",
    sitename="PythonCallHelpers.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://singularitti.github.io/PythonCallHelpers.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/singularitti/PythonCallHelpers.jl",
    devbranch="main",
)
