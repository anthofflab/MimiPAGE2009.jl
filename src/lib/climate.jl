function naturalemissions(stim::Float64, rt_realizedtemperature::Array{Float64}, rt_0_realizedtemperature::Vector{Float64}, tt::Int, area::Vector{Float64})
    if tt == 1
        naturalemissions(stim, rt_0_realizedtemperature, area)
    else
        naturalemissions(stim, vec(rt_realizedtemperature[tt-1, :]), area)
    end
end


function naturalemissions(stim::Float64, rt_tm1_realizedtemperature::Vector{Float64}, area::Vector{Float64})
    stim * sum(rt_tm1_realizedtemperature .* area) / sum(area)
end
