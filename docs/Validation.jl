# Validation

This guide briefly explains how Mimi PAGE results were validated against PAGE 2009 outputs.

Validations were performed for both the deterministic and probabilistic versions of the model, and for both individual components and the final model outputs.

Relevant tests and data are saved in the 'test' folder.

## Obtaining PAGE 2009 values

We obtained PAGE 2009 values from the Excel version of PAGE 2009, provided by Chris Hope (personal communication).

Running the Excel version of PAGE 2009 requires downloading the @RISK 7.5 Industial software (available at http://go.palisade.com/RISKDownload.html), which facilitates probabilistic modeling in Excel. Free 15-day trials of the software are avaiable.

In order to perform tests of individual components, known values were extracted from PAGE 09 or the PAGE written documentation. Where they were obtained from PAGE 2009, values were exported with full precision using a custom function. (Key values are saved in the 'validationdata' folder within the 'test' folder.) Truncating precision can lead to compounding errors which will cause Mimi PAGE results to diverge from PAGE 2009.


## Deterministic validations

For each individual Mimi PAGE component, we tested the component with known input data and compared output with values from PAGE 2009. These test files all begin with the 'test_' prefix. Nearly all values matched within 1%.

## Probabilistic validation

For the probabilistic version of the model, we graphed and compared distributions of total damages, total preventative costs, total adaptation costs, and total effects. Distributions matched closely. Means from the 5, 10, 25, 50, 75, 90, and 95% quantiles all matched within 1.5%.
