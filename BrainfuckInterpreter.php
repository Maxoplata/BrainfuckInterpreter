<?php
/**
 * BrainfuckInterpreter.php
 *
 * Interprets Brainfuck code.
 *
 * example usage:
 *
 * $bf = new BfInterpreter();
 * print $bf->interpret('++++++[>++++++++++<-]>+++++.');
 *
 * @author Maxamilian Demian <max@maxdemian.com>
 * @link https://www.maxodev.org
 * @link https://github.com/Maxoplata/BrainfuckInterpreter
 */

class BfInterpreter
{
	private $input;
	private $inputPointer;
	private $blocks;
	private $pointer;
	private $output;

	private function updateBlockValue($increase = true) {
		if ($increase) {
			if ($this->blocks[$this->pointer] === 255) {
				$this->blocks[$this->pointer] = 0;
			} else {
				$this->blocks[$this->pointer]++;
			}
		} else {
			if ($this->blocks[$this->pointer] === 0) {
				$this->blocks[$this->pointer] = 255;
			} else {
				$this->blocks[$this->pointer]--;
			}
		}
	}

	private function updatePointer($increase = true) {
		if ($increase) {
			$this->pointer++;

			if (!isset($this->blocks[$this->pointer])) {
				$this->blocks[$this->pointer] = 0;
			}
		} else if ($this->pointer > 0) {
			$this->pointer--;
		}
	}

	private function getPositionOfClosingBracket($chars) {
		$openBracketCount = 0;

		for ($i = 0; $i < count($chars); $i++) {
			if ($chars[$i] === '[') {
				$openBracketCount++;
			} else if ($chars[$i] === ']') {
				if ($openBracketCount > 0) {
					$openBracketCount--;
				} else {
					return $i;
				}
			}
		}
	}

	private function handleLoop($chars) {
		$closingBracketPos = $this->getPositionOfClosingBracket($chars);
		$loopCodeChars = array_slice($chars, 0, $closingBracketPos);

		// the recursive call to $this->handleInterpret can change the value of $this->pointer, so we need to put it in a new var first
		$loopPointer = $this->pointer;

		while ($this->blocks[$loopPointer] !== 0) {
			$this->handleInterpret($loopCodeChars);
		}

		return array_slice($chars, $closingBracketPos + 1);
	}

	private function handleOutput() {
		$this->output .= chr($this->blocks[$this->pointer]);
	}

	private function handleInput() {
		$this->blocks[$this->pointer] = ord($this->input[$this->inputPointer]);

		$this->inputPointer++;
	}

	private function handleInterpret($chars) {
		while (count($chars)) {
			$command = array_shift($chars);

			switch($command) {
				case '+':
					$this->updateBlockValue();

					break;
				case '-':
					$this->updateBlockValue(false);

					break;
				case '>':
					$this->updatePointer();

					break;
				case '<':
					$this->updatePointer(false);

					break;
				case '[':
					$chars = $this->handleLoop($chars);

					break;
				case '.':
					$this->handleOutput();

					break;
				case ',':
					$this->handleInput();

					break;
				default:
					// any other character is considered a comment
			}
		}

		return $this->output;
	}

	public function interpret($code = '', $input = '') {
		$this->input = $input;
		$this->inputPointer = 0;
		$this->blocks = [0];
		$this->pointer = 0;
		$this->output = '';

		return $this->handleInterpret(str_split($code));
	}
}
