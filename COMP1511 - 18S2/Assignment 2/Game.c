//Implements Functions as described in Game.h
//Tanson Wang (z5206031)
//Lab-Tut (WED-11 STRINGS)
//Last modified 25-10-2018 20:23
//
//Thought Log
//I really hate this god damn project
//How the hell is this worth 1% more than mandelbrot
//It took me 5 days of continuous coding to do this
//I admit that I'm not good at coding
//but this is just excessive
//It felt messy and I found that the labs were not helpful for this
//I have easily over 2k code between the three files
//Meanwhile mandelbrot has barely 100 lines
//I mean, what the fuck, was it really worth the 200x increase for 1%
//Hell no
//Like seriously the hell man, NOT COOL
//I have exams, like one literally tomorrow
//This was just a massive burden that was not worth the marks
//Have fun marking this shit
//
//
//Now that the minor rant is over
//This project was actually vaguely enjoyable, at times
//I was honestly, completely lost until the stage 1 & 2 tests came out
//A bloody godsend to a fool
//Forum posts were responded to quickly and info was good
//Lectures? Bloody useless
//From the slides to the recording, nothing was helpful
//I would like to say that I have only asked for help once
//It was definitely a fast and effective response, cheers Andrew Bennett
//Lab tutors were nice and gave decent responses
//I didn't attend any help sessions, too late in the day for me
//Once again, IS NOT WORTH 1% MORE THAN MANDELBROT
//Cheers
//Tanson

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <err.h>

#include "Card.h"
#include "player.h"
#include "Game.h"

#include "player.c"

#define NUM_PLAYERS 4
#define NOT_FINISHED -1
#define NO_WINNER 4
#define HAND_MAX 1024
#define DECK_MAX 4096
#define FALSE 0
#define TRUE (!FALSE)


//structs go here
typedef struct _card {
	value value;
	color color;
	suit suit;
}*Card;

typedef struct node {
	struct node *next;
	Card card;
} node;

typedef struct player {
	//All my info for ze players
	node *handStart;
	node *handEnd;
	int handCards;
} player;

typedef struct _game {
		//All of the info about te game goes here
		//There should be a shit ton ya know
		struct node *deck;
		struct node *discardPile;
		struct player *players[NUM_PLAYERS];

		value values[DECK_MAX];
		color colors[DECK_MAX];
		suit suits[DECK_MAX];

		int startNumOfCards;
		int currentTurn;
		int currentPlayer;
		int currentTurnMoves;
		int numTurns;
		int previousTurnPlayer;
		int getTopDiscardTurnNumber;

		Card topDiscard;
		color currentColor;
		int cardsToDraw;
		int skipATurn;

		int isValidMove;
		int gameWinner;
} *Game;

typedef struct deck {
	node *deckStart;
	int deckSize;
	node *deckEnd;
} deck;

//function list
	static node *cardInList(Card card, node *start);
	static int isCardInList(Card card, node *start);
	static struct node *createNode(value value, color color, suit suit);
	static void addToListEnd(node *start, node *addedNode);
	static void addToListStart(node **start, node *addedNode);
	static node *removeFromList(node *beginning, node *toRemove);
	static node *reverselist (node *head);
	static node *createDeck (int deckSize, value values[], color colors[], suit suits[]);
	static void startingHand (Game game);
	static int topCardColor(node *Discard);
	static int twosInHand(Game game, int playerNum);
	static void playCard(Game game, int playerNum, Card card);
	static node *drawCard(Game game, int playerNum);



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Actual functions starting from here don neeee~~
//------------------------------------
//General Usage stuff Raponnnn~~
//finds the card from the list and returns the node to the card
static node *cardInList(Card card, node *start) {
	node *curr = start;
	while (curr!= NULL && curr->card != card) {
		curr = curr->next;
	}
	if (curr == NULL) {
		return NULL;
	} else {
		return curr;
	}
}

//Is a particular card in the list, 1 for yes and 0 for no
static int isCardInList(Card card, node *start) {
	node *curr = start;
	while (curr!= NULL && curr->card != card) {
		curr = curr->next;
	}
	if (curr == NULL) {
		return 0;
	} else {
		return 1;
	}
}

//Creating a node for the list dodonnnn~~
static struct node *createNode(value value, color color, suit suit) {
	struct node *n;
	n = calloc(1, sizeof(node));
	n->card = newCard(value, color, suit);
	n->next = NULL;
	return n;
}


