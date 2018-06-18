# Differences from Excel

This guide lists changes made to the code based on differences from the Excel version that were not present in the documentation.

## Decimal place precision

The following parameter values were updated to match the precision of their corresponding values in Excel. In the published documentation, these values were rounded to two decimal places, but the Excel version uses the means of the triangular probability distributions at higher levels or precision. 
- "src/AbatementCosts.jl" lines 176, 190, 191, 204
- "src/AdaptationCosts.jl" lines 93, 94, 111, 129, 130
- "src/CO2cycle.jl" line 94
- "src/N2Oforcing.jl" lines 21, 24

## Explicit timestep calculation

The following lines were modified to explicity calculate the length of time between year 1 and year 0 (which is assumed to be one year in the PAGE09 model).
- "src/CH4ccycle.jl" line 36
- "src/CO2cycle.jl" line 41
- "src/LGcycle.jl" line 36
- "src/N2Occyle.jl" line 37

