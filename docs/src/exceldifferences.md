# Differences from Excel

This guide lists changes made to the code based on differences from the Excel version that were not present in the documentation.

## Value precision differences

The following parameter values were updated to match the precision of their corresponding values in Excel:
- "src/AbatementCosts.jl" lines 176, 190, 191, 204
- "src/AdaptationCosts.jl" lines 93, 94, 111, 129, 130
- "src/CO2cycle.jl" line 94

## Structural formula differences

The following lines contain slight changes in formulas to match the corresponding calculation in Excel:
- "src/CH4ccycle.jl" line 36
- "src/CO2cycle.jl" line 41
- "src/LGcycle.jl" line 36
- "src/N2Occyle.jl" line 37
- "src/N2Oforcing.jl" lines 21, 24
