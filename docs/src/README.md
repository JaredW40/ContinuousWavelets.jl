```@meta ex
DocTestFilters = [
        r"\@ ContinuousWavelets .*",
        r"[ +-][0-9]\.[0-9]{3,5}e-1[5-9]",
        r"[ +-][0-9]\.[0-9]{3,5}e-[2-9][0-9]",
        r"im {2,7}",
    ]
```

# ContinuousWavelets

[![Build Status](https://travis-ci.com/dsweber2/ContinuousWavelets.jl.svg?branch=master)](https://travis-ci.com/dsweber2/ContinuousWavelets.jl)
[![Coverage](https://codecov.io/gh/dsweber2/ContinuousWavelets.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/dsweber2/ContinuousWavelets.jl)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://ucd4ids.github.io/ContinuousWavelets.jl/dev/)

This package is an offshoot of [Wavelets.jl](https://github.com/JuliaDSP/Wavelets.jl) for the continuous wavelets.
Thanks to [Felix Gerick](https://github.com/fgerick) for the initial implementation there, with extension and further adaptation by David Weber and any other contributors listed on the right.
Currently, it implements 1D continuous wavelet transforms with the following mother wavelets:

![Mothers](https://github.com/UCD4IDS/ContinuousWavelets.jl/blob/master/docs/mothers.svg)

Which covers several standard continuous wavelet families, both real and analytic, as well as continuous versions of the orthogonal wavelet transforms implemented in [Wavelets.jl](https://github.com/JuliaDSP/Wavelets.jl).

## Basic Usage

Install via the package manager and load with `using`

```julia
julia> Pkg.add("ContinuousWavelets")
julia> using ContinuousWavelets
```

Basic usage example on a doppler test function.

```jldoctest ex
julia> using Random

julia> Random.seed!(1234);

julia> using ContinuousWavelets, Wavelets

julia> n = 2047;

julia> t = range(0, n / 1000, length=n); # 1kHz sampling rate

julia> f = testfunction(n, "Doppler");

julia> c = wavelet(Morlet(π), β=2);

julia> res = cwt(f, c)
┌ Warning: the lowest frequency wavelet has more than 1% its max at zero, so it may not be analytic. Think carefully
│   lowAprxAnalyt = 0.061863
└ @ ContinuousWavelets ~/work/ContinuousWavelets.jl/ContinuousWavelets.jl/src/sanityChecks.jl:7
2047×31 Matrix{ComplexF64}:
 -1.48637e-6+1.68642e-19im  …   0.000109978+9.67834e-5im
 -1.48602e-6+6.01921e-19im      -8.24922e-5+0.000130656im
 -1.48534e-6+6.83859e-20im     -0.000153463-5.65145e-5im
  -1.4843e-6+4.88091e-19im       1.91001e-5-0.000168553im
 -1.48293e-6-5.53424e-19im      0.000172843-2.56684e-5im
 -1.48122e-6-4.44009e-19im  …    7.80162e-5+0.000162986im
 -1.47916e-6-1.24901e-19im     -0.000129028+0.000132868im
 -1.47677e-6+5.39201e-20im     -0.000172469-6.71606e-5im
 -1.47403e-6-1.75929e-19im      -9.40417e-6-0.00018015im
 -1.47097e-6-1.39167e-19im      0.000154118-8.14996e-5im
            ⋮               ⋱              ⋮
  0.00044037-8.67907e-19im      -2.60187e-6-7.00984e-7im
 0.000439183-9.54367e-19im      -2.58581e-6-6.24711e-7im
 0.000438144-1.03009e-19im  …   -2.56714e-6-5.41567e-7im
 0.000437254-6.31997e-19im      -2.56353e-6-4.48601e-7im
 0.000436512-2.8937e-19im        -2.5802e-6-3.83865e-7im
 0.000435918-1.00105e-19im      -2.54408e-6-3.55077e-7im
 0.000435472-3.34178e-19im      -2.44518e-6-2.37481e-7im
 0.000435175+4.87161e-19im  …   -2.47195e-6-1.97048e-8im
 0.000435027+4.91421e-19im      -2.63499e-6+4.62331e-8im
```

As the cwt frame is redundant, there are many choices of dual/inverse frames. There are three available in this package, `NaiveDelta()`, `PenroseDelta()`, and `DualFrames()`. As a toy example, lets knock out the middle time of the bumps function and apply a high pass filter:

```jldoctest ex
using ContinuousWavelets, Wavelets
f = testfunction(n, "Bumps");
c = wavelet(dog2, β = 2)
res = cwt(f, c)

# output

2047×27 Matrix{Float64}:
 0.000926575  -0.00150445  -2.16081e-6  …  -3.1189e-8    -2.84589e-8
 0.000926735  -0.00150491  -2.1645e-6      -2.27135e-8   -1.96595e-8
 0.000927054  -0.00150584  -2.17193e-6     -1.22181e-8   -9.55459e-9
 0.000927533  -0.00150722  -2.18314e-6     -5.16347e-9   -3.58522e-9
 0.000928172  -0.00150908  -2.19826e-6     -2.13096e-9   -1.45368e-9
 0.000928971  -0.00151139  -2.2174e-6   …  -1.2662e-9    -9.85671e-10
 0.00092993   -0.00151416  -2.24074e-6     -1.11223e-9   -9.31431e-10
 0.000931049  -0.00151738  -2.26848e-6     -1.11278e-9   -9.48375e-10
 0.000932328  -0.00152106  -2.30088e-6     -1.13528e-9   -9.66342e-10
 0.000933767  -0.00152519  -2.33821e-6     -1.16191e-9   -9.92329e-10
 ⋮                                      ⋱   ⋮
 0.000251031  -2.69124e-6  -1.47873e-7     -8.33078e-11  -7.26131e-11
 0.000250957  -2.65441e-6  -1.48266e-7     -8.21089e-11  -6.83705e-11
 0.000250892  -2.62233e-6  -1.48613e-7  …  -8.51117e-11  -7.15928e-11
 0.000250837  -2.59495e-6  -1.48912e-7     -1.08558e-10  -7.82779e-11
 0.000250791  -2.57221e-6  -1.49162e-7     -2.32143e-10  -1.48134e-10
 0.000250754  -2.55407e-6  -1.49364e-7     -6.57811e-10  -4.45939e-10
 0.000250726  -2.54049e-6  -1.49515e-7     -1.64592e-9   -1.28336e-9
 0.000250708  -2.53146e-6  -1.49616e-7  …  -3.11406e-9   -2.69593e-9
 0.000250698  -2.52694e-6  -1.49667e-7     -4.29947e-9   -3.92694e-9
```

```jldoctest ex
using ContinuousWavelets, Wavelets
f = testfunction(n, "Bumps");
c = wavelet(dog2, β = 2)
res = cwt(f, c)
# dropping the middle peaks
res[620:1100, :] .= 0
# and smoothing the remaining peaks
res[:, 10:end] .= 0
freqs = getMeanFreq(length(f), c)
dropped = icwt(res, c, DualFrames())
round.(dropped,sigdigits=12)

# output

┌ Warning: the canonical dual frame is off by 3.81e6, consider using one of the delta dual frames
└ @ ContinuousWavelets ~/work/ContinuousWavelets.jl/ContinuousWavelets.jl/src/sanityChecks.jl:41
2047-element Vector{Float64}:
 0.0069417253841
 0.00694223965946
 0.00694326785951
 0.00694480929919
 0.00694686299118
 0.00694942769229
 0.00695250196264
 0.00695608423521
 0.00696017289309
 0.00696476635167
 ⋮
 0.00268944585446
 0.00268924509819
 0.00268906748252
 0.00268891374512
 0.00268878454877
 0.00268868046822
 0.00268860197846
 0.00268854944484
 0.00268852311536
```

It can also handle collections of examples at the same time, should you need to do a batch of transforms:

```jldoctest ex
julia> using Wavelets

julia> exs = cat(testfunction(n, "Doppler"), testfunction(n, "Blocks"), testfunction(n, "Bumps"), testfunction(n, "HeaviSine"), dims=2);

julia> c = wavelet(cDb2, β=2, extraOctaves=-0);

julia> res = circshift(cwt(exs, c), (0, 1, 0))
┌ Warning: the highest frequency wavelet has more than 1% its max at the end, so it may not be analytic. Think carefully
│   highAprxAnalyt = 0.26753
└ @ ContinuousWavelets ~/work/ContinuousWavelets.jl/ContinuousWavelets.jl/src/sanityChecks.jl:12
2047×32×4 Array{Float64, 3}:
[:, :, 1] =
  1.88768e-5   0.000266059  0.000196385  …   4.67422e-5    3.00171e-6
  8.31921e-5   0.000266939  0.000201693      1.56546e-5   -4.46452e-5
 -0.000103305  0.00026787   0.000207132     -8.95316e-5   -0.000218163
 -0.000354544  0.000268863  0.000212756     -0.000251491  -0.000256012
 -0.000189201  0.000269918  0.000218473     -0.000206374   5.48096e-5
  0.000341279  0.000271022  0.000224034  …   0.000132559   0.000428572
  0.000574242  0.000272171  0.000229261      0.000418277   0.000352245
  0.000103427  0.000273381  0.00023422       0.000244317  -0.000205848
 -0.000603374  0.00027468   0.000239083     -0.000284468  -0.00064
 -0.000707401  0.000276076  0.000243843     -0.000581429  -0.000390287
  ⋮                                      ⋱   ⋮
 -4.86072e-6   0.00203577   0.00136983       1.3746e-6     1.01316e-6
 -3.96709e-6   0.00202891   0.00135318       1.47248e-6    1.1395e-6
 -3.06475e-6   0.00202201   0.00133645   …   1.66161e-6    1.36773e-6
 -2.10525e-6   0.00201509   0.00131963       1.96822e-6    1.72518e-6
 -1.06591e-6   0.00200815   0.00130273       2.40578e-6    2.22432e-6
  5.95063e-8   0.00200117   0.00128574       2.97467e-6    2.86062e-6
  1.25659e-6   0.00199418   0.00126868       3.66085e-6    3.49923e-6
  2.25286e-6   0.00198715   0.00125153   …   4.24046e-6    3.80696e-6
  2.64275e-6   0.0019801    0.00123431       4.37922e-6    3.47586e-6

[:, :, 2] =
  1.38846e-17  0.022676   0.00955726  …   6.94228e-18   4.66435e-18
  0.0          0.0226846  0.0095044       2.60336e-18  -2.60336e-18
 -4.33893e-18  0.0226935  0.00944927     -3.47114e-18  -5.20671e-18
 -4.33893e-18  0.0227027  0.00939275     -1.51862e-18   8.67785e-19
  6.94228e-18  0.0227121  0.00933466      8.67785e-19   6.50839e-18
  1.12812e-17  0.0227217  0.00927534  …   1.04134e-17   4.33893e-18
  3.47114e-18  0.0227314  0.00921535      4.55587e-18  -7.59312e-19
  8.67785e-19  0.0227412  0.00915422     -1.95252e-18  -6.50839e-18
 -3.90503e-18  0.0227512  0.00909148     -5.64061e-18  -2.8203e-18
  3.47114e-18  0.0227612  0.00902685      4.33893e-19   3.47114e-18
  ⋮                                   ⋱   ⋮
 -7.36312e-18  0.0336974  0.0110366      -6.12989e-18  -8.71296e-18
 -6.4979e-20   0.0337633  0.0109994      -2.91136e-18  -5.73389e-18
 -5.18576e-18  0.0338287  0.0109642   …  -1.52141e-18  -4.54335e-18
 -3.42079e-18  0.0338937  0.010931        7.34449e-19  -4.50817e-18
 -2.75305e-18  0.0339583  0.0108997       1.2251e-18   -4.20299e-18
 -9.44757e-19  0.034023   0.010868       -2.87642e-18  -6.13515e-18
 -3.00299e-18  0.0340877  0.0108362       1.08597e-18  -6.16788e-18
 -7.39019e-18  0.0341524  0.0108042   …  -1.37111e-18  -1.86659e-18
  2.50852e-18  0.0342169  0.0107732       3.52659e-18  -1.48794e-18

[:, :, 3] =
 -4.25348e-7  0.00596895  0.00256794  0.000892542  …  4.4713e-8   1.86785e-8
 -4.37683e-7  0.00596787  0.0025637   0.000882865     3.30062e-8  7.83973e-9
 -4.46078e-7  0.00596705  0.00255994  0.000874621     2.23969e-8  2.37537e-9
 -4.49625e-7  0.00596654  0.0025567   0.000868453     1.70526e-8  2.19316e-9
 -4.51716e-7  0.0059664   0.00255384  0.000865109     1.65292e-8  3.53328e-9
 -4.54754e-7  0.00596671  0.00255138  0.000865688  …  1.76083e-8  4.14038e-9
 -4.58407e-7  0.00596755  0.00254961  0.000872116     1.84205e-8  4.15257e-9
 -4.6207e-7   0.00596908  0.00254889  0.000881383     1.87308e-8  4.12961e-9
 -4.65795e-7  0.00597153  0.0025495   0.000890743     1.88706e-8  4.1764e-9
 -4.69574e-7  0.00597514  0.00255133  0.000899576     1.90652e-8  4.22979e-9
  ⋮                                                ⋱  ⋮
 -1.00718e-7  0.00335078  0.0016979   0.000148562     3.83469e-9  6.42228e-10
 -1.00208e-7  0.00335819  0.0016908   0.000151597     3.87326e-9  7.07905e-10
 -9.96289e-8  0.00336545  0.00168436  0.00015481   …  4.04737e-9  9.34488e-10
 -9.88817e-8  0.0033725   0.00167882  0.00015813      4.40794e-9  1.37883e-9
 -9.79085e-8  0.00337925  0.00167463  0.00016154      4.99228e-9  2.08528e-9
 -9.66617e-8  0.00338588  0.00167092  0.00016505      5.83069e-9  3.09533e-9
 -9.50919e-8  0.00339257  0.00166696  0.00016869      6.96053e-9  4.20677e-9
 -9.36725e-8  0.00339937  0.0016624   0.000172546  …  7.99443e-9  4.79906e-9
 -9.31697e-8  0.00340624  0.00165756  0.00017675      8.3032e-9   4.25503e-9

[:, :, 4] =
  0.000307892  -0.0150904   -0.0039183   …   0.000541893   0.000301771
  6.09684e-5   -0.0152542   -0.00405989      0.000307384   8.45675e-5
 -0.000106299  -0.0154178   -0.00420327      9.46605e-5   -2.52485e-5
 -0.000175694  -0.0155812   -0.00434838     -1.28952e-5   -2.94853e-5
 -0.00021499   -0.0157445   -0.00449505     -2.41298e-5   -3.30047e-6
 -0.000272209  -0.0159075   -0.00464325  …  -3.37452e-6    8.21273e-6
 -0.000340701  -0.0160703   -0.00479295      1.19945e-5    7.81043e-6
 -0.000408349  -0.0162329   -0.00494412      1.72726e-5    6.6819e-6
 -0.000476154  -0.0163952   -0.00509671      1.90843e-5    6.92397e-6
 -0.000543942  -0.0165573   -0.00525068      2.19284e-5    7.27319e-6
  ⋮                                      ⋱   ⋮
  0.000676899  -0.0081728   -0.00224729     -2.26908e-5    6.71449e-7
  0.00060886   -0.00808386  -0.00215564     -2.85968e-5   -8.89112e-6
  0.000530482  -0.00799512  -0.00206209  …  -5.38657e-5   -4.14646e-5
  0.0004274    -0.0079066   -0.00196668     -0.000105778  -0.000105177
  0.000291403  -0.00781828  -0.00186942     -0.000189663  -0.000206366
  0.000115709  -0.00773017  -0.0017703      -0.000309847  -0.000350952
 -0.000106736  -0.00764226  -0.00166933     -0.000471658  -0.000509993
 -0.000308175  -0.00755455  -0.00156652  …  -0.000619665  -0.000594702
 -0.000378998  -0.00746703  -0.00146187     -0.000663844  -0.000516786
```

And the plot of these:

There are also several boundary conditions, depending on the kind of data given; the default `SymBoundary()` symmetrizes the data, while `PerBoundary()` assumes it is periodic, and `ZPBoundary` pads with zeros.
All wavelets are stored in the Fourier domain, and all transforms consist of performing an fft (possibly an rfft if the data is real) of the input, pointwise multiplication (equivalent to convolution in the time domain), and then returning to the time domain.

Perhaps somewhat unusually, the averaging function, or father wavelet, is included as an option (the bottom row for the figure above). This can be either the paired averaging function or uniform in frequency (the `Dirac` averaging). The frequency coverage of the wavelets can be adjusted both in total frequency range both below by the `averagingLength` or above by the `extraOctaves` (caveat emptor with how well they will be defined in that case). The frequency density can be adjusted both in terms of the quality/scale factor `Q`, as well as how quickly this density falls off as the frequency goes to zero via `β`. Finally, depending on what kind of norm you want to preserve, `p` determines the norm preserved in the frequency domain (so `p=1` maintains the 1-norm in frequency, while `p=Inf` maintains the 1-norm in time).

## Possible extensions

- Higher dimensional wavelets have yet to be implemented.
- A DCT implementation of the symmetric boundary to halve the space and computational costs.
