module PythonCallHelpers

using PythonCall: PythonCall, Py, pyhasattr, pyconvert, pycall

export @pymutable, @pycallable

macro pymutable(T)
    return quote
        # Code from https://github.com/stevengj/PythonPlot.jl/blob/d58f6c4/src/PythonPlot.jl#L65-L72
        PythonCall.Py(f::$T) = getfield(f, :o)
        PythonCall.pyconvert(::Type{$T}, o::Py) = $T(o)
        Base.:(==)(f::$T, g::$T) = pyconvert(Bool, Py(f) == Py(g))
        Base.isequal(f::$T, g::$T) = isequal(Py(f), Py(g))
        Base.hash(f::$T, h::UInt) = hash(Py(f), h)
        Base.Docs.doc(f::$T) = Base.Docs.Text(pyconvert(String, Py(f).__doc__))
        # Code from https://github.com/stevengj/PythonPlot.jl/blob/d58f6c4/src/PythonPlot.jl#L75-L80
        Base.getproperty(f::$T, s::Symbol) = getproperty(Py(f), s)
        Base.getproperty(f::$T, s::AbstractString) = getproperty(Py(f), Symbol(s))
        Base.setproperty!(f::$T, s::Symbol, x) = setproperty!(Py(f), s, x)
        Base.setproperty!(f::$T, s::AbstractString, x) = setproperty!(Py(f), Symbol(s), x)
        Base.hasproperty(f::$T, s::Symbol) = pyhasattr(Py(f), s)
        Base.propertynames(f::$T) = propertynames(Py(f))
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
