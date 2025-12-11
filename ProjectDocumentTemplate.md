# The title of your game #

## Summary ##

Checkmate Bots is a chess-inspired tower defense where chess pieces clashes against robots: you place towers with chess attack patterns, manage waves coming from all sides, and juggle economy and positioning to protect your king. Each piece feels true to its role—pawns push forward and promote, bishops sweep diagonals, rooks lock down lanes, knights strike from unexpected angles, and queens are flexible powerhouse. With escalating multi-directional assaults, it’s a fast, tactical spin on chess that rewards smart placements matching the enemies' behavior and moving pieces.

## Project Resources

[Web-playable version of your game.](https://itch.io/)  
[Trailor](https://youtube.com)  
[Press Kit](https://dopresskit.com/)  
[Proposal: make your own copy of the linked doc.](https://docs.google.com/document/d/1AQRiOCcK-6rzK5YfOf873bF-E6SQVYYs7HmX0FpdMPw/edit?usp=sharing)  

## Gameplay Explanation ##

To play, protect your King at the board center through 20 waves by placing chess-piece towers that keep their classic attack patterns. Use hotkeys to build: P for pawns (1 gold), K for knights (3), B for bishops (3), R for rooks (5), and Q for queens (9), then click a tile to place. There is also a drag and drop option if you prefer, right-click to cancel placement. Start the next wave with SPACE or by pressing the start wave button. Enter move mode with M to relocate a tower by clicking it and then a highlighted tile; right-click to exit or deselect—moves are limited each wave. There is a promotion system for pawns if they move 8 tiles in total, you can promote to any tower type. There is also no sell option to encourage moving pieces, if you misplace. Press ESC to pause and adjust audio; zoom with the mouse wheel and pan by right-dragging when not placing. Hover tooltips show tower stats and damage modifiers; the “Next” wave summary lists incoming enemies and directions.

The most optimal strategy is to survive the early game. Look at the where and what type of enemy is about to be spawned and place the best tower to deal it with it. Try to ration out your gold, by moving your pieces to defend other lanes during the waiting phase before a new wave. Allows you to make on-the-fly moves by placing necessary towers during a wave if time calls for it. You can try greeding by only moving a pawn around for a total 8 tiles, but that is probably only for really good placement of towers already. Try to place stronger towers on tiles that can cover the most effective range, so it can handle a lot of angles where enemies could come from. 


**Add it here if you did work that should be factored into your grade but does not fit easily into the proscribed roles! Please include links to resources and descriptions of game-related material that does not fit into roles here.**

# External Code, Ideas, and Structure #

If your project contains code that: 1) your team did not write, and 2) does not fit cleanly into a role, please document it in this section. Please include the author of the code, where to find the code, and note which scripts, folders, or other files that comprise the external contribution. Additionally, include the license for the external code that permits you to use it. You do not need to include the license for code provided by the instruction team.

If you used tutorials or other intellectual guidance to create aspects of your project, include reference to that information as well.

[Used the shield factory as a reference creating our enemy factory.](https://github.com/ensemble-ai/exercise-3-julin2900)  

# Team Member Contributions

This section be repeated once for each team member. Each team member should provide their name and GitHub user information.

The general structures is 
```
Team Member 1
  Main Role
    Documentation for main role.
  Sub-Role
    Documentation for Sub-Role
  Other contribtions
    Documentation for contributions to the project outside of the main and sub roles.

Team Member 2
  Main Role
    Documentation for main role.
  Sub-Role
    Documentation for Sub-Role
  Other contribtions
    Documentation for contributions to the project outside of the main and sub roles.
...
```

For each team member, you shoudl work of your role and sub-role in terms of the content of the course. Please look at the role sections below for specific instructions for each role.

Below is a template for you to highlight items of your work. These provide the evidence needed for your work to be evaluated. Try to have at least four such descriptions. They will be assessed on the quality of the underlying system and how they are linked to course content. 

*Short Description* - Long description of your work item that includes how it is relevant to topics discussed in class. [link to evidence in your repository](https://github.com/dr-jam/ECS189L/edit/project-description/ProjectDocumentTemplate.md)

Here is an example:  
*Procedural Terrain* - The game's background consists of procedurally generated terrain produced with Perlin noise. The game can modify this terrain at run-time via a call to its script methods. The intent is to allow the player to modify the terrain. This system is based on the component design pattern and the procedural content generation portions of the course. [The PCG terrain generation script](https://github.com/dr-jam/CameraControlExercise/blob/513b927e87fc686fe627bf7d4ff6ff841cf34e9f/Obscura/Assets/Scripts/TerrainGenerator.cs#L6).

You should replay any **bold text** with your relevant information. Liberally use the template when necessary and appropriate.

Add addition contributions int he Other Contributions section.

## Main Roles ##

## Sub-Roles ##

## Other Contributions ##
