play :- my_turn([]).

my_turn(Game) :-
    valid_moves(ValidMoves, Game, x),
    any_valid_moves(ValidMoves, Game).

any_valid_moves([], _) :-
    write('It is a tie'), nl.
any_valid_moves([_|_], Game) :-
    findall(NextMove, game_analysis(x, Game, NextMove), MyMoves),
    do_a_decision(MyMoves, Game).

% This can only fail in the beginning.
do_a_decision(MyMoves, Game) :-
    not(MyMoves = []),
    length(MyMoves, MaxMove),
    random(0, MaxMove, ChosenMove),
    nth0(ChosenMove, MyMoves, X),
    NextGame = [X | Game],
    print_game(NextGame),
    (victory_condition(x, NextGame) ->
        (write('I won. You lose.'), nl);
        your_turn(NextGame), !).

your_turn(Game) :-
    valid_moves(ValidMoves, Game, o),
    (ValidMoves = [] -> (write('It is a tie'), nl);
     (write('Available moves:'), write(ValidMoves), nl,
      ask_move(Y, ValidMoves),
      NextGame = [Y | Game],
      (victory_condition(o, NextGame) ->
        (write('I lose. You win.'), nl);
        my_turn(NextGame), !))).

ask_move(Move, ValidMoves) :-
    write('Give your move:'), nl,
    read(Move), member(Move, ValidMoves), !.

ask_move(Y, ValidMoves) :-
    write('not a move'), nl, 
    ask_move(Y, ValidMoves).

movement_prompt(X, Y, ValidMoves) :-
    write('Give your X:'), nl, read(X), member(move(o, X, Y), ValidMoves), !,
    write('Give your Y:'), nl, read(Y), member(move(o, X, Y), ValidMoves).

% A routine for printing games.. Well you can use it.
print_game(Game) :-
    plot_row(0, Game), plot_row(1, Game), plot_row(2, Game).

plot_row(Y, Game) :-
    plot(Game, 0, Y), plot(Game, 1, Y), plot(Game, 2, Y), nl.

plot(Game, X, Y) :-
    (member(move(P, X, Y), Game), ground(P)) -> write(P) ; write('.').

% This system determines whether there's a perfect play available.
game_analysis(_, Game, _) :-
    victory_condition(Winner, Game),
    Winner = x. % We do not want to lose.
    % Winner = o. % We do not want to win. (egostroking mode).
    % true. % If you remove this constraint entirely, it may let you win.
game_analysis(Turn, Game, NextMove) :-
    not(victory_condition(_, Game)),
    game_analysis_continue(Turn, Game, NextMove).

game_analysis_continue(Turn, Game, NextMove) :-
    valid_moves(Moves, Game, Turn),
    game_analysis_search(Moves, Turn, Game, NextMove).

% Comment these away and the system refuses to play,
% because there are no ways to play this without a possibility of tie.
game_analysis_search([], o, _, _). % Tie on opponent's turn.
game_analysis_search([], x, _, _). % Tie on our turn.

game_analysis_search([X|Z], o, Game, NextMove) :- % Whatever opponent does,
    NextGame = [X | Game],                        % we desire not to lose.
    game_analysis_search(Z, o, Game, NextMove),
    game_analysis(x, NextGame, _), !.

game_analysis_search(Moves, x, Game, NextMove) :-
    game_analysis_search_x(Moves, Game, NextMove).

game_analysis_search_x([X|_], Game, X) :-
    NextGame = [X | Game],
    game_analysis(o, NextGame, _).
game_analysis_search_x([_|Z], Game, NextMove) :-
    game_analysis_search_x(Z, Game, NextMove).

% This thing describes all kinds of valid games.
valid_game(Turn, Game, LastGame, Result) :-
    victory_condition(Winner, Game) ->
        (Game = LastGame, Result = win(Winner)) ;
        valid_continuing_game(Turn, Game, LastGame, Result).

valid_continuing_game(Turn, Game, LastGame, Result) :-
    valid_moves(Moves, Game, Turn),
    tie_or_next_game(Moves, Turn, Game, LastGame, Result).

tie_or_next_game([], _, Game, Game, tie).
tie_or_next_game(Moves, Turn, Game, LastGame, Result) :-
    valid_gameplay_move(Moves, NextGame, Game),
    opponent(Turn, NextTurn),
    valid_game(NextTurn, NextGame, LastGame, Result).

% Victory conditions for tic tac toe.
victory(P, Game, Begin) :-
    valid_gameplay(Game, Begin),
    victory_condition(P, Game).

victory_condition(P, Game) :-
    (X = 0; X = 1; X = 2),
    member(move(P, X, 0), Game),
    member(move(P, X, 1), Game),
    member(move(P, X, 2), Game).

victory_condition(P, Game) :-
    (Y = 0; Y = 1; Y = 2),
    member(move(P, 0, Y), Game),
    member(move(P, 1, Y), Game),
    member(move(P, 2, Y), Game).
 
victory_condition(P, Game) :-
    member(move(P, 0, 2), Game),
    member(move(P, 1, 1), Game),
    member(move(P, 2, 0), Game).
 
victory_condition(P, Game) :-
    member(move(P, 0, 0), Game),
    member(move(P, 1, 1), Game),
    member(move(P, 2, 2), Game).

% This describes a valid form of gameplay.
% Which player did the move is disregarded.
valid_gameplay(Start, Start).

valid_gameplay(Game, Start) :-
    valid_gameplay(PreviousGame, Start),
    valid_moves(Moves, PreviousGame, _),
    valid_gameplay_move(Moves, Game, PreviousGame).

valid_gameplay_move([X|_], [X|PreviousGame], PreviousGame).
valid_gameplay_move([_|Z], Game, PreviousGame) :-
    valid_gameplay_move(Z, Game, PreviousGame).

% The set of valid moves must not be affected by the decision making
% of the prolog interpreter.
% Therefore we have to retrieve them like this.
% This is equivalent to the (∀x∈0..2)(∀y∈0..2)(....
% uh wait.. There's no way to represent this using those quantifiers.
valid_moves(Moves, Game, Turn) :-
    valid_moves_column(0, M1,    [], Game, Turn),
    valid_moves_column(1, M2,    M1, Game, Turn),
    valid_moves_column(2, Moves, M2, Game, Turn).

valid_moves_column(X, M3, M0, Game, Turn) :-
    valid_moves_cell(X, 0, M1, M0, Game, Turn),
    valid_moves_cell(X, 1, M2, M1, Game, Turn),
    valid_moves_cell(X, 2, M3, M2, Game, Turn).

valid_moves_cell(X, Y, M1, M0, Game, Turn) :-
    member(move(_, X, Y), Game) -> M0 = M1 ; M1 = [move(Turn,X,Y) | M0].

% valid_move(X, Y, Game) :-
%     (X = 0; X = 1; X = 2),
%     (Y = 0; Y = 1; Y = 2),
%     not(member(move(_, X, Y), Game)).

opponent(x, o).
opponent(o, x).
