# Checkmate, BOTS!

<img width="1153" height="648" alt="image" src="https://github.com/user-attachments/assets/27cdc6a8-8667-4529-a5d2-37b523d8bc64" />

## Project Resources

[Play our game here!](https://jasonzebra.itch.io/checkmate-bots)  
[Project Proposal](https://docs.google.com/document/d/1AQRiOCcK-6rzK5YfOf873bF-E6SQVYYs7HmX0FpdMPw/edit?usp=sharing)  
[Progress Report](https://docs.google.com/document/u/1/d/1C1UqoL5KXRPez0ZVUBrEyWd5p6MovFdbtlSrETRh8IY/edit)

## Summary

Checkmate, BOTS! is a chess-inspired tower defense where chess pieces clash against robots: you place towers with chess attack patterns, manage waves coming from all sides, and juggle economy and positioning to protect your king. Each piece feels true to its role—pawns push forward and promote, bishops sweep diagonals, rooks lock down lanes, knights strike from unexpected angles, and queens are flexible powerhouses. With escalating multi-directional assaults, it’s a fast, tactical spin on chess that rewards smart placements matching the enemies' behavior and moving pieces.

## Gameplay Explanation

To play, protect your King at the board center through 20 waves by placing chess-piece towers that keep their classic attack patterns. Use hotkeys to build: P for pawns (1 gold), K for knights (3), B for bishops (3), R for rooks (5), and Q for queens (9), then click a tile to place. There is also a drag and drop option if you prefer, right-click to cancel placement. Start the next wave with SPACE or by pressing the start wave button. Enter move mode with M to relocate a tower by clicking it and then a highlighted tile; right-click to exit or deselect—moves are limited each wave. There is a promotion system for pawns if they move 8 tiles in total, you can promote to any tower type. There is also no sell option to encourage moving pieces, if you misplace. Press ESC to pause and adjust audio; zoom with the mouse wheel and pan by right-dragging when not placing. Hover tooltips show tower stats and damage modifiers; the “Next” wave summary lists incoming enemies and directions.

The most optimal strategy is to survive the early game. Look at the where and what type of enemy is about to be spawned and place the best tower to deal it with it. Try to ration out your gold, by moving your pieces to defend other lanes during the waiting phase before a new wave. Allows you to make on-the-fly moves by placing necessary towers during a wave if time calls for it. You can try greeding by only moving a pawn around for a total 8 tiles, but that is probably only for really good placement of towers already. Try to place stronger towers on tiles that can cover the most effective range, so it can handle a lot of angles where enemies could come from.

**Add it here if you did work that should be factored into your grade but does not fit easily into the proscribed roles! Please include links to resources and descriptions of game-related material that does not fit into roles here.**

# External Code, Ideas, and Structure

Code
[Used the shield factory as a reference creating our enemy factory.](https://github.com/ensemble-ai/exercise-3-julin2900)

Sprites/Images
[Pixel UI & HUD by Dead Revolver](https://deadrevolver.itch.io/pixel-ui-hud-pack)
[Free Robot Warfare Pack by MattWalkden](https://mattwalkden.itch.io/free-robot-warfare-pack)
[Custom Border and Panels Menu All Part by BDragon1727](https://bdragon1727.itch.io/custom-border-and-panels-menu-all-part)
[Free Effect and Bullet 16x16 by BDragon1727](https://bdragon1727.itch.io/free-effect-and-bullet-16x16)
[Free CC0 Dungeon Backgrounds Pack by The Outlander](https://the-outlander.itch.io/free-cc0-dungeon-backgrounds-pack-15-05-24-10-43-26)
[Futuristic Anime Backgrounds V1 by Myriad Games](https://myriad-games.itch.io/futuristic-anime-backgrounds)
[Futuristic Anime Backgrounds V2 by Myriad Games](https://myriad-games.itch.io/futuristic-anime-backgrounds-v2)

Audio
[Dearly BGM](https://opengameart.org/content/%D0%B4%D0%BE%D1%80%D0%BE%D0%B3%D0%BE%D0%B9-dearly)
[Curious BGM](https://opengameart.org/content/curious)

# Team Member Contributions

-   [Jason Zhong](https://github.com/JasonZhong3): Level and World Designer + Narrative Design
-   [Justin Lin](https://github.com/julin2900): AI and Behavior Design + Audio, Added/Swapp over to Game Logic for main role
-   [Anson Tan](https://github.com/dzintt): Systems and Tools Engineer + Build and Release Manager
-   [Raymond Wu](https://github.com/Raymondwu21): User Interface and Input + Gameplay Testing
-   [Zijian Liu](https://github.com/escapistliu): Game Logic + Game Feel

This section be repeated once for each team member. Each team member should provide their name and GitHub user information.

## Jason Zhong

I was mainly in charge of the initial creation of the world and levels and lore behind our game. I really wanted to keep the game's chess theme and many of the basic mechanics of the game include some sort of chess-related twist to it. Within my roles, I created the map and levels, polished up the enemies and chess pieces, created a type charting, generated a simple backstory behind our game, and balanced the game such that players would probably have to play the game multiple times to learn strategies. Outside of my role, I also helped with preparing for the demo, outlining our general game, and sweeping our project to fix broken logic.

-   Main Role: Level and World Designer

    -   **Board Creation**  
        When coming up with the initial board, we knew we would be using chess boards, but the idea of how to place them and how many were unclear. However, after days of finalization, we decided to use four classic 8x8 chess boards with a cross intersection where the enemies would spawn from. In the middle of the cross, we had the "King" base where the player would try to defend. Because of the chess nature of our game, it is important we make sure the entire game board conforms to a GridSystem and everything in it would not step out of bounds. When implementing the [board](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/scripts/core/tile_board.gd), I made sure most of the details of the board were easily changeable, including number of tiles, size of tiles, and much more. There is also a clear differentiation between the cross where enemies would be in from the areas where players could place their chess pieces. Later on, I also implemented the enemy path to be a 2 tile cross rather than a one tile cross to make it more complex and allow for more strategies.

    -   **Initial Level Creation**  
        Another main mechanic of this game is the level or wave generation. Before I could start balancing the enemies and chess pieces, I needed an initial game where each wave progressively gets harder. Although the final version now uses a factory to create enemies, we originally had [10 static waves](https://github.com/dzintt/ecs-179-checkmate-bots/blob/9525602c9b9345b75ddb3e9b3495b25b4f40b55d/checkmate%2C-bots!/autoload/wave_manager.gd) that was the base point of how we balanced the enemy and chess piece stats. Enemies can spawn in from either North, East, South, or West and for each of those, they can spawn on the one of two tile lines. From there, they would walk straight to our base based on their speed.

    -   **Chess Piece Creation**
        Chess pieces are the most important thing in our game as they are the only things the player can control. I was in charge of creating the general chess pieces and stats, including their name, icon, damage, projectile speed (if applicable), attack pattern, and more. To do this, I started with a general [tower class](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/scripts/core/tower.gd) that all explicit chess pieces inherited. From there, I edited each chess piece based on the base class. The most important thing that the chess pieces must have is the attack pattern and how we can use that to detect enemies. To implement this, we had a Vector array that held the tile that they could possibly hit. From there, we had a seperate array for each piece that constantly checked if an Enemy type was in their attack pattern. For example, this is an implementation of our queen tower's implementation: [Queen Tower](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/scripts/towers/queen/queen_tower.gd)

    -   **Damage Engine**  
        To balance the game out, I also implemented a [damage engine](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/scripts/core/damage_engine.gd) that served as our type advantage. This was pretty easy to implement as we did this for a previous homework and I made it such that each chess piece was good at attacking a certain Enemy type. I also took in consideration about how some chess pieces are naturally better than others based on their attack pattern and our map layout. For example, the Rook was pretty useless as it could only target 4 tiles, which was the same as a Pawn if placed correctly.

    -   **Balancing**
        After getting our general mechanics of the game down, balancing was a serious issue as we found many issues when play testing. For example, the queen spamming was just too dominating because of the pure amount of tiles it could attack with its attack pattern. On the contrary, some pieces were far too weak as it either did too little damage or just wasn't useful at all due to its attack pattern. As a result, I created the damage engine as mentioned previously, and also adjusted the stats of many of the enemies and chess pieces: [Balance patch example](https://github.com/dzintt/ecs-179-checkmate-bots/pull/42). Some of the stats that were adjusted for chess pieces include: damage, projectile speed, and type advantages. It's important to note that I made sure to not change the cost of the chess pieces as it is the same as the point system in chess to ensure a nice game feel. For Enemy balance changes, some adjustments include: movement speed, health, damage to base, and additional effects. I also adjusted the map to include 2 lanes per cardinal direction as it made for more strategies and easy difficulty raises when generating waves.

-   Sub-role: Narrative Design
    -   **Cutscene**  
        The cutscene is the first thing that pops up when the player presses play. I wanted the player to not feel like they had to read an entire essay but I also wanted some lore to the game. The cutscene was initially very hard to start on because of the infinite number of stories that could occur. However, because of how chess and robots seem to be so far apart from each other in terms of time, I eventually thought of something to do with how two would clash in a sort of invader-like scenario. To implement the [cutscene](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/scripts/ui/cutscene.gd), I had an array of seperate [cutscene slides](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/scripts/ui/cutscene_slide.gd) that each had their own text and image. This way, people could dynamically add as many slides as they want and edit the text very easily. In addition, the cutscene has a [skip button](https://github.com/dzintt/ecs-179-checkmate-bots/blob/763ed15acfb2d4a9b1c2f9c7f0baa228ebeb29b0/checkmate%2C-bots!/scripts/ui/cutscene.gd#L13) if the player has already seen it.
-   Other contributions
    -   **Game Feel and Aesthetics**  
        To make this game feel more like chess, there are several mechanics of this game that are chess themed. One of them is how the chess pieces cost 1, 3, 3, 5, and 9, which are the points of the pawn, knight, bishop, rook, and queen respectively. In addition, the king base has a total of 39 health, which is the amount of points a player could have in chess: 8 pawns, 2 knights, 2 bishops, 2 rooks, and 1 queen.
    -   **Original Game Outline**  
        Before we even coded a single line in our game, I made a general game design document that highlights what I had in mind visually about the game. I used [Canva](https://www.canva.com/design/DAG3Z7x0kOQ/Cyu5us-YUtrQdJHfJeKGEA/edit?utm_content=DAG3Z7x0kOQ&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton) to create a simple game design document that included our board structure, damage engine, and initial ideas about the enemies and chess pieces.
-   **Preparing for demo**  
    To host our game to be web playable, I exported the game to a zip file and uploaded it to itch.io. I made sure that it ran smoothly on a PC and was also accessible through a phone. I also tested a bunch to ensure nothing would break during our demo.

## Anson Tan

I built the workflows and modular codebase structure that let the team ship fast: gdformat hooks and CI gates, protected main with required reviews, and documented pipelines so everyone could ship consistent, maintainable code. I also contributed to gameplay systems including placement previews with range and affordance, zoom/pan camera support, clearer projectiles, title screen setup, and the King health HUD keeping core modules reusable and readable for the whole team.

-   **Main Role:** Systems and Tools Engineer

    -   **Created Modular Codebase** - Initially our codebase was a mess, for instance, having all the scripts, scenes, and assets under 1 singular folder. To solve this, I defined a clear, modular project layout separating assets, scenes, scripts, dedicated UI, enemy, tower, and effects folders so the team could find things quickly and avoid tech debt. In addition, I created the initial core tower/enemy/system scaffolding so everyone had consistent foundations to build on. The structure below everything organized, which sped up collaboration and reduced cleanup work later. [The core structure](https://github.com/dzintt/ecs-179-checkmate-bots/pull/2):

    ```
    ecs-179-checkmate-bots/
    │
    │
    ├── .github/                          # GitHub configuration
    │   └── workflows/
    │
    ├── checkmate,-bots!/                 # Main Godot game project
    │   ├── assets/                       # Game assets
    │   │   ├── bgm/                      # Background music
    │   │   ├── enemies/                  # Enemy sprites/assets
    │   │   ├── fonts/                    # Font files
    │   │   ├── images/                   # General images
    │   │   ├── sound effects/            # Sound effect files
    │   │   ├── towers/                   # Tower sprites/assets
    │   │   └── ui/                       # UI assets
    │   │
    │   ├── autoload/                     # Godot autoload scripts
    │   │
    │   ├── resources/                    # Game resources
    │   │   ├── attack_patterns/          # Tower attack pattern definitions
    │   │   ├── cutscene/                 # Cutscene resources
    │   │   └── waves/                    # Enemy wave definitions
    │   │
    │   ├── scenes/                       # Godot scene files (.tscn)
    │   │   ├── effects/                  # Visual/audio effects
    │   │   ├── enemies/                  # Enemy scenes
    │   │   ├── main/                     # Main game scenes
    │   │   ├── projectiles/              # Projectile scenes
    │   │   └── towers/                   # Tower scenes
    │   │
    │   └── scripts/                      # GDScript files
    │       ├── core/                     # Core game logic
    │       ├── enemies/                  # Enemy behavior scripts
    │       ├── systems/                  # Game systems (spawning, pathfinding, etc.)
    │       ├── towers/                   # Tower behavior scripts
    │       └── ui/                       # UI controller scripts
    │
    ├── .gitignore                        # Git ignore rules
    ├── .pre-commit-config.yaml           # Pre-commit hooks configuration
    ├── ProjectDocument.md        # Project documentation
    └── README.md                         # Project readme
    ```

    -   **Implemented a team-wide GDScript standards pipeline:** Required gdformat via pre-commit so every .gd file is auto-formatted locally, and added a GitHub Actions workflow that installs gdtoolkit to check every PR. This kept code style consistent, reduced review churn, and prevented issues from slipping through; reviewers could focus on logic instead of spacing, and CI would flag issues before they reached main. [pre-commit script](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/.pre-commit-config.yaml) and [gdformat CI workflow](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/.github/workflows/gdformat.yml)

-   **Sub-role:** Build and Release Manager

    -   I protected our master branch by requiring PRs with at least one reviewer, personally reviewed every merge to block regressions, and routinely triaged or rejected risky changes to keep the branch stable. Some noteable issues prevented/code improvements from my reviews include: [Spawning logic isses](https://github.com/dzintt/ecs-179-checkmate-bots/pull/3#discussion_r2564223853), [Possible cause for crash](https://github.com/dzintt/ecs-179-checkmate-bots/pull/22#discussion_r2595673532), [Music played twice](https://github.com/dzintt/ecs-179-checkmate-bots/pull/22#discussion_r2595676378), [Refactor suggesions](https://github.com/dzintt/ecs-179-checkmate-bots/pull/23), [Bad descriptions](https://github.com/dzintt/ecs-179-checkmate-bots/pull/54), [Refactor suggestions](https://github.com/dzintt/ecs-179-checkmate-bots/pull/50), [Code cleanup](https://github.com/dzintt/ecs-179-checkmate-bots/pull/40)
    -   Helped with release and deployment to the web on [itch.io](https://jasonzebra.itch.io/checkmate-bots).

-   **Other contributions**
    -   **UX Improvements:**
        -   **Tower placement** – Added ghost towers previews and attack range overlays so players can see which tiles their towers will cover before placing them. [PR Here](https://github.com/dzintt/ecs-179-checkmate-bots/pull/30)
        -   **Board navigation** – Built a zoom and pan with smart disablement during placement to prevent misclicks which allowed players to zoom in and move the camera to focus on specific areas. [PR Here](https://github.com/dzintt/ecs-179-checkmate-bots/pull/37)
        -   **Cursor pointer on hover** - Small addition to make the cursor into a pointer when hovering over buttons to make it obvious for players that it is clickable. [PR Here](https://github.com/dzintt/ecs-179-checkmate-bots/pull/31)
    -   **UI Additions:**
        -   **King health HUD** – Designed and implemented the King HP bar end-to-end, making health state instantly legible. [PR Here](https://github.com/dzintt/ecs-179-checkmate-bots/pull/27)
        -   **Custom title screen image** - Added a "Start Wave" button as an alternative to pressing SPACE so mobile players could easily start the game. [PR Here](https://github.com/dzintt/ecs-179-checkmate-bots/pull/46)
        -   **Added the VT323 font, projectiles, and tower sprites** [PR Here](https://github.com/dzintt/ecs-179-checkmate-bots/pull/49) - Sourced and integrated tower, projectile, and UI sprites with a font that fits the game's theme.
        -   **Various minor UI changes:** [Transparent Background](https://github.com/dzintt/ecs-179-checkmate-bots/pull/53), [New Map Colors](https://github.com/dzintt/ecs-179-checkmate-bots/pull/33), [Move Start Wave Button](https://github.com/dzintt/ecs-179-checkmate-bots/pull/62)
    -   **Features**
        -   **Wave controls** – Created the wave-start logic and fixed accidental SPACE double-actions so starting a wave cannot re-enter placement, keeping game state coherent during wave transitions. [PR Here](https://github.com/dzintt/ecs-179-checkmate-bots/pull/34)
        -   **Projectile and attack feedback** – Implemented homing projectile lifecycle (speed, hit radius, lifetime, target validity) and integrated bounce FX on attacks for snappier feedback across chess pieces. [PR Here](https://github.com/dzintt/ecs-179-checkmate-bots/pull/25) and another related [PR Here](https://github.com/dzintt/ecs-179-checkmate-bots/pull/35)

## Justin Lin

**Main Role:** AI and Behavior Design + Game Logic

AI and Behavior Design Overview

Started as this, but realized that there isn’t that much to implement or do in a tower defense game for this type of role. We only had enemies to consider, unlike other games that have enemies/NPCs. The logic I came up with isn’t even considered AI as well, so I decided to partake in Game Logic as well. Here is a list of things that I did that can be pseudo-considered as AI and Behavior Design:

-   Enemy/NPC design & tuning: adjusted enemy stats/wave data and spawn logic via [enemy_factory.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/systems/enemy_factory.gd#L1) + [wave_manager.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blame/b2bcf12339bb388cff46ff0cbc897ef8d6391b1d/checkmate%2C-bots!/autoload/wave_manager.gd#L97), and difficulty tweaks based on the enemy factory.
-   Integration: enemies are wired into the loop (waves → spawns → damage/placement/grid → cleanup).
-   AI logic: Created spawn logic and post-wave behaviors; however, no dedicated FSM/BT/utility AI characteristics were implemented.

Game Logic Overview

-   Created initial skeleton of [towers](https://github.com/dzintt/ecs-179-checkmate-bots/blame/b2bcf12339bb388cff46ff0cbc897ef8d6391b1d/checkmate%2C-bots!/scripts/core/tower.gd#L1), [enemies](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/core/enemy.gd#L1), and [path manager](https://github.com/dzintt/ecs-179-checkmate-bots/blame/b2bcf12339bb388cff46ff0cbc897ef8d6391b1d/checkmate%2C-bots!/scripts/core/path_manager.gd#L1).
-   Central gameplay control in world_controller.gd: orchestrates wave start/stop, build vs. combat mode, tower interactions, enemy lifecycle, promotions, and UI hooks for tooltips/wave info.
-   Core systems: [wave_manager.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/autoload/wave_manager.gd#L68)(spawning waves), [promotion_system.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/systems/promotion_system.gd#L1)(pawn → higher-tier upgrade flow), [enemy_factory.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/systems/enemy_factory.gd#L1)(spawn queues and portals), [`placement_system.gd` + `grid_system.gd` (tile validation/occupancy)](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/systems/placement_system.gd#L144), [portal_effect.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/core/portal_effect.gd#L1) plus [damage-engine tweaks for effects/hits](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/core/damage_engine.gd#L57).

State & Flow

-   Wave lifecycle: [wave_manager.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/autoload/wave_manager.gd#L30) advances waves, handles cooldowns, and signals world_controller.gd to toggle modes; [enemy_factory.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/systems/enemy_factory.gd#L1) builds spawn queues per wave definition (types, counts, portals).
-   Scene sync: [world.tscn](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scenes/main/world.tscn#L52C28-L52C28) wires managers, background, hologram table, and portal spawn visuals so state changes appear in-scene.

Systems

-   Promotion System [(promotion_system.gd)](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/systems/promotion_system.gd#L1): tracks pawn move distance/eligibility and drives promotion selection; swaps in the chosen tower type to keep logic out of individual towers and the controller. Pawn promotion: movement threshold, promotion UI/selection, replacement of the pawn with the chosen tower.
-   Enemy Factory [(enemy_factory.gd)](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/systems/enemy_factory.gd#L1): constructs enemy queues from wave data, associates them with portal locations/directions, and feeds spawns to the wave manager; tracks currency hooks for reward flows.
-   Placement/Grid Rules [(placement_system.gd, grid_system.gd)](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/systems/placement_system.gd#L144): enforce in-bounds placement, prevent overlapping towers, and integrate with portal/board visuals; supports move-mode relocation. Post-wave move allowance: one reposition after each wave ends.
-   Pathing [(path_manager.gd)](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/core/path_manager.gd#L1): maintains path data for enemies, supplying routes used by spawns and ensuring placement doesn’t block critical lanes.

**Sub-role:** Audio
Overview

-   Expanded the audio layer via [sound_manager.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/autoload/sound_manager.gd#L1) to cover UI and gameplay cues (placement, hits, teleport, money pickup, defeat/victory, button hover) and ensured autoload availability across scenes. Integrated new SFX assets and imports for gameplay feedback and menu interactions.

Systems & Integration

-   sound_manager.gd: manages playback triggers for game/menu events and ties into autoload so UI and gameplay scripts can invoke sounds consistently.
-   UI/game hooks in [main_menu.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/ui/main_menu.gd#L9), [cutscene.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/ui/cutscene.gd#L120), and [world_controller.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/scripts/world_controller.gd#L42) to play appropriate SFX on menu actions, wave starts, placements, and hits.
-   Currency audio in [currency_manager.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/autoload/currency_manager.gd#L23) and wave timing in [wave_manager.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blame/db63b73cf301c1d1017aa9884c12d1b9b9e6669c/checkmate%2C-bots!/autoload/wave_manager.gd#L214) to align SFX with enemies spawing.

Assets Added

-   SFX: [button hover](https://github.com/dzintt/ecs-179-checkmate-bots/blob/BRANCH/checkmate%2C-bots!/assets/sound%20effects/button_hover.mp3), [tower placement](https://github.com/dzintt/ecs-179-checkmate-bots/blob/BRANCH/checkmate%2C-bots!/assets/sound%20effects/tower_placement.mp3), [metal clang/enemies hit](https://github.com/dzintt/ecs-179-checkmate-bots/blob/BRANCH/checkmate%2C-bots!/assets/sound%20effects/enemies_hit.mp3), [teleport](<(https://github.com/dzintt/ecs-179-checkmate-bots/blob/BRANCH/checkmate%2C-bots!/assets/sound%20effects/teleport.mp3)>), [money](https://github.com/dzintt/ecs-179-checkmate-bots/blob/BRANCH/checkmate%2C-bots!/assets/sound%20effects/money.mp3), [defeat](https://github.com/dzintt/ecs-179-checkmate-bots/blob/BRANCH/checkmate%2C-bots!/assets/sound%20effects/defeat.mp3), [victory](https://github.com/dzintt/ecs-179-checkmate-bots/blob/BRANCH/checkmate%2C-bots!/assets/sound%20effects/victory.mp3), [entering damage](https://github.com/dzintt/ecs-179-checkmate-bots/blob/BRANCH/checkmate%2C-bots!/assets/sound%20effects/entering_dmg.mp3), and [background music](https://github.com/dzintt/ecs-179-checkmate-bots/blob/BRANCH/checkmate%2C-bots!/assets/sound%20effects/curious.mp3).

**Other contributions:**

-   [Tooltip/UI support](https://github.com/dzintt/ecs-179-checkmate-bots/blame/5154ecf967b974b97a5f323cadad55915279a124/checkmate%2C-bots!/scripts/world_controller.gd#L2): tower panels show affordances/stats; world scene includes tooltip asset.
-   Finding visuals for background and animating tile highlight and promotion effect.

## Raymond Wu

I was in charge of creating the user interface of the game, and I handled the inputs of buttons. These features are a vital part of every game as it allows for the game to function and captures the audience’s attention. The style and font of the UI is critical to the look of the game as it helps the player navigate through the ins and outs of the game. I was focused on making sure the UI was clear, readable, and fit the theme of our game being pixelated chess and robots. The choice of font, spacing, layout, and button animations play a major role in how the game is presented.

-   **Main Role**: User Interface and Input

    -   **Main Menu**
        The Main Menu is the first thing the player sees when they open the game. There is the play button
    -   **Victory & Defeat Menu**
        The Victory Menu shows up when the player survives through all 20 waves successfully and shows a restart, return to main menu, and exit button. The restart button resets every value in the game back to their starting values like waves, king’s hp, and currency so the game is fresh and ensures no towers previously placed are still there nor enemies. The return to main menu also restarts the game but brings you back to the main menu. And the exit simply exits the game. There’s a freeze command that is implemented in both menu’s script that freezes the game where projectiles are frozen, enemies aren’t moving, and the players aren’t able to place towers or start the next wave.

    -   **Pause Menu**
        I didn’t completely create the pause menu, I collaborated with Justin Lin(audio), but I was involved in the finished product of rewiring the hierarchy in Godot and importing the UI style, font, and format. The Pause Menu is activated and deactivated through pressing esc and consists of the resume button that unpauses the game, return to main menu button that brings you back to the main menu resetting your progress, and the exit button that exits the game.

    -   **Tower Shop**
        The tower shop is where players are able to purchase towers with currency in order to play the game and survive as many waves as they can to beat the game. I implemented this through using Godot’s UI system, mainly inspector for building and nodes for buttons that trigger placement logic. Each tower button checks if the player has enough currency through attaching a script for that tower called pawn_panel or knight_panel, etc, and if so, it calls into the PlacementSystem to let the player place that tower onto the board. Whenever the player doesn’t have enough currency to buy the tower, the icon will gray out signifying that the user doesn’t have the sufficient funds.

-   **Sub Role**: Gameplay Testing
    In this role, I took part in playtesting the game after every PR on the main branch, I looked for exploits or bugs that shouldn’t be a part of the game and broke the rules. For example, I was able to catch that we were able to replace towers by placing the same or different towers on the same tiles thus wasting currency as there can only be one tower on one tile. I also noticed that you could place towers where you shouldn’t be allowed to like outside of the map or on the enemy tiles. I would then report what the issue was, where I think it’s coming from, and some ways we could fix it. I also made sure that the game was beatable, testing out strategies and notifying if there were balancing needed to be done like queen towers being too over powered.

    -   **Other Contributions**:
        Some other areas I helped around in were audio, images, fonts, sprites, and ideas. Although most weren’t a part of the final changes, I looked for background music, images for the background, fonts for the game, possible sprites for our towers and enemies, and ideas on how we can further develop our game. I also provided the team with resources like websites on where to get free sprites and free audio. To help with the organization of our files, and scripts I helped out by creating folders for specific purposes.

## Zijian Liu

In this project, my main role was working on the enemy side of the game and helping make the game easier to understand for new players. I implemented the five-enemy system (different stats and behaviors), set up and integrated the enemy sprites so each type is visually clear on the board, and created the How-To-Play tutorial that walks new players through the basic mechanics. I also helped tweak enemy values and behavior through playtesting so the overall difficulty felt more balanced and fun.

_Five Enemy System_ – I implemented five different enemy types (pawn, bomber, caster, loot runner, shielder) with their own stats and behaviors in GDScript. Each enemy knows how to move, take damage, and die inside the game loop, and plugs into the team’s existing spawn/path system. This connects to what we covered about game architecture, update loops, and using simple state machines for enemy behavior.  
[basic_pawn.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/scripts/enemies/basic_pawn.gd),
[bomber.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/scripts/enemies/bomber.gd),
[caster.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/scripts/enemies/caster.gd),
[loot_runner.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/scripts/enemies/loot_runner.gd),
[shielder.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/scripts/enemies/shielder.gd)

_How To Play Tutorial_ – I built the How To Play tutorial scene that walks new players through placing pieces, starting the game, and understanding how enemies go for the king. It’s a small guided flow that reacts to player actions. This relates to the course topics on UI/UX, state machines, and event-driven programming with signals.  
[how_to_play.gd](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/scenes/main/how_to_play.gd)

_Enemy Sprites & Readability_ – I chose, imported, and set up the enemy sprites so each enemy type looks different and lines up correctly on the board. The goal was to make it easy for players to quickly tell which enemy is which during gameplay. This ties into visual feedback, readability, and game feel from the course.  
[basic_pawn.png](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/assets/enemies/basic_pawn/basic_pawn.png),
[bomber.png](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/assets/enemies/bomber/bomber.png),
[caster.png](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/assets/enemies/caster/caster.png),
[loot_runner.png](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/assets/enemies/loot_runner/loot_runner.png),
[shielder.png](https://github.com/dzintt/ecs-179-checkmate-bots/blob/main/checkmate%2C-bots!/assets/enemies/shielder/shielder.png)
