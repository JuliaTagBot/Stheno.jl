# Create CompositeMean, CompositeKernel and CompositeCrossKernel.
for (composite_type, parent_type) in [(:CompositeMean, :MeanFunction),
                                      (:CompositeKernel, :Kernel),
                                      (:CompositeCrossKernel, :CrossKernel),]
@eval struct $composite_type{Tf, N} <: $parent_type
    f::Tf
    x::Tuple{Vararg{Any, N}}
    $composite_type(f::Tf, x::Vararg{Any, N}) where {Tf, N} = new{Tf, N}(f, x)
end
end

# CompositeMean definitions.
length(c::CompositeMean) = length(c.x[1])
(μ::CompositeMean)(x) = map(μ.f, map(f->f(x), μ.x)...)
unary_obswise(f::CompositeMean, X::AVM) = map(f.f, map(f->unary_obswise(f, X), f.x)...)

# CompositeKernel and CompositeCrossKernel definitions.
for T in [:CompositeKernel, :CompositeCrossKernel]
    @eval (k::$T)(x, x′) = map(k.f, map(f->f(x, x′), k.x)...)
    @eval size(k::$T, N::Int) = size(k.x[1], N)
    @eval isstationary(k::$T) = all(map(isstationary, k.x))
    for foo in [:binary_obswise, :pairwise]
        @eval $foo(f::$T, X::AVM) = map(f.f, map(f->$foo(f, X), f.x)...)
        @eval $foo(f::$T, X::AVM, X′::AVM) = map(f.f, map(f->$foo(f, X, X′), f.x)...)
    end
end

# function pairwise(k::CompositeKernel, X::AVM)
#     Σs = map(f->pairwise(f, X), k.x)
#     Σout = map(k.f, Σs...)
#     # @show typeof.(Σs), typeof(Σout)
#     return map(k.f, map(f->pairwise(f, X), k.x)...)
# end

"""
    LhsCross <: CrossKernel

A cross-kernel given by `k(x, x′) = f(x) * k(x, x′)`.
"""
struct LhsCross <: CrossKernel
    f::Any
    k::CrossKernel
end
(k::LhsCross)(x, x′) = k.f(x) * k.k(x, x′)
size(k::LhsCross, N::Int) = size(k.k, N)
pairwise(k::LhsCross, X::AVM, X′::AVM) = unary_obswise(k.f, X) .* pairwise(k.k, X, X′)

"""
    RhsCross <: CrossKernel

A cross-kernel given by `k(x, x′) = k(x, x′) * f(x′)`.
"""
struct RhsCross <: CrossKernel
    k::CrossKernel
    f
end
(k::RhsCross)(x, x′) = k.k(x, x′) * k.f(x′)
size(k::RhsCross, N::Int) = size(k.k, N)
pairwise(k::RhsCross, X::AVM, X′::AVM) = pairwise(k.k, X, X′) .* unary_obswise(k.f, X′)'

"""
    OuterCross <: CrossKernel

A kernel given by `k(x, x′) = f(x) * k(x, x′) * f(x′)`.
"""
struct OuterCross <: CrossKernel
    f
    k::CrossKernel
end
(k::OuterCross)(x, x′) = k.f(x) * k.k(x, x′) * k.f(x′)
size(k::OuterCross, N::Int) = size(k.k, N)
pairwise(k::OuterCross, X::AVM, X′::AVM) =
    unary_obswise(k.f, X) .* pairwise(k.k, X, X′) .* unary_obswise(k.f, X′)'

"""
    OuterKernel <: Kernel

A kernel given by `k(x, x′) = f(x) * k(x, x′) * f(x′)`.
"""
struct OuterKernel <: Kernel
    f
    k::Kernel
end
(k::OuterKernel)(x, x′) = k.f(x) * k.k(x, x′) * k.f(x′)
size(k::OuterKernel, N::Int) = size(k.k, N)
pairwise(k::OuterKernel, X::AVM) = Xt_A_X(pairwise(k.k, X), Diagonal(unary_obswise(k.f, X)))
pairwise(k::OuterKernel, X::AVM, X′::AVM) =
    unary_obswise(k.f, X) .* pairwise(k.k, X, X′) .* unary_obswise(k.f, X′)'


############################## Convenience functionality ##############################

import Base: +, *, promote_rule, convert

promote_rule(::Type{<:MeanFunction}, ::Type{<:Union{Real, Function}}) = MeanFunction
convert(::Type{MeanFunction}, x::Real) = ConstantMean(x)

promote_rule(::Type{<:Kernel}, ::Type{<:Union{Real, Function}}) = Kernel
convert(::Type{<:CrossKernel}, x::Real) = ConstantKernel(x)

# Composing mean functions.
+(μ::MeanFunction, μ′::MeanFunction) = CompositeMean(+, μ, μ′)
+(μ::MeanFunction, μ′::Real) = +(promote(μ, μ′)...)
+(μ::Real, μ′::MeanFunction) = +(promote(μ, μ′)...)

*(μ::MeanFunction, μ′::MeanFunction) = CompositeMean(*, μ, μ′)
*(μ::MeanFunction, μ′::Real) = *(promote(μ, μ′)...)
*(μ::Real, μ′::MeanFunction) = *(promote(μ, μ′)...)

# Composing kernels.
+(k::Kernel, k′::Kernel) = CompositeKernel(+, k, k′)
+(k::Kernel, k′::Real) = +(promote(k, k′)...)
+(k::Real, k′::Kernel) = +(promote(k, k′)...)

*(k::Kernel, k′::Kernel) = CompositeKernel(*, k, k′)
*(k::Kernel, k′::Real) = *(promote(k, k′)...)
*(k::Real, k′::Kernel) = *(promote(k, k′)...)
