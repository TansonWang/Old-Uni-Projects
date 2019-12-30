#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <string>
#include <cctype>


// Constants
const int INITIAL_NUM_CARDS(7);
const int NUM_PLAYERS(4);
const int MIN_CARD(1);
const int MAX_CARD(10);
const int CURRENT_PLAYER(0);

// Enums and structs
enum Colours {
	RED,
	BLUE,
	GREEN,
	YELLOW
};

struct card {
	int number;
	Colours color;
};

// Function declarations
std::string colorToString(Colours color);
void addCard(std::vector<struct card> &Cards, int num, Colours color);
void initialiseCards(std::vector<struct card> &Cards);
int getRandomNumber(int min, int max);
void getInput(std::vector<struct card> &player, std::vector<struct card> &recentlyPlayedCards);
bool checkInput(std::string input);
bool isStringColour(std::string colour);
bool checkValidCard(std::vector<struct card> &player, std::vector <struct card> &recentlyPlayedCards,
					int num, Colours color);
void playRound(std::vector<struct card> &player, std::vector <struct card> &recentlyPlayedCards);

// Functions
// Converts color type to std::string type
std::string colorToString(Colours color) {
	switch (color) {
		case RED:
			return "Red";
			break;
		case BLUE:
			return "Blue";
			break;
		case GREEN:
			return "Green";
			break;
		case YELLOW:
			return "Yellow";
			break;
		default:
			return "Red";
			break;
	}
}

// Same as above except converts std::string type to color type
Colours stringToColor(std::string color) {
	if (color == "Red") return RED;
	else if (color == "Green") return GREEN;
	else if (color == "Blue") return BLUE;
	else if (color == "Yellow") return YELLOW;
	else return RED;

	return RED;
}

// Adds a card to the array/vector of struct card, given the number and the colour of the card
void addCard(std::vector<struct card> &Cards, int num, Colours color) {
	struct card cardToAdd = {num, color};
	Cards.push_back(cardToAdd);
}

// Formats and prints the cards in an array of cards
void printCards(std::vector<struct card> &Cards) {
	for (int i = 0; i < Cards.size(); i++) {
		std::cout << "#" << i+1 << " Card: " << Cards[i].number << ", " << colorToString(Cards[i].color) << '\n';
	}
}

// Fills the hands of the 4 players with random cards
void initialiseCards(std::vector<struct card> &Cards) {
	int number = 0;
	Colours color = RED;
	

	for (int i=0; i < INITIAL_NUM_CARDS; i++) {
		number = getRandomNumber(MIN_CARD, MAX_CARD); // Gets a random number
		color = static_cast<Colours>(getRandomNumber(0, 3)); // Gets a random number and converts it to Colours type
		addCard(Cards, number, color); // Adds the card to the array of cards
	}

}

// Literally gets a random number in the range given
int getRandomNumber(int min, int max)
{
    static const double fraction = 1.0 / (RAND_MAX + 1.0);
    // static used for efficiency, so we only calculate this value once
    // evenly distribute the random number across our range
    return min + static_cast<int>((max - min + 1) * (std::rand() * fraction));
}

// Function to check if the string is "Blue", "Red", etc.
bool isStringColour(std::string colour) {
	if (colour == "Blue" ||
		colour == "Red" ||
		colour == "Yellow" ||
		colour == "Green") {

		return true;
	}
	return false;
}

// check that input is valid before any conversion to numbers or type Colours 
// to avoid program crashing due to invalid input
bool checkInput(std::string input) {

	if (input == "Deck") {
		return true;
	}
	// Make sure there is input and its in the correct format
	int pos = input.find(" ");
	if (pos == std::string::npos) {
		return false;
	}

	// Make sure each character is a number
	std::string firstSub = input.substr(0, pos);
	if (pos <= 0) {
		return false;
	}
	for (int i = 0; i < pos; i++) {
		if (std::isdigit(firstSub[i]) == false) {
			return false;
		}
	}

	// Make sure the number is within the range
	int num = std::stoi(firstSub);
	if (num < MIN_CARD || num > MAX_CARD) {
		return false;
	}

	// Make sure the rest of the characters are letters
	std::string secondSub = input.substr(pos + 1);
	if (secondSub.size() <= 0) {
		return false;
	}
	for (int i = 0; i < pos; i++) {
		if (std::isalpha(secondSub[i]) == false) {
			return false;
		}
	}

	// Make sure the rest of string is a colour
	if (isStringColour(secondSub) == false) {
		return false;
	}

	return true;
}

// Checks that the card the player entered is in the player's hand and is similar to the recently played card
// If it is all good, then removes the card from the player's hand and adds it to the recently played cards
bool checkValidCard(std::vector<struct card> &player, std::vector <struct card> &recentlyPlayedCards,
					int num, Colours colour) {
	
	// Check if card chosen is actually in hand
	bool found = false;
	int pos = 0;
	for (int i = 0; i < player.size(); i++) {
		if (player[i].number == num && player[i].color == colour) {
			found = true;
			pos = i;
			break;
		}
	}

	if (found == false) {
		std::cout << "not found\n";
		return false;
	}

	// Check if card chosen is the same colour or same number as the most recently played card
	if (recentlyPlayedCards.back().number != num &&
		recentlyPlayedCards.back().color != colour) {

		return false;
	}

	// Remove card from player array
	player.erase(player.begin() + pos);

	addCard(recentlyPlayedCards, num, colour);

	return true;
}

