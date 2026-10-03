# Survival-Game
 Godot-Engine Tutorial Survival Game

I'm following Devworm's tutorial on Youtube to learn game programming in Godot 4.2: https://www.youtube.com/playlist?list=PL3cGrGHvkwn2NOT1LSwf5d2XZmlc5Bjsn

Additionally, I implemented further improvements to my game:
- Main menu (start game, exit game, credits)
- Game over screen (shows total playing time)
- Keyboard layout (F1) - TODO: needs to be updated (inventory mouse buttons)
- All items are picked-up and put into inventory by pressing "E" (stick, water, slime, apple)
- Animated camp fire (stationary; TODO: player should build it from sticks in the inventory) - ignite with "F", doesn't do anything special currently
- Day/night, counting days in game (UI), different background sounds for day and night
- Health bar for player (UI) and slime enemy
- Spawner for sticks and slime: up to 100 sticks and slimes are placed over time randomly on free map tiles, 10 additional apple trees are also randomly positioned
- Player needs food and water: hunger and thirst bars (UI)
- Player gets thirsty and hungry over time, loses health if hunger or thirst bar gets empty
- Eat apple and drink water potions (apple gives +10 health and reduces hunger by 10 points, water reduces thirst by 10 points) until max health or max water is restored
- Shader on player: turns blinking red for 1 sec by a red shader attached to a wave-time function that could also be used for green (poisoning) or blue (thirst)
- Shooting arrows with the bow: player can level-up archery (Level 1-10; UI) and gets better with every level (arrows miss the enemy more often on lower levels, more hitpoints on higher levels)
- Arrows disappear when they hit the enemy
- Water areas: at the border of each lake the player can collect water potions
- Larger maps for World 1 and World 2 than in the original tutorial
- NPC house in World 2
- Music (OGG): LET'S ADVENTURE! by Sara Garrard (sonatina.itch.io)
- Sounds (MP3): arrow, slime hit, slime died, player puts item in inventory, player died
- Screen messages (hints, tutorial, e.g. which key to press...)
- New enemy: skeleton (with sounds: hit, laugh, die)
- New animal: frog (can't be killed) because frogs can be heard during background sounds
- New static item: chest (has own inventory with health potion)
- New item: health potion: restores health points to maximum (100)
- FPS counter (F12)
- Inventory from the original tutorial changed to GLoot (https://github.com/peter-kish/gloot)
- First quest prepared: Carl wants us to hunt some skeletons


PLANNED:
- Larger World
- NPC and quests
- More enemies (stronger, more health points)
- More sounds
- Credits on main menu (already prepared)
- Settings (screen size, audio volume, music on/off, difficulty)
- Player level (EXP)
- Simple crafting system (sticks -> arrows, sticks -> campfire, slime -> health potion...)
- Save/load game (main menu, inside the game)
- Better enemy AI: slimes should walk around and be more aggressive

KNOWN BUGS:
- After slime hit player it loses detection of the player and doesn't follow him
- Switching animation to NPC house (house not shown when animation finishes)
- When game over screen is shown, system time still counts and player dies again every ... seconds (game loop not stopped correctly)
