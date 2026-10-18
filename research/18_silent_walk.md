# 18 — Silent Walk / Run

**Spec:** "Completely removes footstep audio while traveling at full movement speeds."

**Dump evidence**
- Footstep/weapon sounds are routed through `ReplicatedStorage.SoundService.RemoteEvents.MakeSoundClient:FireServer(sound, pos)`
  (network.md:941-950; GunShootModule.luau:622 for gunfire). This is the C2S "play my sound for
  others" path.
- Local footstep playback also goes via the SoundService remotes (`PlaySoundOnClient` S2C,
  `DistanceSound`).

**Trust:** local (suppressing our own outgoing sound).

**Implementation**
- Hook the `MakeSoundClient` remote's `FireServer` (capability-guarded `__namecall`/`hookfunction`)
  and drop calls whose sound is a footstep (filter by sound name containing "Step"/"Foot"/"Walk" or
  by the calling context). This stops broadcasting our footsteps to others.
- Local mute: also lower/skip local footstep sound instances if accessible.

**UI:** toggle "Silent Walk".

**Risks / partial**
- Sound-name filter is heuristic (the exact footstep sound names are not enumerated in the dump).
  Default filter targets step-like names; over-broad filtering could mute other self-sounds, so keep
  the filter list narrow and documented. Needs hook capability; self-disables otherwise.
