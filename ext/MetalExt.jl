module MetalExt

using ContinuousWavelets, Metal

function ContinuousWavelets.cwt(Y::MtlArray{<:Union{Float64,ComplexF64}}, args...; kwargs...)
    error("Metal does not support Float64 — pass Float32 (or ComplexF32) data instead.")
end

end