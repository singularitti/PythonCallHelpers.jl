module PythonCallHelpers

using PythonCall: PythonCall, Py, pygetattr, pyhasattr, pyconvert, pycall

export @pyimmutable, @pymutable, @pycallable

# Code from https://github.com/stevengj/PythonPlot.jl/blob/d17c1d5/src/PythonPlot.jl#L26-L52
struct LazyHelp
    obj::Py
    keys::Tuple{Vararg{String}}
    LazyHelp(obj) = new(obj, ())
    LazyHelp(obj, key::AbstractString) = new(obj, (key,))
    LazyHelp(obj, key1::AbstractString, key2::AbstractString) = new(obj, (key1, key2))
    LazyHelp(obj, keys::AbstractString...) = new(obj, keys)
end
function Base.show(io::IO, ::MIME"text/plain", help::LazyHelp)
    obj = help.obj
    for key in help.keys
        obj = pygetattr(obj, key)
    end
    if pyhasattr(obj, "__doc__")
        print(io, pyconvert(String, obj.__doc__))
    else
        print(io, "no Python docstring found for ", obj)
    end
end
Base.show(io::IO, help::LazyHelp) = show(io, "text/plain", help)
function Base.Docs.catdoc(helps::LazyHelp...)
    Base.Docs.Text() do io
        for help in helps
            show(io, "text/plain", help)
        end
    end
end

# See https://github.com/rafaqz/DimensionalData.jl/blob/4814246/src/Dimensions/dimension.jl#L382-L398
macro pyimmutable(typename, fieldname)
    return esc(
        quote
            # Code from https://github.com/stevengj/PythonPlot.jl/blob/d58f6c4/src/PythonPlot.jl#L65-L72
            Core.@__doc__ struct $typename
                $fieldname::Py
            end
            PythonCall.Py(x::$typename) = getfield(x, $fieldname)
            PythonCall.pyconvert(::Type{$typename}, py::Py) = $typename(py)
            Base.:(==)(x::$typename, y::$typename) = pyconvert(Bool, Py(x) == Py(y))
            Base.isequal(x::$typename, y::$typename) = isequal(Py(x), Py(y))
            Base.hash(x::$typename, h::UInt) = hash(Py(x), h)
            Base.Docs.doc(x::$typename) = Base.Docs.Text(pyconvert(String, Py(x).__doc__))
            # Code from https://github.com/stevengj/PythonPlot.jl/blob/d58f6c4/src/PythonPlot.jl#L75-L80
            Base.getproperty(x::$typename, s::Symbol) = getproperty(Py(x), s)
            Base.getproperty(x::$typename, s::AbstractString) =
                getproperty(Py(x), Symbol(s))
            Base.hasproperty(x::$typename, s::Symbol) = pyhasattr(Py(x), s)
            Base.propertynames(x::$typename) = propertynames(Py(x))
        end,
    )
end

macro pymutable(typename, fieldname)
    return esc(
        quote
            # Code from https://github.com/stevengj/PythonPlot.jl/blob/d58f6c4/src/PythonPlot.jl#L65-L72
            Core.@__doc__ mutable struct $typename
                $fieldname::Py
            end
            PythonCall.Py(x::$typename) = getfield(x, $fieldname)
            PythonCall.pyconvert(::Type{$typename}, py::Py) = $typename(py)
            Base.:(==)(x::$typename, y::$typename) = pyconvert(Bool, Py(x) == Py(y))
            Base.isequal(x::$typename, y::$typename) = isequal(Py(x), Py(y))
            Base.hash(x::$typename, h::UInt) = hash(Py(x), h)
            Base.Docs.doc(x::$typename) = Base.Docs.Text(pyconvert(String, Py(x).__doc__))
            # Code from https://github.com/stevengj/PythonPlot.jl/blob/d58f6c4/src/PythonPlot.jl#L75-L80
            Base.getproperty(x::$typename, s::Symbol) = getproperty(Py(x), s)
            Base.getproperty(x::$typename, s::AbstractString) =
                getproperty(Py(x), Symbol(s))
            Base.setproperty!(x::$typename, s::Symbol, v) = setproperty!(Py(x), s, v)
            Base.setproperty!(x::$typename, s::AbstractString, v) =
                setproperty!(Py(x), Symbol(s), v)
            Base.hasproperty(x::$typename, s::Symbol) = pyhasattr(Py(x), s)
            Base.propertynames(x::$typename) = propertynames(Py(x))
        end,
    )
end

# See https://github.com/stevengj/PythonPlot.jl/issues/19
macro pycallable(T)
    return quote
        PythonCall.pycall(f::$T, args...; kws...) = pycall(Py(f), args...; kws...)
        (f::$T)(args...; kws...) = pycall(Py(f), args...; kws...)
    end
end

end
