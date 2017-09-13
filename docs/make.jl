using Documenter

makedocs(
	format = :html,
	sitename = "mimi-page.jl",
	pages = [
		"Home" => "index.md",
		"Getting started" => "gettingstarted.md",
        "Scientific User Guide" => "scientificuserguide.md",
		"Technical User Guide" => "technicaluserguide.md"]
)

deploydocs(
    deps = nothing,
    make = nothing,
	target = "build",
    repo = "github.com/anthofflab/mimi-page.jl.git",
    julia = "0.5"
)
