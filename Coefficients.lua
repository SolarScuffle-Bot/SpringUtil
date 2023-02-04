--!strict

--[[
	Pulled directly from Fusion's spring utility. Thank you elttob :pray:
]]

--[[
	Returns a 2x2 matrix of coefficients for a given time, damping and speed.
	Specifically, this returns four coefficients - posPos, posVel, velPos, and
	velVel - which can be multiplied with position and velocity like so:

	local newPosition = oldPosition * posPos + oldVelocity * posVel
	local newVelocity = oldPosition * velPos + oldVelocity * velVel

	Special thanks to AxisAngle for helping to improve numerical precision.
]]
return function(Time: number, Damping: number, Speed: number): (number, number, number, number)
	-- if time or speed is 0, then the spring won't move
	if Time == 0 or Speed == 0 then
		return 1, 0, 0, 1
	end
	local PosPos, PosVel, VelPos, VelVel

	if Damping > 1 then
		-- overdamped spring
		-- solution to the characteristic equation:
		-- z = -ζω ± Sqrt[ζ^2 - 1] ω
		-- x[t] -> x0(e^(t z2) z1 - e^(t z1) z2)/(z1 - z2)
		--		 + v0(e^(t z1) - e^(t z2))/(z1 - z2)
		-- v[t] -> x0(z1 z2(-e^(t z1) + e^(t z2)))/(z1 - z2)
		--		 + v0(z1 e^(t z1) - z2 e^(t z2))/(z1 - z2)

		local ScaledTime = Time * Speed
		local Alpha = math.sqrt(Damping ^ 2 - 1)
		local ScaledInvAlpha = -0.5 / Alpha
		local Z1 = -Alpha - Damping
		local Z2 = 1 / Z1
		local ExpZ1 = math.exp(ScaledTime * Z1)
		local ExpZ2 = math.exp(ScaledTime * Z2)

		PosPos = (ExpZ2 * Z1 - ExpZ1 * Z2) * ScaledInvAlpha
		PosVel = (ExpZ1 - ExpZ2) * ScaledInvAlpha / Speed
		VelPos = (ExpZ2 - ExpZ1) * ScaledInvAlpha * Speed
		VelVel = (ExpZ1 * Z1 - ExpZ2 * Z2) * ScaledInvAlpha
	elseif Damping == 1 then
		-- critically damped spring
		-- x[t] -> x0(e^-tω)(1+tω) + v0(e^-tω)t
		-- v[t] -> x0(t ω^2)(-e^-tω) + v0(1 - tω)(e^-tω)

		local ScaledTime = Time * Speed
		local ExpTerm = math.exp(-ScaledTime)

		PosPos = ExpTerm * (1 + ScaledTime)
		PosVel = ExpTerm * Time
		VelPos = ExpTerm * (-ScaledTime * Speed)
		VelVel = ExpTerm * (1 - ScaledTime)
	else
		-- underdamped spring
		-- factored out of the solutions to the characteristic equation:
		-- α = Sqrt[1 - ζ^2]
		-- x[t] -> x0(e^-tζω)(α Cos[tα] + ζω Sin[tα])/α
		--	   + v0(e^-tζω)(Sin[tα])/α
		-- v[t] -> x0(-e^-tζω)(α^2 + ζ^2 ω^2)(Sin[tα])/α
		--	   + v0(e^-tζω)(α Cos[tα] - ζω Sin[tα])/α

		local Alpha = math.sqrt(1 - Damping ^ 2)
		local InvAlpha = 1 / Alpha
		local AlphaTime = Alpha * Time
		local ExpTerm = math.exp(-Time * Damping * Speed)
		local SinTerm = ExpTerm * math.sin(AlphaTime)
		local CosTerm = ExpTerm * math.cos(AlphaTime)
		local SinInvAlpha = SinTerm * InvAlpha
		local SinInvAlphaDamp = SinInvAlpha * Damping

		PosPos = SinInvAlphaDamp + CosTerm
		PosVel = SinInvAlpha / Speed
		VelPos = (SinInvAlphaDamp * Damping + SinTerm * Alpha) * -Speed
		VelVel = CosTerm - SinInvAlphaDamp
	end

	return PosPos, PosVel, VelPos, VelVel
end