//Adding a node to end of a list jajannnn~~
static void addToListEnd(node *start, node *addedNode) {
	node *curr = start;
	//printf("washingsock %d\n", start->card->suit);
	while(curr->next != NULL) {
		curr = curr->next;
	}
	curr->next = addedNode;
	//addedNode->next = NULL;
}

//adding a node to the start of a list
static void addToListStart(node **start, node *addedNode) {
	addedNode->next = *start;
	*start = addedNode;
}

//Removing a value from the list yoooo~~
static node *removeFromList(node *beginning, node *toRemove) {
	node *curr = beginning;
	node *prev;

	//if empty list
    if (beginning == NULL) {
        return beginning;
    }
    //if first value
    if (beginning == toRemove) {
        node *now = beginning;
        beginning = beginning->next;
        now->next = NULL;
        return beginning;
    }

    //Flowing through the list
    while (curr != NULL && curr != toRemove) {
        prev = curr;
        curr = curr->next;
    }
    //Remove from list
    if (curr == toRemove) {
        node *original = curr;
        prev->next = curr->next;
        curr = curr->next;
        original->next = NULL;
    }

    return beginning;
}

//Reverse the entire list and return the new head
static node *reverselist (node *head) {
    struct node *curr = head;
    int num_of_node = 0;
    
    //If there is no number
    if (curr == NULL) {
        return NULL;
    }
    
    //Count the number of numbers in the list and save the last location
    struct node *end_location;
    while (curr != NULL) {
        struct node *prev = curr;
        curr = curr->next;
        num_of_node++;
        end_location = prev;
    }    

    curr = head; //reset back to the start of the list

    if (num_of_node == 1) { //list length 1 return the value
        return head;
    } else if (num_of_node == 2) { //list length 2, make 2 point to 1 and 1 to NULL
        struct node *prev = curr;
        curr = curr->next;
        curr->next = prev;
        prev->next = NULL;
        head = curr;
    } else { //list length > 2
        struct node *prev1 = curr;
        struct node *prev2;

        end_location->next = curr; //kink the end value to the start

        //create the positions of prev1 and prev2
        curr = curr->next;
        prev2 = prev1;
        prev1 = curr;
        curr = curr->next;
        prev1->next = prev2; //first reverse

        //loop through the linked list and make prev1 point to prev2 (backwards)
        //-2 is beacuse we have already done one above
        int i = 0;
        while (i < num_of_node - 2) {
            prev2 = prev1;
            prev1 = curr;
            curr = curr->next;
            prev1->next  = prev2;
            i++;
        }
        curr->next = NULL;
        head = prev1;

    }

    return head;
}

//------------------------------------
//Starting the game off oraaaa~~
//Starting a new game including making the deck and giving out cards
Game newGame(int deckSize, value values[], color colors[], suit suits[]) {
	Game currGame;
	//allocate all required space
		currGame = calloc(1, sizeof(struct _game));
		currGame->players[0] = calloc(1, sizeof(struct player));
		currGame->players[1] = calloc(1, sizeof(struct player));
		currGame->players[2] = calloc(1, sizeof(struct player));
		currGame->players[3] = calloc(1, sizeof(struct player));

	//Create deck and obtain its starting position
	currGame->deck = createDeck(deckSize, values, colors, suits);
	//printf("%d\n", currGame->deck->card->value);
	
	//Knowledge is power
		currGame->startNumOfCards = deckSize;
		int loadingArray = 0;
		currGame->values[deckSize] = *values;
		currGame->colors[deckSize] = *colors;
		currGame->suits[deckSize] = *suits;

		currGame->currentTurn = 0;
		currGame->currentTurnMoves = 0;
		currGame->currentPlayer = 0;
		currGame->numTurns = 1;
		currGame->previousTurnPlayer = -1;
		currGame->getTopDiscardTurnNumber = -1;
		currGame->gameWinner = NOT_FINISHED;
		currGame->skipATurn = 1;

	//Everyone starts with an empty card in their hand.
		node *p0Card0 = createNode(100,100,100);
		node *p1Card0 = createNode(100,100,100);
		node *p2Card0 = createNode(100,100,100);
		node *p3Card0 = createNode(100,100,100);
	//Assigning the cards made above to the players
		currGame->players[0]->handStart = p0Card0;
		currGame->players[1]->handStart = p1Card0;
		currGame->players[2]->handStart = p2Card0;
		currGame->players[3]->handStart = p3Card0;
	//printf("%d\n", currGame->players[1]->handStart->card->value);
	startingHand(currGame);

	//Playing the top card from the deck
	node *firstCardToPlay = currGame->deck;
	currGame->deck = currGame->deck->next;
	removeFromList(firstCardToPlay, firstCardToPlay);
	currGame->discardPile = firstCardToPlay;
	currGame->topDiscard = currGame->discardPile->card;

	return currGame;
}

