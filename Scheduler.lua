--!strict

--[[
	Manages batch updating of spring objects.
]]

local RunService = game:GetService("RunService")

local SpringCoefficients = require(script.Parent.Coefficients)
local PackType = require(script.Parent.PackType)
local Types = require(script.Parent.Types)

type Set<T> = { [T]: true }

local SpringScheduler = {}

SpringScheduler._Epsilon = 1e-4
SpringScheduler._ActiveSprings = {} :: Set<Types.Spring<any>>
SpringScheduler._LastUpdateTime = os.clock()

function SpringScheduler:Add<T>(Spring: Types.Spring<T>)
	-- we don't necessarily want to use the most accurate time - here we snap to
	-- the last update time so that springs started within the same frame have
	-- identical time steps
	Spring.LastSchedule = SpringScheduler._LastUpdateTime
	Spring.StartDisplacements = {}
	Spring.StartVelocities = {}
	for Index, Goal in Spring.SpringGoals do
		Spring.StartDisplacements[Index] = Spring.SpringPositions[Index] - Goal
		Spring.StartVelocities[Index] = Spring.SpringVelocities[Index]
	end

	SpringScheduler._ActiveSprings[Spring] = true
end

function SpringScheduler:Remove<T>(Spring: Types.Spring<T>)
	SpringScheduler._ActiveSprings[Spring] = nil
end

local function UpdateAllSprings()
	local SpringsToSleep: Set<Types.Spring<any>> = {}
	SpringScheduler._LastUpdateTime = os.clock()

	for Spring in SpringScheduler._ActiveSprings do
		local PosPos, PosVel, VelPos, VelVel =
			SpringCoefficients(SpringScheduler._LastUpdateTime - Spring.LastSchedule, Spring.CurrentDamping, Spring.CurrentSpeed)

		local Positions = Spring.SpringPositions
		local Velocities = Spring.SpringVelocities
		local StartDisplacements = Spring.StartDisplacements
		local StartVelocities = Spring.StartVelocities
		local IsMoving = false

		for Index, Goal in Spring.SpringGoals do
			local OldDisplacement = StartDisplacements[Index]
			local OldVelocity = StartVelocities[Index]
			local NewDisplacement = OldDisplacement * PosPos + OldVelocity * PosVel
			local NewVelocity = OldDisplacement * VelPos + OldVelocity * VelVel

			if math.abs(NewDisplacement) > SpringScheduler._Epsilon or math.abs(NewVelocity) > SpringScheduler._Epsilon then
				IsMoving = true
			end

			Positions[Index] = NewDisplacement + Goal
			Velocities[Index] = NewVelocity
		end

		if not IsMoving then
			SpringsToSleep[Spring] = true
		end
	end

	for Spring in SpringScheduler._ActiveSprings do
		Spring.CurrentValue = PackType(Spring.SpringPositions, Spring.CurrentType)
		Spring.Object[Spring.Property] = Spring.CurrentValue
	end

	for Spring in SpringsToSleep do
		SpringScheduler._ActiveSprings[Spring] = nil
		Spring.CurrentValue = Spring.GoalValue
		Spring.Completed:Fire()
	end
end

RunService:BindToRenderStep("__SpringScheduler", Enum.RenderPriority.First.Value, UpdateAllSprings)

return SpringScheduler
