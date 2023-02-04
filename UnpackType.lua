--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Oklab = require(ReplicatedStorage.Util.OklabUtil)

--[[
	Unpacks an animatable type into an array of numbers.
	If the type is not animatable, an empty array will be returned.

	FIXME: This function uses a lot of redefinitions to suppress false positives
	from the Luau typechecker - ideally these wouldn't be required

	FUTURE: When Luau supports singleton types, those could be used in
	conjunction with intersection types to make this function fully statically
	type checkable.
]]
return function(Value: any, TypeString: string): { number }
	if TypeString == "number" then
		local Value = Value :: number
		return { Value }

	elseif TypeString == "CFrame" then
		-- FUTURE: is there a better way of doing this? doing distance
		-- calculations on `angle` may be incorrect
		local Axis, Angle = Value:ToAxisAngle()
		return { Value.X, Value.Y, Value.Z, Axis.X, Axis.Y, Axis.Z, Angle }

	elseif TypeString == "Color3" then
		local Lab = Oklab:To(Value)
		return { Lab.X, Lab.Y, Lab.Z }

	elseif TypeString == "ColorSequenceKeypoint" then
		local Lab = Oklab:To(Value.Value)
		return { Lab.X, Lab.Y, Lab.Z, Value.Time }

	elseif TypeString == "DateTime" then
		return { Value.UnixTimestampMillis }

	elseif TypeString == "NumberRange" then
		return { Value.Min, Value.Max }

	elseif TypeString == "NumberSequenceKeypoint" then
		return { Value.Value, Value.Time, Value.Envelope }

	elseif TypeString == "PhysicalProperties" then
		return { Value.Density, Value.Friction, Value.Elasticity, Value.FrictionWeight, Value.ElasticityWeight }

	elseif TypeString == "Ray" then
		return {
			Value.Origin.X,
			Value.Origin.Y,
			Value.Origin.Z,
			Value.Direction.X,
			Value.Direction.Y,
			Value.Direction.Z,
		}

	elseif TypeString == "Rect" then
		return { Value.Min.X, Value.Min.Y, Value.Max.X, Value.Max.Y }

	elseif TypeString == "Region3" then
		-- FUTURE: support rotated Region3s if/when they become constructable
		return {
			Value.CFrame.X,
			Value.CFrame.Y,
			Value.CFrame.Z,
			Value.Size.X,
			Value.Size.Y,
			Value.Size.Z,
		}

	elseif TypeString == "Region3int16" then
		return { Value.Min.X, Value.Min.Y, Value.Min.Z, Value.Max.X, Value.Max.Y, Value.Max.Z }

	elseif TypeString == "UDim" then
		return { Value.Scale, Value.Offset }

	elseif TypeString == "UDim2" then
		return { Value.X.Scale, Value.X.Offset, Value.Y.Scale, Value.Y.Offset }

	elseif TypeString == "Vector2" then
		return { Value.X, Value.Y }

	elseif TypeString == "Vector2int16" then
		return { Value.X, Value.Y }

	elseif TypeString == "Vector3" then
		return { Value.X, Value.Y, Value.Z }

	elseif TypeString == "Vector3int16" then
		return { Value.X, Value.Y, Value.Z }

	else
		return {}
	end
end