//Creating a deck neeee~~
static node *createDeck (int deckSize, value values[], color colors[], suit suits[]) {
	node *firstNode = createNode(values[0], colors[0], suits[0]);

	//Make a list of all of the cards adding onto the first node created
	int i = 1;
	while (i < deckSize) {
		node *currNode = createNode(values[i], colors[i], suits[i]);
		addToListEnd(firstNode, currNode);
		i++;
		currNode->next=NULL;
	}
	return firstNode;
}

//Distributing the starting cards
static void startingHand (Game game) {
	node *currNode = game->deck;
	node *prevNode;
	
	//Passing out the starting hand cards
	int i = 0;
	while (i < 7) {
		//printf("hi %d\n", i);
		game->deck = drawCard(game, 0);
		//printf("%d\n", game->deck->card->suit);
		game->deck = drawCard(game, 1);
		game->deck = drawCard(game, 2);
		game->deck = drawCard(game, 3);
		i++;
	}
}

//Finding number of value, color and suit
	int NumOfValue (Game game, value toCheck) {
		int numOfValue = 0;
		int i = 0;
		while(i < game->startNumOfCards) {
			if (game->values[i] == toCheck) {
				numOfValue++;
			}
			i++;
		}
		return numOfValue;
	}
	int NumOfColor (Game game, color toCheck) {
		int numOfColor = 0;
		int i = 0;
		while(i < game->startNumOfCards) {
			if (game->colors[i] == toCheck) {
				numOfColor++;
			}
			i++;
		}
		return numOfColor;
	}
	int NumOfSuit (Game game, suit toCheck) {
		int numOfSuit = 0;
		int i = 0;
		while(i < game->startNumOfCards) {
			if (game->suits[i] == toCheck) {
				numOfSuit++;
			}
			i++;
		}
		return numOfSuit;
	}

//Number of cards in the initial deck
int numCards(Game game) {
	return game->startNumOfCards;
}

//Remove all alloced space
void destroyGame (Game game) {
	int i = 0;
	while (i < 4) {//for each player
		node *curr = game->players[i]->handStart;
		while (curr != NULL) {//in each players hand
			node *prev = curr;
			curr= curr->next;
			free(prev->card);//the card in the node
			free(prev);//the node itstelf
		}
		free(game->players[i]);
		i++;
	}
	//free the deck list in game
	node *curr = game->deck;
		while (curr != NULL) {
		node *prev = curr;
		curr= curr->next;
		free(prev->card);
		free(prev);
		}
	//free the discard list in game
	curr = game->discardPile;
		while (curr != NULL) {
		node *prev = curr;
		curr= curr->next;
		free(prev->card);
		free(prev);
		}
	free(game);
}

//------------------------------------
//During the game jajannnn~~
//Number of consecutive twos on the discard pile
int getNumberofTwoCardsAtTop(Game game) {
	node *curr = game->discardPile;
	int numOfTwosOntop = 0;
	while (curr->card->value == DRAW_TWO) {
		numOfTwosOntop++;
		curr = curr->next;
	}
	return numOfTwosOntop;
}

//return the color of the first card from the game struct
static int topCardColor(node *Discard) {
	int color = Discard->card->color;
	return color;
}

//find the number of cards in a player's hand
int playerCardCount(Game game, int playerNum) {
	node *curr = game->players[playerNum]->handStart->next;
	int num = 0;
	while (curr != NULL) {
		num++;
		curr = curr->next;
	}
	return num;
}

//number of cards in current player's hand
int handCardCount(Game game) {
	node *curr = game->players[game->currentPlayer]->handStart->next;
	int num = 0;
	while (curr != NULL) {
		num++;
		curr = curr->next;
	}
	return num;
}

//worth of a player's hand
int playerPoints(Game game, int playerNum) {
	node *curr = game->players[game->currentPlayer]->handStart->next;
	int points = 0;
	while (curr != NULL) {
		points = points + curr->card->value;
		curr = curr->next;
	}
	return points;
}
//if there is a two in the player's hand return 1 otherwise 0
static int twosInHand(Game game, int playerNum) {
	node *curr = game->players[playerNum]->handStart;
	while (curr != NULL) {
		if (curr->card->value == DRAW_TWO) {
			return 1;
		}
		curr = curr->next;
	}
	return 0;
}

