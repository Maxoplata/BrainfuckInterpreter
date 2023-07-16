#!/usr/bin/perl
#
# BrainfuckInterpreter.pl
#
# Interprets Brainfuck code.
#
# example usage
#
# my $bf = BfInterpreter->new;
# print $bf->interpret('++++++[>++++++++++<-]>+++++.');
#
# Author: Maxamilian Demian
#
# https://www.maxodev.org
# https://github.com/Maxoplata/BrainfuckInterpreter

use strict;
use warnings;

# package definition
{
	package BfInterpreter;

	sub new {
		my ($class, $args) = @_;

		my $self = bless {
			input => '',
			inputPointer => 0,
			blocks => [0],
			pointer => 0,
			output => '',
		}, $class;
	}

	sub _updateBlockValue {
		my ($self, $increase) = @_;

		if ($increase == 1) {
			if ($self->{blocks}[$self->{pointer}] == 255) {
				$self->{blocks}[$self->{pointer}] = 0;
			} else {
				$self->{blocks}[$self->{pointer}]++;
			}
		} else {
			if ($self->{blocks}[$self->{pointer}] == 0) {
				$self->{blocks}[$self->{pointer}] = 255;
			} else {
				$self->{blocks}[$self->{pointer}]--;
			}
		}
	}

	sub _updatePointer {
		my ($self, $increase) = @_;

		if ($increase == 1) {
			$self->{pointer}++;

			if (!defined $self->{blocks}[$self->{pointer}]) {
				$self->{blocks}[$self->{pointer}] = 0;
			}
		} elsif ($self->{pointer} > 0) {
			$self->{pointer}--;
		}
	}

	sub _getPositionOfClosingBracket {
		my ($self, @chars) = @_;

		my $openBracketCount = 0;

		for (my $i = 0; $i < scalar(@chars); $i++) {
			if ($chars[$i] eq '[') {
				$openBracketCount++;
			} elsif ($chars[$i] eq ']') {
				if ($openBracketCount > 0) {
					$openBracketCount--;
				} else {
					return $i;
				}
			}
		}
	}

	sub _handleLoop {
		my ($self, @chars) = @_;

		my $closingBracketPos = $self->_getPositionOfClosingBracket(@chars);
		my @loopCodeChars = @chars[0..($closingBracketPos - 1)];

		# the recursive call to $self->handleInterpret can change the value of $self->{pointer}, so we need to put it in a new var first
		my $loopPointer = $self->{pointer};

		while ($self->{blocks}[$loopPointer] != 0) {
			$self->handleInterpret(@loopCodeChars);
		}

		return @chars[($closingBracketPos + 1)..$#chars];
	}

	sub _handleOutput {
		my ($self) = @_;

		$self->{output} .= chr($self->{blocks}[$self->{pointer}]);
	}

	sub _handleInput {
		my ($self) = @_;

		$self->{blocks}[$self->{pointer}] = ord(substr($self->{input}, $self->{inputPointer}, 1));

		$self->{inputPointer}++;
	}

	sub handleInterpret {
		my ($self, @chars) = @_;

		while (scalar(@chars) > 0) {
			my $command = shift @chars;

			if ($command eq '+') {
				$self->_updateBlockValue(1);
			} elsif ($command eq '-') {
				$self->_updateBlockValue(0);
			} elsif ($command eq '>') {
				$self->_updatePointer(1);
			} elsif ($command eq '<') {
				$self->_updatePointer(0);
			} elsif ($command eq '[') {
				@chars = $self->_handleLoop(@chars);
			} elsif ($command eq '.') {
				$self->_handleOutput();
			} elsif ($command eq ',') {
				$self->_handleInput();
			}

			# any other character is considered a comment
		}

		return $self->{output};
	}

	sub interpret {
		my ($self, $code, $input) = @_;

		$code ||= '';
		$input ||= '';

		$self->{input} = $input;
		$self->{inputPointer} = 0;
		$self->{blocks} = [0];
		$self->{pointer} = 0;
		$self->{output} = '';

		return $self->handleInterpret(split('', $code));
	}
}
