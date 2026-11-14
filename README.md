# Roblox Tower Climbing Game: EGG CLIMB!

EGG CLIMB! is a multiplayer Roblox tower climbing game script featuring an adorable egg character, a colorful classic Roblox style, studded platforms, checkpoints, hazards, progression, cosmetic unlocks, and a HUD for climbing a 30-floor tower.

## Install

1. Open the place in Roblox Studio.
2. Create a Script in `ServerScriptService` named `WorldBuilder.server.lua` and paste in the contents of the matching file.
3. Create a Script in `ServerScriptService` named `ProgressionService.server.lua` and paste in the contents of the matching file.
4. Create a Script in `ServerScriptService` named `CosmeticService.server.lua` and paste in the contents of the matching file.
5. Create a LocalScript in `StarterPlayer > StarterPlayerScripts` named `EggClimbClient.client.lua` and paste in the contents of the matching file.
6. Publish the place before testing multiplayer or persistent progression.
7. To test DataStore saving in Studio, enable `Game Settings > Security > Enable Studio Access to API Services`.

The scripts automatically create the `EggClimbWorld` folder in Workspace and the `EggClimbRemotes` folder in ReplicatedStorage. No manual RemoteEvent or BindableEvent setup is required.

## Use

1. Press Play in Roblox Studio.
2. Spawn on the lobby platform and follow the tower upward.
3. Use `WASD` or a thumbstick to move.
4. Press Space or use the jump button to jump between platforms.
5. Touch yellow checkpoint pads to record your latest reached checkpoint.
6. Avoid the red neon hazard bars. Touching one resets your character.
7. Reach the golden summit and touch the finish pad to receive 1 win and 100 coins.
8. Use the Unlocks panel to equip shell colors and trails when you have enough wins.
9. Reach higher floors to improve your progress and best-floor stat.
10. Test with multiple players to let several egg characters climb the tower together.

The project includes a generated lobby, 30 tower floors, colorful studded platforms, bridges, checkpoints, hazards, a summit, a finish pad, egg character visuals, persistent wins and coins, leaderstats, unlockable shells, unlockable trails, and a progress HUD.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/24d11082-805a-488f-b7d3-a31ce246585d?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=24d11082-805a-488f-b7d3-a31ce246585d
