# chess-game
♟️ Chess Game in Pascal
📌 Overview

This project is a console-based Chess game implemented in Pascal.
It was developed as a programming project to practice modular programming, data structures, and game logic implementation.

The program allows players to start a new game, play chess according to the official rules, and save or reload a game.

The project follows a modular architecture, separating the game logic into multiple units for better readability and maintainability.

🎮 Features

Play a two-player chess game in the console

Implementation of legal chess moves

Detection of check and checkmate

Game state management

Save and load a game

Clear console interface

🧩 Project Structure
Chess-Pascal
│
├── Echecs_main.pas           # Main program
│
├── uTypesEchecs.pas          # Definitions of chess types and structures
├── uPlateauEtPieces.pas      # Board and pieces management
├── uReglesDeplacement.pas    # Movement rules for pieces
├── uMouvementsEchecs.pas     # Move validation and execution
├── uEchecEtMat.pas           # Check and checkmate detection
├── uGestionPartie.pas        # Game flow management
├── uSauvegardeEchecs.pas     # Save and load game system
└── uIHMConsole.pas           # Console interface and display
⚙️ Technologies Used

Pascal (FreePascal / Lazarus compatible)

Console interface

Modular programming using Pascal units

Concepts used in this project:

structured programming

modular design

game state management

file handling

algorithmic rule checking

▶️ How to Run
1️⃣ Compile the program

Using FreePascal:

fpc Echecs_main.pas
2️⃣ Run the program
./Echecs_main
🕹️ Game Menu

When launching the program:

1 - Nouvelle partie
2 - Reprendre la derniere partie sauvegardee
0 - Quitter

1 → start a new game

2 → load the last saved game

0 → exit the program

💾 Save System

The game can store the current state into a file:

sauvegarde.dat

This allows players to resume a previously saved game.

📚 Learning Objectives

This project was designed to practice:

Pascal modular programming

data structure design

algorithm implementation

game logic modeling

code organization in large programs



Student project developed at INSA Rouen Normandie.

Author: An Vu
