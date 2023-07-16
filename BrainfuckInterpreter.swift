#!/usr/bin/swift
/**
 * BrainfuckInterpreter.swift
 *
 * Interprets Brainfuck code.
 *
 * example usage:
 *
 * let bf = BfInterpreter()
 * print(bf.interpret("++++++[>++++++++++<-]>+++++."))
 *
 * @author Maxamilian Demian <max@maxdemian.com>
 * @link https://www.maxodev.org
 * @link https://github.com/Maxoplata/StringToINTERCAL
 */

class BfInterpreter {
	var input: String = ""
	var inputPointer: Int = 0
	var blocks: [Int] = [0]
	var pointer: Int = 0
	var output: String = ""

	func updateBlockValue(_ increase: Bool = true) -> Void {
		if increase {
			if blocks[pointer] == 255 {
				blocks[pointer] = 0
			} else {
				blocks[pointer] += 1
			}
		} else {
			if blocks[pointer] == 0 {
				blocks[pointer] = 255
			} else {
				blocks[pointer] -= 1
			}
		}
	}

	func updatePointer(_ increase: Bool = true) -> Void {
		if increase {
			pointer += 1

			if !blocks.indices.contains(pointer) {
				blocks.append(0)
			}
		} else if pointer > 0 {
			pointer -= 1
		}
	}

	func getPositionOfClosingBracket(_ chars: [Character]) -> Int {
		var openBracketCount: Int = 0

		for (i, char) in chars.enumerated() {
			if char == "[" {
				openBracketCount += 1
			} else if char == "]" {
				if openBracketCount > 0 {
					openBracketCount -= 1
				} else {
					return i
				}
			}
		}

		// if we get here, there is no closing bracket, but an Int return is required
		return 0
	}

	func handleLoop(_ chars: [Character]) -> [Character] {
		let closingBracketPos: Int = getPositionOfClosingBracket(chars)
		let loopCodeChars: [Character] = Array(chars.prefix(closingBracketPos))

		// the recursive call to handleInterpret can change the value of pointer, so we need to put it in a new var first
		let loopPointer = pointer

		while blocks[loopPointer] != 0 {
			// we clone the loopCodeChars to get a new instance instead of passing by reference
			// adding "let _ = " to suppress unused return warning
			let _ = handleInterpret([] + loopCodeChars)
		}

		return Array(chars.suffix(from: closingBracketPos + 1))
	}

	func handleOutput() -> Void {
		output += String(UnicodeScalar(blocks[pointer])!)
	}

	func handleInput() -> Void {
		blocks[pointer] = Int(input[input.index(input.startIndex, offsetBy: inputPointer)].asciiValue!)

		inputPointer += 1
	}

	func handleInterpret(_ chars: [Character]) -> String {
		// chars is a let constant, but we need to modify it
		var modifiedChars = chars

		while modifiedChars.count > 0 {
			let command = modifiedChars.removeFirst()

			switch command {
				case "+":
					updateBlockValue()
				case "-":
					updateBlockValue(false)
				case ">":
					updatePointer()
				case "<":
					updatePointer(false)
				case "[":
					modifiedChars = handleLoop(modifiedChars)
				case ".":
					handleOutput()
				case ",":
					handleInput()
				default:
					// any other character is considered a comment
					// this is here to get rid of the note for no default and warning for no default executable statement
					modifiedChars = Array(modifiedChars)
			}
		}

		return output
	}

	func interpret(_ code: String) -> String {
		input = code
		inputPointer = 0
		blocks = [0]
		pointer = 0
		output = ""

		return handleInterpret(Array(code))
	}
}
