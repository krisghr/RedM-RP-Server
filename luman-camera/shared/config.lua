Config = {}

Config.OpenKey = 0x4F -- O vk

Config.DefaultFov = 50.0
Config.MinFov = 5.0
Config.MaxFov = 130.0

Config.EditorSpeed = 1.5
Config.EditorMinSpeed = 0.5
Config.EditorMaxSpeed = 40.0
Config.EditorSpeedStep = 0.5
Config.EditorBoostFactor = 4.0
Config.EditorSensitivity = 2.0
Config.EditorSmoothPos = 0.12
Config.EditorSmoothRot = 0.5
Config.EditorRollSpeed = 60.0 -- degrees per second

Config.DefaultKeyframeTime = 2000 -- ms
Config.MinKeyframeTime = 100 -- ms

Config.DefaultDof = {
  enabled = false,
  dofStrength = 0.5,
  focalLength = 25.0,
  maxFocal = 60.0,
}

Config.DefaultInterp = "spline"

Config.DefaultTimeOfDay = {
  enabled = false,
  hour = 12,
  minute = 0,
  transition = 0, -- ms
}

Config.DefaultWeather = {
  enabled = false,
  type = "sunny",
  transition = 1.0, -- seconds
}

Config.WeatherTypes = {
  "sunny", "clear", "clouds", "overcast", "fog", "misty",
  "rain", "drizzle", "shower", "thunder", "thunderstorm", "hurricane",
  "snow", "snowlight", "blizzard", "groundblizzard", "whiteout", "sandstorm",
}

-- Per-frame 3D overlays
Config.EnableVisualizer       = true  -- master switch for all 3D overlays below
Config.VisualizerDrawMarkers  = true  -- keyframe + handle dots (~60 DrawPoly per kf)
Config.VisualizerDrawFrustums = true  -- camera frustums (~32 DrawPoly per kf)
Config.VisualizerDrawPath     = true  -- path lines between keyframes (heavy in spline mode: ~320 DrawPoly)
Config.VisualizerDrawHandles  = true  -- tangent handles on selected keyframe (~12 DrawPoly)
Config.VisualizerDrawEntity   = true  -- entity-attach link line + marker
Config.EnableGizmo            = true  -- 3D translate/rotate handles