//------------------------------------
//Player Powers Keroooo~~
//move a card to the discard pile and remove it from the hand
static void playCard(Game game, int playerNum, Card card) {
	node *HandStart = game->players[playerNum]->handStart;
	node *curr = cardInList(card, HandStart);
	removeFromList(HandStart, curr);
	addToListStart(&game->discardPile, curr);
}

//Return the last discarded card
Card topDiscard (Game game) {
	return game->topDiscard;
}

//the number of actions exacuted during this turn
int currentTurnMoves (Game game) {
	//printf("In the function currentTurnMoves %d\n", game->currentTurnMoves);
	return game->currentTurnMoves;
}

//draw a card and return the top of the deck
static node *drawCard(Game game, int playerNum) {
	node *curr = game->deck;

	//printf("%d ", game->deck->card->suit);
	if (game->deck == NULL) {//if there is no deck
		if (game->discardPile == NULL) {//and there is no discard
			game->gameWinner = NO_WINNER;
			return NULL;
		} else {//if there is a discard, reverse it and make it the deck
			game->deck = reverselist(game->discardPile);
			curr = game->deck;
			addToListEnd(game->players[playerNum]->handStart, curr);
			game->discardPile = NULL;
			return game->deck;
		}
	} else {//if there is a deck
		game->deck = game->deck->next;
		//printf("I drew a card\n");
		addToListEnd(game->players[playerNum]->handStart, curr);
		curr->next = NULL;
		return game->deck;
	}	
}

//return the card of position cardPos in your hand
Card handCard(Game game, int cardPos){
	node *curr = game->players[game->currentPlayer]->handStart;
	int i = 1;
	while (i < cardPos) {
		curr = curr->next;
		i++;
	}
	return curr->card;
}

//------------------------------------
//Condition checking ra oooo~~
int currentPlayer (Game game) {
	return game->currentPlayer;
}
int currentTurn (Game game) {
	return game->currentTurn;
}
int numTurns (Game game) {
	return game->numTurns;
}
int getPreviousTurnPlayer (Game game){
	return game->previousTurnPlayer;
}
int getTopDiscardTurnNumber (Game game) {
	return game->getTopDiscardTurnNumber;
}
int getCurrentColor(Game game) {
	return game->currentColor;
}
//go through the deck and return card no.i or NULL
Card getDeckCard (Game game, int i) {
	int j = 0;
	node *curr = game->deck;
	while (j < i && curr != NULL) {
		curr = curr->next;
		//printf("moving on %d\n", j)
		j++;
	}
	if (curr == NULL) {
		return NULL;
	}
	return curr->card;
}
//go through the discard and return card no.i or NULL
Card getDiscardPileCard (Game game, int i) {
	int j = 0;
	node *curr = game->discardPile;
	while (j < i && curr != NULL) {
		curr = curr->next;
		j++;
	}
	if (curr == NULL) {
		return NULL;
	}
	//printf("suit %d\n", curr->card->suit);
	//printf("value %d\n", curr->card->value);
	//printf("color %d\n", curr->card->color);
	return curr->card;
}
//get card No.i of a player's hand
Card getHandCard (Game game, int player, int i) {
	int j = 0;
	node *curr = game->players[player]->handStart;
	while (j < i +1 && curr != NULL) {
		curr = curr->next;
		j++;
	}
	if (curr == NULL) {
		return NULL;
	}
	return curr->card;
}
//instead of keeping a number of twos, I have cardsToDraw
//but they are basically the same except cardsToDraw is x2 larger
int getActiveDrawTwos(Game game) {
	return game->cardsToDraw/2;
}

