// The game of Final Card-Down. v1.6 (updated 07:50am 09/Oct)
//
// !!! DO NOT CHANGE THIS FILE !!!


#include "Card.h"

#ifndef GAME_H
#define GAME_H

#define NUM_PLAYERS 4

#define NOT_FINISHED -1
#define NO_WINNER 4

#define FALSE 0
#define TRUE (!FALSE)

typedef struct _game *Game;


typedef enum {
    // Draw a single card from the deck.
    DRAW_CARD,
    // Play a single card onto the discard pile.
    PLAY_CARD,
    // End the player's turn.
    END_TURN
} action;

typedef struct _playerMove {
    // Which action to play.
    action action;
    // Declare which color must be played on the next turn.
    // This is only used when playing a "D". 
    color nextColor;
    // Which card to play (only valid for PLAY_CARD).
    Card card;
} playerMove;


Game newGame(int deckSize, value values[], color colors[], suit suits[]);


void destroyGame(Game game);


// Get the number of cards that were in the initial deck.
int numCards(Game game);


int numOfSuit(Game game, suit suit);

int numOfColor(Game game, color color);

int numOfValue(Game game, value value);

int currentPlayer(Game game);

int currentTurn(Game game);


Card topDiscard(Game game);

int numTurns(Game game);

int currentTurnMoves(Game game);
int getNumberOfTwoCardsAtTop(Game game);


int getCurrentColor(Game game);

int getPreviousTurnPlayer(Game game);


int getTopDiscardTurnNumber(Game game);

int getActiveDrawTwos(Game game);


int handCardCount(Game game);

Card handCard(Game game, int card);

int isValidMove(Game game, playerMove move);


void playMove(Game game, playerMove move);

int gameWinner(Game game);


Card getDeckCard (Game game, int n);

Card getDiscardPileCard (Game game, int n);

Card getHandCard (Game game, int player, int n);

int playerCardCount(Game game, int player);

int playerPoints(Game game, int player);


#endif // GAME_H

