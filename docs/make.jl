using Documenter

makedocs(
    sitename="MimiPAGE2009.jl",
    pages=[
        "Home" => "index.md",
        "Getting started" => "gettingstarted.md",
        "Model Structure" => "model-structure.md",
        "Technical User Guide" => "technicaluserguide.md",
        "Model Validation" => "validation.md"]
)

deploydocs(
    repo="github.com/anthofflab/MimiPAGE2009.jl.git"
)
