# Tic-tac-toe written in Prolog

This program is the first larger dialogical logic program I've written.
It's describing a perfect play of tic-tac-toe.

Dialogical logic programming treats proof-search as a game-tree-search.
This can be used to write programs that refuse to interact
if it cannot be proven that there would be a desirable outcome.

The program is configured to do a perfect play, eg. Either a win or tie.
If you adjust the option of tie away, it refuses to play.
You may also loosen the constraints and you may make it to
prevent itself from winning or disregard the outcome.

I believe that the approach of building this kind of a program
can be generalised to arbitrary programs.

This program has been tested in SWI-Prolog.

## How to play

    ?- consult('tictactoe.pro').
    ?- play.

## Example gameplay

    ?- play.
    ...
    x..
    ...
    Available moves:[move(o,2,2),move(o,2,1),move(o,2,0),move(o,1,2),move(o,1,1),move(o,1,0),move(o,0,2),move(o,0,0)]
    Give your move:
    |: move(o, 1,1).
    ...
    xo.
    x..
    Available moves:[move(o,2,2),move(o,2,1),move(o,2,0),move(o,1,2),move(o,1,0),move(o,0,0)]
    Give your move:
    |: move(o, 0, 0).
    o..
    xo.
    x.x
    Available moves:[move(o,2,1),move(o,2,0),move(o,1,2),move(o,1,0)]
    Give your move:
    |: move(o, 2, 0).
    o.o
    xo.
    xxx
    I won. You lose.
    true.


    ?- play.
    ...
    ...
    ..x
    Available moves:[move(o,2,1),move(o,2,0),move(o,1,2),move(o,1,1),move(o,1,0),move(o,0,2),move(o,0,1),move(o,0,0)]
    Give your move:
    |: move(o,1,1).
    ..x
    .o.
    ..x
    Available moves:[move(o,2,1),move(o,1,2),move(o,1,0),move(o,0,2),move(o,0,1),move(o,0,0)]
    Give your move:
    |: move(o,2,1).
    ..x
    xoo
    ..x
    Available moves:[move(o,1,2),move(o,1,0),move(o,0,2),move(o,0,0)]
    Give your move:
    |: move(o,1,0).
    .ox
    xoo
    .xx
    Available moves:[move(o,0,2),move(o,0,0)]
    Give your move:
    |: move(o,0,2).
    xox
    xoo
    oxx
    It is a tie
    true.
