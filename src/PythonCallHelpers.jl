module PythonCallHelpers

using PythonCall: Py, pygetattr, pyhasattr, pyconvert

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
function pybasic(type, field)
    return quote
        using PythonCall: pyhasattr
        import PythonCall: Py, pyconvert
        # Code from https://github.com/stevengj/PythonPlot.jl/blob/d58f6c4/src/PythonPlot.jl#L65-L72
        Py(x::$type) = getfield(x, $(QuoteNode(Symbol(field))))
        pyconvert(::Type{$type}, py::Py) = $type(py)
        Base.:(==)(x::$type, y::$type) = pyconvert(Bool, Py(x) == Py(y))
        Base.isequal(x::$type, y::$type) = isequal(Py(x), Py(y))
        Base.hash(x::$type, h::UInt) = hash(Py(x), h)
        Base.Docs.doc(x::$type) = Text(pyconvert(String, Py(x).__doc__))
        # Code from https://github.com/stevengj/PythonPlot.jl/blob/d58f6c4/src/PythonPlot.jl#L75-L80
        Base.getproperty(x::$type, s::Symbol) = getproperty(Py(x), s)
        Base.getproperty(x::$type, s::AbstractString) = getproperty(Py(x), Symbol(s))
        Base.hasproperty(x::$type, s::Symbol) = pyhasattr(Py(x), s)
        Base.propertynames(x::$type) = propertynames(Py(x))
    end
end

"""
    @pyimmutable type [supertype] [field]

Construct an immutable wrapper for a Python object, with a supertype and a default fieldname.
"""
macro pyimmutable(type, supertype=Any, field=:py)
    return esc(
        quote
            using PythonCall: Py
            struct $type <: $supertype
                $field::Py
            end
            $(pybasic(type, field))
        end,
    )
end

"""
    @pymutable type [supertype] [field]

Construct an mutable wrapper for a Python object, with a supertype and a default fieldname.
"""
macro pymutable(type, supertype=Any, field=:py)
    return esc(
        quote
            using PythonCall: Py
            mutable struct $type <: $supertype
                $field::Py
            end
            $(pybasic(type, field))
            # Code from https://github.com/stevengj/PythonPlot.jl/blob/d58f6c4/src/PythonPlot.jl#L77-L78
            Base.setproperty!(x::$type, s::Symbol, v) = setproperty!(Py(x), s, v)
            Base.setproperty!(x::$type, s::AbstractString, v) =
                setproperty!(Py(x), Symbol(s), v)
        end,
    )
end

# See https://github.com/stevengj/PythonPlot.jl/issues/19
"""
    @pycallable type

Make an existing type callable.
"""
macro pycallable(type)
    return quote
        using PythonCall: Py
        import PythonCall: pycall
        pycall(x::$type, args...; kws...) = pycall(Py(x), args...; kws...)
        (x::$type)(args...; kws...) = pycall(Py(x), args...; kws...)
    end
end

end
