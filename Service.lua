local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local SpringScheduler = require(script.Parent.Scheduler)
local UnpackType = require(script.Parent.UnpackType)
local Types = require(script.Parent.Types)

local SpringService = {}

--[[
	Returns the current value of this Spring object.
]]
function SpringService:Get<T>(Spring: Types.Spring<T>): T
	return Spring.CurrentValue
end

--[[
	Sets the position of the internal springs, meaning the value of this
	Spring will jump to the given value. This doesn't affect velocity.

	If the type doesn't match the current type of the spring, an error will be
	thrown.
]]
function SpringService:SetPosition<T>(Spring: Types.Spring<T>, NewValue: Types.Animatable)
	local NewType = typeof(NewValue)
	if NewType ~= Spring.CurrentType then
		warn("springTypeMismatch", nil, NewType, Spring.CurrentType)
	end

	Spring.SpringPositions = UnpackType(NewValue, NewType)
	Spring.CurrentValue = NewValue
	SpringScheduler:Add(Spring)
end

--[[
	Sets the velocity of the internal springs, overwriting the existing velocity
	of this Spring. This doesn't affect position.

	If the type doesn't match the current type of the spring, an error will be
	thrown.
]]
function SpringService:SetVelocity<T>(Spring: Types.Spring<T>, NewValue: Types.Animatable)
	local NewType = typeof(NewValue)
	if NewType ~= Spring.CurrentType then
		warn("springTypeMismatch", nil, NewType, Spring.CurrentType)
	end

	Spring.SpringVelocities = UnpackType(NewValue, NewType)
	SpringScheduler:Add(Spring)
end

--[[
	Adds to the velocity of the internal springs, on top of the existing
	velocity of this Spring. This doesn't affect position.

	If the type doesn't match the current type of the spring, an error will be
	thrown.
]]
function SpringService:AddVelocity<T>(Spring: Types.Spring<T>, DeltaTime: Types.Animatable)
	local DeltaTime = typeof(DeltaTime)
	if DeltaTime ~= Spring.CurrentType then
		warn("springTypeMismatch", nil, DeltaTime, Spring.CurrentType)
	end

	local SpringDeltas = UnpackType(DeltaTime, DeltaTime)
	for Index, Delta in SpringDeltas do
		Spring.SpringVelocities[Index] += Delta
	end

	SpringScheduler:Add(Spring)
end

--[[
	Called when the goal state changes value, or when the Speed or Damping has
	changed.
]]
function SpringService:UpdatePhysics<T>(Spring: Types.Spring<T>): boolean
	-- Speed/Damping change
	local Damping = Spring.Damping
	if typeof(Damping) ~= "number" then
		warn("mistypedSpringDamping", nil, typeof(Damping))

	elseif Damping < 0 then
		warn("invalidSpringDamping", nil, Damping)

	else
		Spring.CurrentDamping = Damping
	end

	local Speed = Spring.Speed
	if typeof(Speed) ~= "number" then
		warn("mistypedSpringSpeed", nil, typeof(Speed))

	elseif Speed < 0 then
		warn("invalidSpringSpeed", nil, Speed)

	else
		Spring.CurrentSpeed = Speed
	end

	return false
end

--[[
	Called when the goal state changes value, or when the Speed or Damping has
	changed.
]]
function SpringService:UpdateGoal<T>(Spring: Types.Spring<T>): boolean
	-- goal change - reconfigure spring to target new goal
	Spring.GoalValue = Spring.GoalState

	local OldType = Spring.CurrentType
	local NewType = typeof(Spring.GoalState)
	Spring.CurrentType = NewType

	local SpringGoals = UnpackType(Spring.GoalState, NewType)
	local NumSprings = #SpringGoals
	Spring.SpringGoals = SpringGoals

	if NewType ~= OldType then
		-- if the type changed, snap to the new value and rebuild the
		-- position and velocity tables
		Spring.CurrentValue = Spring.GoalValue
		Spring.Object[Spring.Property] = Spring.CurrentValue

		local SpringPositions = table.create(NumSprings, 0)
		local SpringVelocities = table.create(NumSprings, 0)
		for Index, SpringGoal in SpringGoals do
			SpringPositions[Index] = SpringGoal
		end
		Spring.SpringPositions = SpringPositions
		Spring.SpringVelocities = SpringVelocities

		-- the spring may have been animating before, so stop that
		SpringScheduler:Remove(Spring)
		return true

		-- otherwise, the type hasn't changed, just the goal...
	elseif NumSprings == 0 then
		-- if the type isn't animatable, snap to the new value
		Spring.CurrentValue = Spring.GoalValue
		return true

	else
		-- if it's animatable, let it animate to the goal
		SpringScheduler:Add(Spring)
		return false
	end
end

--[[
	Stops the spring from animating
]]
function SpringService:Stop<T>(Spring: Types.Spring<T>)
	SpringScheduler:Remove(Spring)
end

function SpringService:Create<T>(Args: {
	Object: Instance,
	Property: string,
	GoalState: T,
	Speed: number?,
	Damping: number?
}): Types.Spring<T>
	local Spring = {
		Object = Args.Object,
		Property = Args.Property,

		Speed = Args.Speed or 10,
		Damping = Args.Damping or 1,

		GoalState = Args.GoalState,
		GoalValue = nil,

		CurrentType = nil,
		CurrentValue = Args.Object[Args.Property],
		CurrentSpeed = nil,
		CurrentDamping = nil,

		SpringPositions = nil,
		SpringGoals = nil,
		SpringVelocities = nil,

		Completed = Signal.new(),
	}

	return Spring
end

return SpringService