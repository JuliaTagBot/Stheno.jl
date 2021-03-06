using Documenter, Stheno

DocMeta.setdocmeta!(
    Stheno,
    :DocTestSetup,
    :(using AbstractGPs, Stheno, Random, LinearAlgebra);
    recursive=true,
)

makedocs(
	modules = [Stheno],
    format = Documenter.HTML(),
    sitename = "Stheno.jl",
    pages = [
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
        "Input Types" => "input_types.md",
        "Kernel Design" => "kernel_design.md",
        "Internals" => "internals.md",
        "API" => "api.md",
    ],
)

deploydocs(repo="github.com/JuliaGaussianProcesses/Stheno.jl.git")
