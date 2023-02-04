local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local SpringService = require(script.Service)
local Types = require(script.Types)

local SpringUtil = {}

SpringUtil._Springs = {} :: { [string]: Types.Spring<any> }
SpringUtil._Connections = {} :: { [Instance]: RBXScriptSignal }

function SpringUtil:Play(Object: Instance, Goals: { [string]: any }, Info: { Speed: number, Damping: number }?)
	local CurrentSprings = SpringUtil._Springs[Object] or {}
	local Info = Info or {}

	for Name, Value in Goals do
		local Spring = CurrentSprings[Name]
		if Spring then
			Spring.GoalState = Value
			Spring.Speed = Info.Speed or Spring.Speed
			Spring.Damping = Info.Damping or Spring.Damping
		else
			Spring = SpringService:Create {
				Object = Object,
				Property = Name,

				GoalState = Value,
				Speed = Info.Speed,
				Damping = Info.Damping,
			}
		end

		SpringService:UpdatePhysics(Spring)
		SpringService:UpdateGoal(Spring)

		CurrentSprings[Name] = Spring
	end

	SpringUtil._Springs[Object] = CurrentSprings
	SpringUtil._Connections = Object.Destroying:Connect(function()
		SpringUtil:Clear(Object)
	end)
end

function SpringUtil:Stop(Object: Instance, Properties: { string }?)
	local CurrentSprings = SpringUtil._Springs[Object]
	if not CurrentSprings then return end

	if Properties then
		for _, Name in Properties do
			local Spring = CurrentSprings[Name]
			if not Spring then continue end

			SpringService:Stop(Spring)
		end
	else
		for _, Spring in CurrentSprings do
			SpringService:Stop(Spring)
		end
	end
end

function SpringUtil:Clear(Object: Instance)
	local CurrentSprings = SpringUtil._Springs[Object]
	if not CurrentSprings then return end

	SpringUtil._Connections[Object]:Disconnect()
	SpringUtil._Connections[Object] = nil

	for _, Spring in CurrentSprings do
		SpringService:Stop(Spring)
		Spring.Completed:DisconnectAll()
	end
	SpringUtil._Springs[Object] = nil
end

function SpringUtil:GetCompletedSignal(Object: Instance, Property: string): typeof(Signal.new())
	local CurrentSprings = SpringUtil._Springs[Object] or {}

	local Spring = CurrentSprings[Property]
	if not Spring then
		SpringUtil:Play(Object, {
			[Property] = Object[Property],
		})

		Spring = CurrentSprings[Property]
	end

	return Spring.Completed
end

return SpringUtil