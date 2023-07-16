#!/usr/bin/ruby
# BrainfuckInterpreter.rb
#
# Interprets Brainfuck code.
#
# example usage:
#
# bf = BfInterpreter.new
# puts bf.interpret('++++++[>++++++++++<-]>+++++.')
#
# @author Maxamilian Demian
# @link https://www.maxodev.org
# @link https://github.com/Maxoplata/BrainfuckInterpreter

class BfInterpreter
	def interpret(code = '', input = '')
		@input = input
		@inputPointer = 0
		@blocks = [0]
		@pointer = 0
		@output = ''

		return handleInterpret(code.split(''))
	end

	private

	def updateBlockValue(increase = true)
		if increase
			if @blocks[@pointer] == 255
				@blocks[@pointer] = 0
			else
				@blocks[@pointer] += 1
			end
		else
			if @blocks[@pointer] == 0
				@blocks[@pointer] = 255
			else
				@blocks[@pointer] -= 1
			end
		end
	end

	def updatePointer(increase = true)
		if increase
			@pointer += 1

			if @blocks[@pointer].nil?
				@blocks[@pointer] = 0
			end
		elsif @pointer > 0
			@pointer -= 1
		end
	end

	def getPositionOfClosingBracket(chars)
		openBracketCount = 0

		chars.each_with_index do |char, i|
			if char == '['
				openBracketCount += 1
			elsif char == ']'
				if openBracketCount > 0
					openBracketCount -= 1
				else
					return i
				end
			end
		end
	end

	def handleLoop(chars)
		closingBracketPos = getPositionOfClosingBracket(chars)
		loopCodeChars = chars[0...closingBracketPos]

		# the recursive call to handleInterpret can change the value of @pointer, so we need to put it in a new var first
		loopPointer = @pointer

		while @blocks[loopPointer] != 0
			# we clone the loopCodeChars to get a new instance instead of passing by reference
			handleInterpret(loopCodeChars.clone)
		end

		return chars[(closingBracketPos + 1)..-1]
	end

	def handleOutput()
		@output += @blocks[@pointer].chr
	end

	def handleInput()
		@blocks[@pointer] = @input[@inputPointer].ord

		@inputPointer += 1
	end

	def handleInterpret(chars)
		while chars.length > 0
			command = chars.shift

			case command
				when '+'
					updateBlockValue()
				when '-'
					updateBlockValue(false)
				when '>'
					updatePointer()
				when '<'
					updatePointer(false)
				when '['
					chars = handleLoop(chars)
				when '.'
					handleOutput()
				when ','
					handleInput()
				else
					# any other character is considered a comment
			end
		end

		return @output
	end
end
