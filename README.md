# Tic Tac Toe Bot

## Background

In this directory, there's a working tic-tac-toe game. It's written for two humans
sitting at the same terminal to play against each other. Give it a try now:

    ./play

The 'X' player always goes first. Players take turns choosing squares to put their mark
in. The columns are named 'a', 'b', and 'c' (left to right) and the rows are named '1',
'2', and '3' (top to bottom), so 'c1' is the top-left corner.

This is obviously the most fun you could possibly have with a friend. But what if you
don't have a friend to play with? Fortunately, this program uses a command-line
interface, so we ought to be able to design and plug in an AI opponent without needing to
modify the original game.

In fact, such an AI has already been written. It's tragically named "idiot.pl", as it
isn't very clever. Try giving it control of the 'O' player and see if you can beat it:

    ./play -o bots/idiot.pl

Or, for extra entertainment value, pit two idiots against each other:

    ./play -x bots/idiot.pl -o bots/idiot.pl --print-outcome

## The Problem

Program a better bot without making changes to the main game's code.

This will involve two main challenges:
1. figure out how to get the information you need from the game's output, and
2. implement some kind of game strategy

Take a look at the code in idiot.pl to get a basic idea of where to start, but feel free
to write your bot in any available language that you prefer.

As a minimal goal, in a competition against idiot.pl, your bot should win more often than
it loses. As a more impressive goal, it should be able to always play to a win or draw
against any opponent, whether it starts first or second.

Also, once you have a working bot, make sure you merge your code back into the main
github repo so other teams can try it out against their bots.

## Notes

The game code is implemented in ruby. It should work with either ruby 1.8 or 1.9, which
is installed on the dev machine systems. You should also be able to do this exercise in
any other environment with an appropriate ruby installation (and perl for idiot.pl).