// Let bots play cards
void playRound(std::vector<struct card> &player, std::vector <struct card> &recentlyPlayedCards) {

	bool found = false;
	int pos = 0;

	// Find card that is valid
	for (int i = 0; i < player.size(); i++) {
		if (recentlyPlayedCards.back().number == player[i].number ||
			recentlyPlayedCards.back().color == player[i].color) {

			found = true;
			pos = i;
			break;
		}
	}

	if (found == true) {
		addCard(recentlyPlayedCards, player[pos].number, player[pos].color);

		player.erase(player.begin() + pos);
	} else {
		// Draw from deck
		addCard(player, getRandomNumber(MIN_CARD, MAX_CARD), static_cast<Colours>(getRandomNumber(0, 3)));
	}

}

// Get input from user
// void printCards(std::vector<struct card> &Cards) {
void getInput(std::vector<struct card> &player, std::vector<struct card> &recentlyPlayedCards) {

	std::string inputLine;
	int num;
	Colours color;
	bool status = false; // used for while loop
	bool resultOfCheckInput = false;

	// Get actual input
	std::cout << "Last card played: " << recentlyPlayedCards.back().number << " " << 
		colorToString(recentlyPlayedCards.back().color) << '\n';
	std::cout << "Enter a card to play: ";
	std::getline(std::cin, inputLine);
	resultOfCheckInput = checkInput(inputLine);
	
	// Run if could not pass input test
	while (status == false) {
		
		while (resultOfCheckInput == false) {
			std::cout << '\n'; // For formatting
			std::cout << "Please enter a card like this: 5 Blue\n";
			std::cout << "Last card played: " << recentlyPlayedCards.back().number << " " << 
			colorToString(recentlyPlayedCards.back().color) << '\n';
			std::cout << "Enter a card to play: ";
			std::getline(std::cin, inputLine);

			resultOfCheckInput = checkInput(inputLine);
		}
		// If no request to get card from the deck
		if (inputLine != "Deck") {
			// Converts first part to a number
			num = std::stoi(inputLine.substr(0, inputLine.find(" ")));
			// std::cout << "num: " << num << '\n';

			// Converts second part to colours type
			color = stringToColor(inputLine.substr(inputLine.find(" ") + 1));
			// std::cout << "color: " << colorToString(color) << "\n\n";

			// Status variable to store if result of check of if the card given is valid
			status = checkValidCard(player, recentlyPlayedCards, num, color);
			if (status == false) {
				resultOfCheckInput = false;
				// Reset everything and ask for input again
			}
		} else {
			std::cout << "Getting a card from the deck!\n";
			num = getRandomNumber(MIN_CARD, MAX_CARD); // Gets a random number
			color = static_cast<Colours>(getRandomNumber(0, 3)); // Gets a random number and converts it to Colours type
			addCard(player, num, color); // Adds the card to the array of cards
			status = true;
		}
	}

}

void printVector(std::vector<struct card> vector, std::string name) {
	std::cout << name << ": ";
	for (int i = 0; i < vector.size(); i++) {
		std::cout << vector[i].number << " ";
	}

	std::cout << '\n';
}

// Returns true if there is a player with no cards left
bool numCardsLeft(std::vector<std::vector<struct card> > Players) {
	for (int i = 0; i < NUM_PLAYERS; i++) {
		if (Players[i].size() == 0) {
			return true;
		}
	}
	return false;
}

int main() {


	std::vector<std::vector<struct card> > Players;
	Players.resize(NUM_PLAYERS);
	
	std::srand(static_cast<unsigned int>(std::time(0)));
	std::rand(); // First number is always 5 for some reason, so skip to next number

	for (int i = 0; i < NUM_PLAYERS; i++) {
		initialiseCards(Players[i]);
	};

	std::cout << "Your cards: \n";
	printCards(Players[CURRENT_PLAYER]);

	// std::cout << "Player1 Card0: " << Players[0][0].number << ", " << colorToString(static_cast<Colours>(Players[0][0].color)) << '\n';
	// std::cout << "Player1 Card1: " << Players[0][1].number << ", " << colorToString(static_cast<Colours>(Players[0][1].color)) << '\n';

	std::vector<struct card> recentlyPlayedCards;
	// addCard(recentlyPlayedCards, getRandomNumber(MIN_CARD, MAX_CARD), static_cast<Colours>(getRandomNumber(0, 3)));
	addCard(recentlyPlayedCards, 5, RED);

	bool endGame = false;
	while (endGame == false) {
		std::cout << '\n';
		getInput(Players[0], recentlyPlayedCards);

		for (int j = 0; j < NUM_PLAYERS; j++) {
			if (j != CURRENT_PLAYER) {
				playRound(Players[j], recentlyPlayedCards);
			}
		}

		std::cout << "recentlyPlayedCards: \n";
		printCards(recentlyPlayedCards);
		std::cout << "Your cards: \n";
		printCards(Players[CURRENT_PLAYER]);

		for (int k = 0; k < NUM_PLAYERS; k++) {
			if (k != CURRENT_PLAYER) {
				std::cout << "Player " << k+1 << " has " << Players[k].size() << " cards left.\n";
			}
		}

		endGame = numCardsLeft(Players);
	}

	std::cout << "Game over!\n";
	return 0;

}