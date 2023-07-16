/**
 * BrainfuckInterpreter.js
 *
 * Interprets Brainfuck code.
 *
 * example usage:
 *
 * const bf = new BfInterpreter();
 * console.log(bf.interpret('++++++[>++++++++++<-]>+++++.'));
 *
 * @author Maxamilian Demian <max@maxdemian.com>
 * @link https://www.maxodev.org
 * @link https://github.com/Maxoplata/BrainfuckInterpreter
 */

class BfInterpreter {
	#updateBlockValue(increase = true) {
		if (increase) {
			if (this.blocks[this.pointer] === 255) {
				this.blocks[this.pointer] = 0;
			} else {
				this.blocks[this.pointer]++;
			}
		} else {
			if (this.blocks[this.pointer] === 0) {
				this.blocks[this.pointer] = 255;
			} else {
				this.blocks[this.pointer]--;
			}
		}
	}

	#updatePointer(increase = true) {
		if (increase) {
			this.pointer++;

			if (typeof this.blocks[this.pointer] === 'undefined') {
				this.blocks[this.pointer] = 0;
			}
		} else if (this.pointer > 0) {
			this.pointer--;
		}
	}

	#getPositionOfClosingBracket(chars) {
		let openBracketCount = 0;

		for (let i = 0; i < chars.length; i++) {
			if (chars[i] === '[') {
				openBracketCount++;
			} else if (chars[i] === ']') {
				if (openBracketCount > 0) {
					openBracketCount--;
				} else {
					return i;
				}
			}
		}
	}

	#handleLoop(chars) {
		const closingBracketPos = this.#getPositionOfClosingBracket(chars);
		const loopCodeChars = chars.slice(0, closingBracketPos);

		// the recursive call to this.#handleInterpret can change the value of this.pointer, so we need to put it in a new var first
		const loopPointer = this.pointer;

		while (this.blocks[loopPointer] !== 0) {
			// we spread the loopCodeChars into a new array to get a new instance instead of passing by reference
			this.#handleInterpret([...loopCodeChars]);
		}

		return chars.slice(closingBracketPos + 1);
	}

	#handleOutput() {
		this.output += String.fromCharCode(this.blocks[this.pointer]);
	}

	#handleInput() {
		this.blocks[this.pointer] = this.input.charCodeAt(this.inputPointer);

		this.inputPointer++;
	}

	#handleInterpret(chars) {
		while (chars.length) {
			let command = chars.shift();

			switch(command) {
				case '+':
					this.#updateBlockValue();

					break;
				case '-':
					this.#updateBlockValue(false);

					break;
				case '>':
					this.#updatePointer();

					break;
				case '<':
					this.#updatePointer(false);

					break;
				case '[':
					chars = this.#handleLoop(chars);

					break;
				case '.':
					this.#handleOutput();

					break;
				case ',':
					this.#handleInput();

					break;
				default:
					// any other character is considered a comment
			}
		}

		return this.output;
	}

	interpret(code = '', input = '') {
		this.input = input;
		this.inputPointer = 0;
		this.blocks = [0];
		this.pointer = 0;
		this.output = '';

		return this.#handleInterpret(code.split(''));
	}
}
