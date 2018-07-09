using Mimi
using Base.Test

m = page_model()
include("../src/components/LGforcing.jl")

addcomponent(m, LGforcing)

set_parameter!(m, :LGforcing, :c_LGconcentration, readpagedata(m,"test/validationdata/c_LGconcentration.csv"))

# run Model
run(m)

forcing=m[:LGforcing,:f_LGforcing]
forcing_compare=readpagedata(m,"test/validationdata/f_LGforcing.csv")

@test forcing ≈ forcing_compare rtol=1e-3