//Play the godamn move, takes in the game and the preped move
void playMove(Game game, playerMove move) {
	int playerNum = game->currentPlayer;
	game->gameWinner = gameWinner(game);
	//printf("current player num = %d\n",playerNum);
	if (isValidMove(game, move) && gameWinner(game) == NOT_FINISHED) {
		//while there has been no turns yet
		if (game->currentTurnMoves == 0) {
			//if there has been twos played before
			if (game->cardsToDraw != 0) {
				//if a two is played add to the number of cards to draw
				if (move.action == DRAW_CARD) {
				//if card played wasn't two or they didn't play
				//draw all required cards
					while (0 < game->cardsToDraw) {
						drawCard(game, playerNum);
						//printf("Drew a card %d\n", game->cardsToDraw);
						game->cardsToDraw--;
					}
					game->currentTurnMoves++;
				} else if (move.card->value == DRAW_TWO && move.action == PLAY_CARD) {
					playCard(game, playerNum, move.card);
					game->cardsToDraw = game->cardsToDraw + 2;
					game->currentTurnMoves++;
				}
			} else 
			//if the action is drawing a card add a card to their hand
			if (move.action == DRAW_CARD) {
				drawCard(game, playerNum);
				game->currentTurnMoves++;
			} else
			//if the action is playing a card, play a card from their hand
			if (move.action == PLAY_CARD) {
				playCard(game, playerNum, move.card);

				//first set everything to its default state
				game->cardsToDraw = 0;
				game->skipATurn = 1;
				game->currentColor = move.card->color;
				game->getTopDiscardTurnNumber = game->currentTurn;
				game->topDiscard = move.card;

				//if the card was a two, add to the cardsToDraw
				//if the card was an A, make skipATurn to two
				//if the card was a D, make currentColor = move.nextColor

				if (move.card->value == DRAW_TWO) {
					game->cardsToDraw = game->cardsToDraw + 2;
				}
				if (move.card->value == A) {
					game->skipATurn = 2;
					//printf("skipATurn is now %d\n", game->skipATurn);					
				}
				if (move.card->value == D) {
					//printf("color was %d\n", game->currentColor);
					game->currentColor = move.nextColor;
					//printf("color is now %d\n", game->currentColor);
				}

				game->currentTurnMoves++;
			}
		}
		//if the action is giving up on life
		if (move.action == END_TURN) {
			game->previousTurnPlayer = game->currentPlayer;
			//printf("current player = %d\n",game->currentPlayer);
			//printf("current skipATurn = %d\n",game->skipATurn);
			game->currentPlayer = ((game->currentPlayer + game->skipATurn) % 4);
			//printf("current player = %d\n",game->currentPlayer);
			game->currentTurn++;
			game->numTurns++;
			game->currentTurnMoves = 0;
		}
	} else {
		if (gameWinner(game) == NOT_FINISHED) {
			printf("Your move was invalid friend\n");
		} else {
			printf("Game's Over Stop Playing\n");
		}
	}
}

int isValidMove (Game game, playerMove move) {
	Card prevCard = game->topDiscard;
	int playerNum = game->currentPlayer;
	node *playerHand = game->players[playerNum]->handStart;

	//if the game is already finished what are you doing?
	if (game->gameWinner != NOT_FINISHED) {
		return FALSE;
	}

	//if the they haven't taken a turn yet
	if (game->currentTurnMoves == 0) {
		//if the previous card was a two
		if (prevCard->value == DRAW_TWO) {
			if (move.action == PLAY_CARD && move.card->value == DRAW_TWO) {
				return TRUE;
			} else if (game->cardsToDraw == 0) {
				return TRUE;
			} else if (move.action == DRAW_CARD) {
				return TRUE;
			} else {//player either didn't play a card or it wasn't two
				return FALSE;
			}
		}
		if (prevCard->value == A) {
			if (game->previousTurnPlayer != ((playerNum + 2) % 4)) {
				return FALSE;
			}
		}
		if (move.action == DRAW_CARD) {
			if (game->deck == NULL && game->discardPile == NULL) {
				return FALSE;
			} else {
				return TRUE;
			}
		}
		if (move.action == PLAY_CARD) {
			//if card is even in their hand...
			if (isCardInList(move.card, playerHand) != 1) {
				return FALSE;
			}
			//if the card is 0 or matches anything
			if (move.card->value == 0) {
				return TRUE;
			} else
			if (move.card->color == game->currentColor){
				return TRUE;
			} else if (move.card->suit == prevCard->suit) {
				return TRUE;
			} else if (move.card->value == prevCard->value) {
				return TRUE;
			} else {
				return FALSE;
			}
		}
		if (move.action == END_TURN) {
			return FALSE;
		}
	} else {//currentTurnMoves is not 0
		if (move.action != END_TURN) {
			return FALSE;
		} else {//move.action is END_TURN
			return TRUE;
		}
	}
	return FALSE;
}

int gameWinner (Game game) {
	int i = 0;
	while (i < 4) {
		if (playerPoints(game, i) == 0) {
			return i;
		}
		i++;
	}
	return NOT_FINISHED;
}