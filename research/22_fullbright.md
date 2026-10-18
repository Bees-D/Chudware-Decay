# 22 — Fullbright / Always Day

**Spec:** "Overrides client-side lighting shaders, shadows, and fog to maximize brightness ...
negates pitch-black night cycles, unlit caves, and dense weather."

**Dump evidence**
- Lighting is continuously driven by `TimeChanger.luau`: it tweens `Lighting.{Brightness,
  EnvironmentDiffuseScale, EnvironmentSpecularScale, Ambient, OutdoorAmbient, FogColor}`,
  `Lighting.ClockTime`, and `Lighting.Atmosphere.Density` based on `ReplicatedStorage.Time.Value`
  and `player.GlobalTime.Value` (TimeChanger.luau:15-81, 156-227).
- Night preset forces dark Ambient and black FogColor (TimeChanger.luau:29-41).

**Trust:** local (Lighting is client-only).

**Implementation**
- Because TimeChanger re-asserts Lighting on every Time/DayType change, fullbright must re-apply on
  RenderStepped (or `Lighting:GetPropertyChangedSignal` hooks): set `Brightness` high,
  `Ambient`/`OutdoorAmbient` white, `ClockTime = 14`, `FogEnd = huge`, `Atmosphere.Density = 0`,
  `EnvironmentDiffuseScale/SpecularScale = 1`. Cache originals; restore on toggle-off.

**UI:** toggle "Fullbright", brightness slider.

**Risks**
- Fights TimeChanger's tweens → must win by re-asserting each frame (expected). Restore captured
  originals cleanly when disabled.
