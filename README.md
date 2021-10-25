# Chess-AI
A traditional chess engine built in bitboards. Features include
- Negamax searching
- Alpha-Beta pruning
- Zobrist hashing
- Time-contrained iterative deepening option
- A rough implementation of transposition tables (still contains bugs)
- An opening book

As few engines out there are written in Swift, the [Chess Programming Wiki](https://www.chessprogramming.org) was a significant resource to provide approaches in creating a chess AI. After discovering the site, the speed of searching jumped from 500k nodes per second (NPS) to 2,000k NPS (performance test, bulk counting disabled, evaluation not included). While this number could improve, my goal with the project (having fun!) was complete. 

The UI here is complete to an extent. To modify game participants, go to /UI/GameView
