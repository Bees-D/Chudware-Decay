# 27 — Custom Crosshair Overlay

**Spec:** "Generates an on-screen reticle to assist with hip-firing weapons that lack native
crosshairs."

**Dump evidence**
- Purely local UI; no game symbol needed. Center of screen = `Camera.ViewportSize/2`
  (GunShootModule.luau:49-50 uses the same center point for the aim ray, so the crosshair matches the
  real hip-fire point).

**Trust:** local.

**Implementation**
- Draw a reticle at viewport center using the Drawing API (4 `Drawing.new("Line")` for a cross, or a
  `Circle`) or a ScreenGui frame. Configurable color, size, gap, thickness, dot.

**UI:** toggle "Crosshair", style dropdown (cross/dot/circle), color, size, gap, thickness.

**Risks**
- None significant; Drawing objects must be cleaned up on unload.
