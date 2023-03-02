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
        "Manual" => [
            "Installation guide" => "installation.md",
        ],
        "Public API" => "public.md",
        "Developer Docs" => [
            "Contributing" => "developers/contributing.md",
            "Style Guide" => "developers/style-guide.md",
            "Design Principles" => "developers/design-principles.md",
        ],
        "Troubleshooting" => "troubleshooting.md",
    ],
)

deploydocs(;
    repo="github.com/singularitti/PythonCallHelpers.jl",
    devbranch="main",
)
