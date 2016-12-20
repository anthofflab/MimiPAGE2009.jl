# How to format properly in this model

## Naming
Components (i.e. after `@defcomp`) should use capitalized camel casing, e.g. `SeaLevelRise`.
Everything else should use all lowercase.
Variables: `pagevariable_longerformwithoutspaces`
we should use common abbreviations (init, econ, etc.).

## Spaces
4 space indentation and no tabs.

## Units
`unitless` for proportions, and never use the word `per` in a unit.

## Proposals
One question about dollar units is whether we should include the price level, 
e.g. we could use USD95 to indicate that prices are in 1995 levels... 
Not sure about that one, though.

I think I like g_init best for initial values, but could easily be convinced otherwise. 
We could for example use Unicode for this and name them x₀. 
You enter that in Atom by writing ``x\_0`` and then press tab. That would be nice and short and pretty clear.

I like the idea of using Unicode for _0, iff we can get a clever unicode for _per_cap too.  
(Maybe 🚶,  Þ, ÷, or ᵨ?).  Otherwise, I propose uniformly removing any underscores from the page variable name, 
so g_0 becomes g0 and gdp_per_cap becomes gdppercap.
