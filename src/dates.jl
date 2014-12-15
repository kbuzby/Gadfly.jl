using Base.Dates

#define promote rules to get better accuracy of division and modulo

value(x::Period) = x.value

#convert type to a finer measurement
fperiodt(::Type{Year}) = Month
fperiodt(::Type{Month}) = Day
fperiodt(::Type{Day}) = Hour
fperiodt(::Type{Hour}) = Minute
fperiodt(::Type{Minute}) = Second
fperiodt(::Type{Second}) = Millisecond

#convert value to a finer unit
fperiodval(t::Year) = Month(t)
fperiodval(t::Month) = Day(t)
fperiodval(t::Day) = Hour(t)
fperiodval(t::Hour) = Minute(t)
fperiodval(t::Minute) = Second(t)
fperiodval(t::Second) = Millisecond(t)

#when dividing Date values that become less than one convert the DateTime type to a finer type and perform division accordingly
for op in (:/,:div)
	@eval begin
		($op){P<:Period}(x::P,y::P) = ((value(x)/value(y))>=1 ? P(round(Integer, ($op)(value(x),value(y)))) : fperiodt(P)(round(Integer, ($op)(value(fperiodval(x)),value(fperiodval(y))))))
		($op){P<:Period}(x::P,y::Real) = ((value(x)/Int64(y))>=1 ? P(round(Integer, ($op)(value(x),Int64(y)))) : fperiodt(P)(round(Integer, ($op)(value(fperiodval(x)),Int64(y)))))
		#add operations for if the values are greater than 1 but still not an integer... either round/force Int on the output of value(x)/value(y) or convert to a finer DateTime type 
		#former option seems easier but may conflict with existing dates/periods.jl operations
	end
end
