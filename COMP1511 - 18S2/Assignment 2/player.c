//Implements functions as described by player.h

#include <stdlib.h>
#include <math.h>
#include <stdio.h>

#include "Game.h"
#include "Card.h"
#include "player.h"

#define NO_MATCH -1
#define MATCH 1

int isNormalCard (Card card);
int isPowerCard (Card card);
int numPowerCard (Card array[], int numCards);

int matchingColor (color target, Card card);
int matchingSuit (suit target, Card card);
int matchingValue (value target, Card card);

int checkValueInArray (value target, Card array[], int length);
int checkColorInArray (color target, Card array[], int length);
int checkSuitInArray (suit target, Card array[], int length);

int canPlay(Game game, Card discardTop, Card array[], int length);
color mostColors (Card array[], int length);
int compareValues (int A, int B);
color findColorFromValue (int R, int B, int G, int Y, int P);


playerMove decideMove (Game game) {
	playerMove *thisTurn = calloc(1, sizeof(playerMove));
	if (currentTurnMoves(game) == 0) {//if first call
		int numCards = handCardCount(game);
		Card discardTop = topDiscard(game);

		//Making the three hand arrays, all, norm and power
			//fill up the hand array
			Card cards[numCards];
			int i = 0;
			while (i < numCards) {
				cards[i] = handCard(game, i);
				i++;
			}

			int numPow = numPowerCard(cards, numCards);
			int numNorm = numCards - numPow;

			//sort out the power cards
			Card handPower[numPow];
			i = 0;
			int j = 0;
			while (i < numCards) {
				if (isPowerCard(cards[i]) == MATCH) {
					handPower[j] = cards[i];
					j++;
				}
				i++;
			}

			//sort out the normal cards
			Card handNorm[numNorm];
			i = 0;
			j = 0;
			while (i < numCards) {
				if (isNormalCard(cards[i]) == MATCH) {
					handNorm[j] = cards[i];
					j++;
				}
				i++;
			}

		//If there are active draw twos, try and play a two
		if (getActiveDrawTwos(game) != 0) {
			int hasTwo = checkValueInArray(DRAW_TWO, handPower, numPow);
			if (hasTwo != NO_MATCH) {
				thisTurn->action = PLAY_CARD;
				thisTurn->card = handPower[hasTwo];
				return *thisTurn;
			} else {
				thisTurn->action = DRAW_CARD;
				return *thisTurn;
			}
		}

		//This is the catch all section for no special situations
		//try normal, then power, then zero, then draw
		int canPlayNorm = canPlay(game, discardTop, handNorm, numNorm);
		int canPlayPow = canPlay(game, discardTop, handPower, numPow);
		int canPlayZero = checkValueInArray(0, handPower, numPow);

		if (canPlayNorm != NO_MATCH) {
			thisTurn->action = PLAY_CARD;
			thisTurn->card = handNorm[canPlayNorm];
			return *thisTurn;

		} else if (canPlayPow != NO_MATCH) {
			//if played card was a D announce next card
			if (cardValue(handPower[canPlayPow]) == D) {
				thisTurn->nextColor = mostColors(cards, numCards);
			}
			thisTurn->action = PLAY_CARD;
			thisTurn->card = handPower[canPlayPow];
			return *thisTurn;

		} else if (canPlayZero != NO_MATCH) {
			thisTurn->action = PLAY_CARD;
			thisTurn->card = handPower[canPlayZero];
			return *thisTurn;

		} else {
			thisTurn->action = DRAW_CARD;
			return *thisTurn;

		}


	} else {
		thisTurn->action = END_TURN;
		return *thisTurn;
	}


	return *thisTurn;
}


//isn't a power card
int isNormalCard (Card card) {
	if (isPowerCard(card) != MATCH) {
		return MATCH;
	}
	return NO_MATCH;
}

