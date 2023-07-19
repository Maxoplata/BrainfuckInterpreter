#!/usr/bin/env python
"""
BrainfuckInterpreter.py

Interprets Brainfuck code.

example usage:

bf = BfInterpreter()
print(bf.interpret('++++++[>++++++++++<-]>+++++.'))

https://www.maxodev.org
https://github.com/Maxoplata/BrainfuckInterpreter
"""

import sys

__author__ = "Maxamilian Demian"
__email__ = "max@maxdemian.com"

class BfInterpreter:
	input = ''
	inputPointer = 0
	blocks = [0]
	pointer = 0
	output = ''

	def _updateBlockValue(self, increase = True):
		if increase:
			if self.blocks[self.pointer] == 255:
				self.blocks[self.pointer] = 0
			else:
				self.blocks[self.pointer] += 1
		else:
			if self.blocks[self.pointer] == 0:
				self.blocks[self.pointer] = 255
			else:
				self.blocks[self.pointer] -= 1

	def _updatePointer(self, increase = True):
		if increase:
			self.pointer += 1

			if self.pointer >= len(self.blocks):
				self.blocks.append(0)
		elif self.pointer > 0:
			self.pointer -= 1

	def _getPositionOfClosingBracket(self, chars):
		openBracketCount = 0

		for i, char in enumerate(chars):
			if char == '[':
				openBracketCount += 1
			elif char == ']':
				if openBracketCount > 0:
					openBracketCount -= 1
				else:
					return i

	def _handleLoop(self, chars):
		closingBracketPos = self._getPositionOfClosingBracket(chars)
		loopCodeChars = chars[:closingBracketPos]

		# the recursive call to _handleInterpret can change the value of self.pointer, so we need to put it in a new var first
		loopPointer = self.pointer

		while self.blocks[loopPointer] != 0:
			# we clone the loopCodeChars to get a new instance instead of passing by reference
			self._handleInterpret(loopCodeChars[:])

		return chars[(closingBracketPos + 1):]

	def _handleOutput(self):
		self.output += chr(self.blocks[self.pointer])

	def _handleInput(self):
		self.blocks[self.pointer] = ord(self.input[self.inputPointer])

		self.inputPointer += 1

	def _handleInterpret(self, chars):
		while len(chars) > 0:
			command = chars.pop(0)

			if command == '+':
				self._updateBlockValue()
			elif command == '-':
				self._updateBlockValue(False)
			elif command == '>':
				self._updatePointer()
			elif command == '<':
				self._updatePointer(False)
			elif command == '[':
				chars = self._handleLoop(chars)
			elif command == '.':
				self._handleOutput()
			elif command == ',':
				self._handleInput()

			# any other character is considered a comment

		return self.output

	def interpret(self, code = '', input = ''):
		self.input = input
		self.inputPointer = 0
		self.blocks = [0]
		self.pointer = 0
		self.output = ''

		return self._handleInterpret([char for char in code])
