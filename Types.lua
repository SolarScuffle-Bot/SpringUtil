local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

-- A state object which follows another state object using spring simulation.
export type Spring<T> = {
	Object: Instance,
	Property: string,
	Speed: number,
	SpeedIsState: boolean,
	LastSpeed: number,
	Damping: number,
	DampingIsState: boolean,
	LastDamping: number,
	GoalState: T,
	GoalValue: T,
	CurrentType: string,
	CurrentValue: T,
	SpringPositions: { number },
	SpringGoals: { number },
	SpringVelocities: { number },
	LastSchedule: number,
	Completed: typeof(Signal.new()),
}

-- Types that can be expressed as vectors of numbers, and so can be animated.
export type Animatable =
	number |
	CFrame |
	Color3 |
	ColorSequenceKeypoint |
	DateTime |
	NumberRange |
	NumberSequenceKeypoint |
	PhysicalProperties |
	Ray |
	Rect |
	Region3 |
	Region3int16 |
	UDim |
	UDim2 |
	Vector2 |
	Vector2int16 |
	Vector3 |
	Vector3int16

return false