//Check if input card has value Two, A, D or 0
int isPowerCard (Card card) {
	if (matchingValue(DRAW_TWO, card) != NO_MATCH) {
		return MATCH;
	}
	if (matchingValue(A, card) != NO_MATCH) {
		return MATCH;
	}
	if (matchingValue(D, card) != NO_MATCH) {
		return MATCH;
	}
	if (matchingValue(0, card) != NO_MATCH) {
		return MATCH;
	}
	return NO_MATCH;
}

//Takes an array and its length, returns no. power cards
int numPowerCard (Card array[], int numCards) {
	int i = 0;
	int counter = 0;
	while (i < numCards) {
		if (isPowerCard(array[i]) == MATCH) {
			counter++;
		}
		i++;
	}
	return counter;
}

//if a card has matches the value, color or suit of something
//intakes a color, value or suit and a card
int matchingColor (color target, Card card) {
	if (cardColor(card) == target) {
		return MATCH;
	} else {
		return NO_MATCH;
	}
}
int matchingSuit (suit target, Card card) {
	if (cardSuit(card) == target) {
		return MATCH;
	} else {
		return NO_MATCH;
	}
}
int matchingValue (value target, Card card) {
	if (cardValue(card) == target) {
		return MATCH;
	} else {
		return NO_MATCH;
	}
}

//check array for value, color or suit and return the pos
int checkValueInArray (value target, Card array[], int length) {
	int i = 0;
	while (i < length && cardValue(array[i]) != target) {
		i++;
	}
	if (i == length) {
		return NO_MATCH;
	} else {
		return i;
	}
}
int checkSuitInArray (suit target, Card array[], int length) {
	int i = 0;
	while (i < length && cardSuit(array[i]) != target) {
		i++;
	}
	if (i == length) {
		return NO_MATCH;
	} else {
		return i;
	}
}
int checkColorInArray (color target, Card array[], int length) {
	int i = 0;
	while (i < length && cardColor(array[i]) != target) {
		i++;
	}
	if (i == length) {
		return NO_MATCH;
	} else {
		return i;
	}
}

//take the top discard, the hand you are using and its length
//return the position of a playable card in hand or NO_MATCH
int canPlay (Game game, Card discardTop, Card array[], int length) {
	int hasSuit = checkSuitInArray(cardSuit(discardTop), array, length);
	if (hasSuit != NO_MATCH) {
		return hasSuit;
	}
	int hasColor = checkColorInArray(getCurrentColor(game), array, length);
	if (hasColor != NO_MATCH) {
		return hasColor;
	}
	int hasValue = checkValueInArray(cardValue(discardTop), array, length);
	if (hasValue != NO_MATCH) {
		return hasValue;
	}
	return NO_MATCH;
}

//taken in an array and return the most prolific card
color mostColors (Card array[], int length){
	int R = 0;
	int B = 0;
	int G = 0;
	int Y = 0;
	int P = 0;
	int i = 0;
	while (i < length) {
		if (cardColor(array[i]) == RED) {
			R++;
		} else if (cardColor(array[i]) == RED) {
			R++;
		} else if (cardColor(array[i]) == BLUE) {
			B++;
		} else if (cardColor(array[i]) == GREEN) {
			G++;
		} else if (cardColor(array[i]) == YELLOW) {
			Y++;
		} else if (cardColor(array[i]) == PURPLE) {
			P++;
		}
		i++;
	}
	color most = findColorFromValue(R, B, G, Y, P);
	return most;
}

//return the larger with preference to A
int compareValues (int A, int B) {
	if (A >= B) {
		return A;
	} else {
		return B;
	}
}

//match the highest value with the correct color and return that
color findColorFromValue (int R, int B, int G, int Y, int P) {
	int largest = compareValues(R, B);
	largest = compareValues(largest, G);
	largest = compareValues(largest, Y);
	largest = compareValues(largest, P);
	if (largest == R) {
		return R;
	}
	if (largest == B) {
		return B;
	}
	if (largest == G) {
		return G;
	}
	if (largest == Y) {
		return Y;
	}
	if (largest == P) {
		return P;
	}
	return R;
}
