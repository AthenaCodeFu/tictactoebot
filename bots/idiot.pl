#!/usr/local/bin/perl

# idiot.pl
#
# This is about the simplest tic tac toe bot possible. It makes no attempt to understand
# the game's state - it just offers a random space on the board every time the server
# asks for a move. If the space happens to already be occupied, the game will simply
# prompt it for a new move. Eventually, this bot is bound to stumble on a legal move!

use strict;
use warnings;

# Make sure you flush your output, or things will likely deadlock!
use IO::Handle;
STDOUT->autoflush(1);

# these are the nine possible moves - one for each square on the board
my @moves = qw( a1 a2 a3 b1 b2 b3 c1 c2 c3 );

# run until the tic tac toe server stops talking
while (my $message = <>) {

	# ignore everything the server says until it asks "what is your move?"
	next unless $message =~ /what is your move/;

	# pick a random move
	my $move = $moves[ int( rand( scalar @moves ) ) ];

	# send that move back to the server
	print "$move\n";

}
