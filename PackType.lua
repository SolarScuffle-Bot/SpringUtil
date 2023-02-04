--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(script.Parent.Types)
local Oklab = require(ReplicatedStorage.Util.OklabUtil)

--[[
	Packs an array of numbers into a given animatable data type.
	If the type is not animatable, nil will be returned.

	FUTURE: When Luau supports singleton types, those could be used in
	conjunction with intersection types to make this function fully statically
	type checkable.
]]
return function(Numbers: { number }, TypeString: string): Types.Animatable?
	if TypeString == "number" then
		return Numbers[1]

	elseif TypeString == "CFrame" then
		return
			CFrame.new(Numbers[1], Numbers[2], Numbers[3]) *
			CFrame.fromAxisAngle(
				Vector3.new(Numbers[4], Numbers[5], Numbers[6]).Unit,
				Numbers[7]
			)

	elseif TypeString == "Color3" then
		return Oklab:From(
			Vector3.new(Numbers[1], Numbers[2], Numbers[3]),
			false
		)

	elseif TypeString == "ColorSequenceKeypoint" then
		return ColorSequenceKeypoint.new(
			Numbers[4],
			Oklab:From(
				Vector3.new(Numbers[1], Numbers[2], Numbers[3]),
				false
			)
		)

	elseif TypeString == "DateTime" then
		return DateTime.fromUnixTimestampMillis(Numbers[1])

	elseif TypeString == "NumberRange" then
		return NumberRange.new(Numbers[1], Numbers[2])

	elseif TypeString == "NumberSequenceKeypoint" then
		return NumberSequenceKeypoint.new(Numbers[2], Numbers[1], Numbers[3])

	elseif TypeString == "PhysicalProperties" then
		return PhysicalProperties.new(Numbers[1], Numbers[2], Numbers[3], Numbers[4], Numbers[5])

	elseif TypeString == "Ray" then
		return Ray.new(
			Vector3.new(Numbers[1], Numbers[2], Numbers[3]),
			Vector3.new(Numbers[4], Numbers[5], Numbers[6])
		)

	elseif TypeString == "Rect" then
		return Rect.new(Numbers[1], Numbers[2], Numbers[3], Numbers[4])

	elseif TypeString == "Region3" then
		-- FUTURE: support rotated Region3s if/when they become constructable
		local position = Vector3.new(Numbers[1], Numbers[2], Numbers[3])
		local halfSize = Vector3.new(Numbers[4] / 2, Numbers[5] / 2, Numbers[6] / 2)
		return Region3.new(position - halfSize, position + halfSize)

	elseif TypeString == "Region3int16" then
		return Region3int16.new(
			Vector3int16.new(Numbers[1], Numbers[2], Numbers[3]),
			Vector3int16.new(Numbers[4], Numbers[5], Numbers[6])
		)

	elseif TypeString == "UDim" then
		return UDim.new(Numbers[1], Numbers[2])

	elseif TypeString == "UDim2" then
		return UDim2.new(Numbers[1], Numbers[2], Numbers[3], Numbers[4])

	elseif TypeString == "Vector2" then
		return Vector2.new(Numbers[1], Numbers[2])

	elseif TypeString == "Vector2int16" then
		return Vector2int16.new(Numbers[1], Numbers[2])

	elseif TypeString == "Vector3" then
		return Vector3.new(Numbers[1], Numbers[2], Numbers[3])

	elseif TypeString == "Vector3int16" then
		return Vector3int16.new(Numbers[1], Numbers[2], Numbers[3])

	else
		return nil
	end
end