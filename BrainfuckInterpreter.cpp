/**
 * BrainfuckInterpreter.cpp
 *
 * Interprets Brainfuck code.
 *
 * example usage:
 * 
 * BfInterpreter bf;
 * std::cout << bf.interpret("++++++[>++++++++++<-]>+++++.");
 *
 * @author Maxamilian Demian
 * @link https://www.maxodev.org
 * @link https://github.com/Maxoplata/BrainfuckInterpreter
 */
#include <iostream>

class BfInterpreter {
	private:
		std::string input;
		int inputPointer;
		std::vector<int> blocks;
		int pointer;
		std::string output;

		void updateBlockValue(bool increase = true) {
			if (increase) {
				if (blocks[pointer] == 255) {
					blocks[pointer] = 0;
				} else {
					blocks[pointer]++;
				}
			} else {
				if (blocks[pointer] == 0) {
					blocks[pointer] = 255;
				} else {
					blocks[pointer]--;
				}
			}
		}

		void updatePointer(bool increase = true) {
			if (increase) {
				pointer++;

				if (pointer >= blocks.size()) {
					blocks.push_back(0);
				}
			} else if (pointer > 0) {
				pointer--;
			}
		}

		int getPositionOfClosingBracket(std::vector<char> chars) {
			int openBracketCount = 0;

			for (size_t i = 0; i < chars.size(); i++) {
				if (chars[i] == '[') {
					openBracketCount++;
				} else if (chars[i] == ']') {
					if (openBracketCount > 0) {
						openBracketCount--;
					} else {
						return i;
					}
				}
			}

			// if we get here, there is no closing bracket, but an int return is required
			return 0;
		}

		std::vector<char> handleLoop(std::vector<char> chars) {
			int closingBracketPos = getPositionOfClosingBracket(chars);

			std::vector<char> loopCodeChars;
			for (size_t i = 0; i < closingBracketPos; i++) {
				loopCodeChars.push_back(chars[i]);
			}

			// the recursive call to handleInterpret can change the value of pointer, so we need to put it in a new var first
			int loopPointer(pointer);

			while (blocks[loopPointer] != 0) {
				handleInterpret(loopCodeChars);
			}

			std::vector<char> retChars;
			for (size_t i = (closingBracketPos + 1); i < chars.size(); i++) {
				retChars.push_back(chars[i]);
			}

			return retChars;
		}

		void handleOutput() {
			output += static_cast<char>(blocks[pointer]);
		}

		void handleInput() {
			blocks[pointer] = (int) input.at(inputPointer);

			inputPointer++;
		}

		std::string handleInterpret(std::vector<char> achars) {
			std::vector<char> chars(achars);
			while (!chars.empty()) {
				char command = chars.front();

				chars.erase(chars.begin());

				switch(command) {
					case '+':
						updateBlockValue();

						break;
					case '-':
						updateBlockValue(false);

						break;
					case '>':
						updatePointer();

						break;
					case '<':
						updatePointer(false);

						break;
					case '[':
						chars = handleLoop(chars);

						break;
					case '.':
						handleOutput();

						break;
					case ',':
						handleInput();

						break;
				}

				// any other character is considered a comment
			}

			return output;
		}

	public:
		std::string interpret(std::string code = "", std::string codeInput = "") {
			input = codeInput;
			inputPointer = 0;
			blocks.clear();
			blocks.push_back(0);
			pointer = 0;
			output = "";

			std::vector<char> chars;
			for (size_t i = 0; i < code.length(); i++) {
					chars.push_back(code.at(i));
			}

			return handleInterpret(chars);
		}
};
