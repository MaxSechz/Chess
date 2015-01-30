#Terminal Chess

This is the classic board game for the terminal written in Ruby!
It can be played between two human opponents, a human and a computer, or even a computer against another computer.
Comes complete with several AI classes to choose from. They range in competence from completely useless, to only mildly useless.
AI number 7, or the "Smartest AI" is the most advanced and can beat (or draw in the case of the Greedy AI, which will always try to get a draw) all the other AIs, including itself.
They each apply slightly different heuristics to their move selection. Random Computer selects moves entirely at random.
Checkmate Computer does the same, but will checkmate if possible. Safe Computer will also checkmate if possible, and will never move its own pieces into danger for any reason.
Control Computer will attempt to gain the most board control, that is have immediate access to as many squares as possible.
Greedy Computer will only move to capture. Smartest Computer is a combination of Control and Greedy Computers.
It will first find the moves with the greatest (safe) capture potential, and of those, find the move with the greatest board control.

###Usage

After cloning the repo (or downloading the zip and extracting the files), run 'ruby chess.rb' in the chess directory.
You will be prompted if you would like to load a file. If you do not load a saved game you will then be prompted to enter a number corresponding to each player's class (1 for humans and 2-7 for computers).
Each turn you may elect to save the game at that point.
During your turn you will be prompted for a starting position and an ending position in algebraic chess notation i.e. a2, h4, c8, etc.

###Features
- Graphical interface with unicode representations of chess pieces.
- Saving and loading of game state, including the current player.
- Error handling and rejection of invalid/illegal moves.
- The user is allowed to choose again after making an invalid move (ex: trying to castle inappropriately).
- You cannot move into check.
- You can castle when conditions permit.
- You can promote your pawns if they hit the end of the board. Computers will always choose a queen (as should you).
- All pieces inherit from sliding or stepping piece classes in order to keep code DRY.
- Multiple AI classes using different heuristics to determine behavior.
