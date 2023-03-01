module PythonCallHelpers

using PythonCall: PythonCall, Py, pyhasattr, pyconvert, pycall

export @pyimmutable, @pymutable, @pycallable

macro pyimmutable(typename, fieldname)
    return quote
        # Code from https://github.com/stevengj/PythonPlot.jl/blob/d58f6c4/src/PythonPlot.jl#L65-L72
        struct $typename
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
        Base.getproperty(x::$typename, s::AbstractString) = getproperty(Py(x), Symbol(s))
        Base.hasproperty(x::$typename, s::Symbol) = pyhasattr(Py(x), s)
        Base.propertynames(x::$typename) = propertynames(Py(x))
    end
end

macro pymutable(typename, fieldname)
    return quote
        # Code from https://github.com/stevengj/PythonPlot.jl/blob/d58f6c4/src/PythonPlot.jl#L65-L72
        mutable struct $typename
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
        Base.getproperty(x::$typename, s::AbstractString) = getproperty(Py(x), Symbol(s))
        Base.setproperty!(x::$typename, s::Symbol, v) = setproperty!(Py(x), s, v)
        Base.setproperty!(x::$typename, s::AbstractString, v) =
            setproperty!(Py(x), Symbol(s), v)
        Base.hasproperty(x::$typename, s::Symbol) = pyhasattr(Py(x), s)
        Base.propertynames(x::$typename) = propertynames(Py(x))
    end
end

# See https://github.com/stevengj/PythonPlot.jl/issues/19
macro pycallable(T)
    return quote
        PythonCall.pycall(f::$T, args...; kws...) = pycall(Py(f), args...; kws...)
        (f::$T)(args...; kws...) = pycall(Py(f), args...; kws...)
    end
end

end
