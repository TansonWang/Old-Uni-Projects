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


#include <stdio.h>
#include <assert.h>

#include "Game.h"
#include "Card.h"

#define STARTING_HAND_SIZE 7
#define NUM_PLAYERS 4

#define NUM_VALUES 16
#define NUM_COLORS 5
#define NUM_SUITS 5

//Test 1 Draw two
    static void test1_draw_two_once(void);
    static void test1player0turn1 (Game game);
    static void test1player1turn1 (Game game);

//Test 2 Draw two twice
    static void test2_draw_two_twice(void);
    static void test2player0turn1 (Game game);
    static void test2player1turn1 (Game game);
    static void test2player2turn1 (Game game);

//Test 3 play skip
    static void test3_skip_turn(void);
    static void test3player0turn1 (Game game);
    static void test3player2turn1 (Game game);

//Test 4 play wild
    static void test4_play_D(void);
    static void test4player0turn1 (Game game);
    static void test4player1turn1 (Game game);

//Test 5 play 0
    static void test5_play_0(void);
    static void test5player0turn1 (Game game);
    static void test5player1turn1 (Game game);

//Test 6 empty deck
    static void test6_empty_deck(void);
    static void test6player0turn1 (Game game);
    static void test6player1turn1 (Game game);
    static void test6player2turn1 (Game game);

//HelperFunctions
    static Card findCardInHand(Game game, int player, value v, color c, suit s);
    static void checkGameState(Game game, int expectedPlayer, int expectedTurn, int expectedMoves, int expectedPreviousPlayer, int expectedTopDiscardTurn);
    static Card findCardInDeck(Game game, value v, color c, suit s);
    static void checkTopDiscard(Game game, Card card);
    static int cardMatchesComponents(Card card, value v, color c, suit s);
    static void printCardByComponents(value v, color c, suit s);




int main (void){
     test1_draw_two_once ();
     test2_draw_two_twice ();
     test3_skip_turn ();
     test4_play_D();
     test5_play_0();
     test6_empty_deck();
     printf("\n\n\n HAHAHAHAHA M*THER F*CKER THIS IS FINALLY DONE \n\n\n");
}


//==========================FUNCTIONS==============================\\
//=============TEST ONE===============\\
//Testing the draw card function
    static void test1_draw_two_once (void){
        int deck_size = 50;
        value values[] = {
            DRAW_TWO, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        color colors[] = {
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        suit suits[] = {
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        Game game = newGame(deck_size, values, colors, suits);
        printf("~~~~~~~~~~~TEST ONE~~~~~~~~~~~\n");
        test1player0turn1 (game);
        test1player1turn1 (game);
    }

    //player0 plays a drawtwo, lets see how this goes
    static void test1player0turn1 (Game game) {
        playerMove move;
        Card card;
        printf("test1player0turn1\n");
        printf("formerly had %d cards in hand\n", playerCardCount(game, 0));

        //find the required card
        card = findCardInHand(game, 0, DRAW_TWO, 1, 1);
        assert(card != NULL);
        //play the found card
        move.action = PLAY_CARD;
        move.card = card; 
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        checkTopDiscard(game, card);
        printf("Has played DRAW_TWO, 1, 1\n");
        printf("now has %d cards in hand\n", playerCardCount(game, 0));

        //end turn
        move.action = END_TURN;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Turn has ended\n\n");
    }

    //Draw two
    static void test1player1turn1 (Game game) {
        playerMove move;
        Card card;
        printf("test1player1turn1\n");
        printf("formerly had %d cards in hand\n", playerCardCount(game, 1));

        //draw cards as the previous card was a 2
        move.action = DRAW_CARD;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Has drawn cards\n");
        printf("now has %d cards in hand\n", playerCardCount(game, 1));
        assert(playerCardCount(game, 1) == 9);

        //end turn
        move.action = END_TURN;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Turn has ended\n\n");
    }

//=============TEST TW0===============\\
//Testing the draw card function by playing two twice
    static void test2_draw_two_twice (void){
        int deck_size = 50;
        value values[] = {
            DRAW_TWO, DRAW_TWO, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        color colors[] = {
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        suit suits[] = {
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        Game game = newGame(deck_size, values, colors, suits);
        printf("~~~~~~~~~~~TEST TWO~~~~~~~~~~~\n");

        test2player0turn1 (game);
        test2player1turn1 (game);
        test2player2turn1 (game);
    }

    //player0 plays a drawtwo, lets see how this goes
    static void test2player0turn1 (Game game) {
        playerMove move;
        Card card;
        printf("test2player0turn1\n");
        printf("formerly had %d cards in hand\n", playerCardCount(game, 0));

        //find the required card
        card = findCardInHand(game, 0, DRAW_TWO, 1, 1);
        assert(card != NULL);
        //play the found card
        move.action = PLAY_CARD;
        move.card = card; 
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        checkTopDiscard(game, card);
        printf("Has played DRAW_TWO, 1, 1\n");
        printf("now has %d cards in hand\n", playerCardCount(game, 0));

        //end turn
        move.action = END_TURN;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Turn has ended\n\n");
    }

    //Playing another two
    static void test2player1turn1 (Game game) {
        playerMove move;
        Card card;
        printf("test2player1turn1\n");
        printf("formerly had %d cards in hand\n", playerCardCount(game, 1));

        //find the required card
        card = findCardInHand(game, 1, DRAW_TWO, 1, 1);
        assert(card != NULL);
        //play the found card
        move.action = PLAY_CARD;
        move.card = card; 
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        checkTopDiscard(game, card);
        printf("Has played DRAW_TWO, 1, 1\n");
        printf("now has %d cards in hand\n", playerCardCount(game, 1));

        //end turn
        move.action = END_TURN;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Turn has ended\n\n");
    }
    //Draw four
    static void test2player2turn1 (Game game) {
        playerMove move;
        Card card;
        printf("test2player2turn1\n");
        printf("formerly had %d cards in hand\n", playerCardCount(game, 2));

        //draw cards as the previous card was a 2
        move.action = DRAW_CARD;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Has drawn cards\n");
        printf("now has %d cards in hand\n", playerCardCount(game, 2));
        assert(playerCardCount(game, 2) == 11);

        //end turn
        move.action = END_TURN;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Turn has ended\n\n");
    }

//=============TEST THREE===============\\
//Testing the ace card function
    static void test3_skip_turn (void){
        int deck_size = 50;
        value values[] = {
            A, 1, A, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        color colors[] = {
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        suit suits[] = {
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        Game game = newGame(deck_size, values, colors, suits);
        printf("~~~~~~~~~~~TEST THREE~~~~~~~~~~~\n");
        test3player0turn1 (game);
        test3player2turn1 (game);
    }

    //plays an ace
    static void test3player0turn1 (Game game) {
        playerMove move;
        Card card;
        printf("test3player0turn1\n");

        //find the required card
        card = findCardInHand(game, 0, A, 1, 1);
        assert(card != NULL);
        //play the found card
        move.action = PLAY_CARD;
        move.card = card; 
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        checkTopDiscard(game, card);
        printf("Has played A, 1, 1\n");

        //end turn
        move.action = END_TURN;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Turn has ended\n\n");
    }

    //plays an ace
    static void test3player2turn1 (Game game) {
        playerMove move;
        Card card;
        printf("test3player2turn1\n");

        //find the required card
        card = findCardInHand(game, 2, A, 1, 1);
        assert(card != NULL);
        //play the found card
        move.action = PLAY_CARD;
        move.card = card; 
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        checkTopDiscard(game, card);
        printf("Has played A, 1, 1\n");

        //end turn
        move.action = END_TURN;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Turn has ended\n\n");
    }

//=============TEST FOUR===============\\
//Testing the wild card function
    static void test4_play_D (void){
        int deck_size = 50;
        value values[] = {
            D, 2, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        color colors[] = {
            1, 2, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        suit suits[] = {
            1, 2, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        Game game = newGame(deck_size, values, colors, suits);
        printf("~~~~~~~~~~~TEST FOUR~~~~~~~~~~~\n");
        test4player0turn1 (game);
        test4player1turn1 (game);
    }

    //player0 plays a D
    static void test4player0turn1 (Game game) {
        playerMove move;
        Card card;
        printf("test4player0turn1\n");
        printf("formerly had %d cards in hand\n", playerCardCount(game, 0));

        //find the required card
        card = findCardInHand(game, 0, D, 1, 1);
        assert(card != NULL);
        //set the color to something new
        move.nextColor = 2;
        //play the found card
        move.action = PLAY_CARD;
        move.card = card; 
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        checkTopDiscard(game, card);
        printf("Has played D, 1, 1\n");
        printf("now has %d cards in hand\n", playerCardCount(game, 0));

        //end turn
        move.action = END_TURN;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Turn has ended\n\n");
    }

    //tries to play a card
    static void test4player1turn1 (Game game) {
        playerMove move;
        Card card;
        printf("test4player1turn1\n");
        printf("formerly had %d cards in hand\n", playerCardCount(game, 0));

        //test that playing a wrong card doesn't work
        card = findCardInHand(game, 1, 3, 3, 3);
        assert(card != NULL);
        move.action = PLAY_CARD;
        move.card = card;
        printf("Testing incorrect card\n");
        assert(isValidMove(game, move) == FALSE);

        //test that a card with the new color is fine
        card = findCardInHand(game, 1, 2, 2, 2);
        assert(card != NULL);
        move.action = PLAY_CARD;
        move.card = card; 
        printf("Testing card with only correct new suit\n");
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        checkTopDiscard(game, card);
        printf("Has played 1, 2, 2\n");
        printf("now has %d cards in hand\n", playerCardCount(game, 0));

        //end turn
        move.action = END_TURN;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Turn has ended\n\n");
    }

//=============TEST FIVE===============\\
//Testing the zero card function
    static void test5_play_0 (void){
        int deck_size = 50;
        value values[] = {
            1, 0, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        color colors[] = {
            1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        suit suits[] = {
            1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        Game game = newGame(deck_size, values, colors, suits);
        printf("~~~~~~~~~~~TEST FIVE~~~~~~~~~~~\n");
        test5player0turn1 (game);
        test5player1turn1 (game);
    }

    //player0 plays a D
    static void test5player0turn1 (Game game) {
        playerMove move;
        Card card;
        printf("test5player0turn1\n");
        printf("formerly had %d cards in hand\n", playerCardCount(game, 0));

        //find the required card
        card = findCardInHand(game, 0, 1, 1, 1);
        assert(card != NULL);
        //play the found card
        move.action = PLAY_CARD;
        move.card = card; 
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        checkTopDiscard(game, card);
        printf("Has played 1, 1, 1\n");
        printf("now has %d cards in hand\n", playerCardCount(game, 0));

        //end turn
        move.action = END_TURN;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Turn has ended\n\n");
    }

    //tries to play a card
    static void test5player1turn1 (Game game) {
        playerMove move;
        Card card;
        printf("test5player1turn1\n");
        printf("formerly had %d cards in hand\n", playerCardCount(game, 0));

        //test that playing a wrong card doesn't work
        card = findCardInHand(game, 1, 2, 2, 2);
        assert(card != NULL);
        move.action = PLAY_CARD;
        move.card = card;
        printf("Testing incorrect card\n");
        assert(isValidMove(game, move) == FALSE);

        //test that a card with the new color is fine
        card = findCardInHand(game, 1, 0, 2, 2);
        assert(card != NULL);
        move.action = PLAY_CARD;
        move.card = card; 
        printf("Testing card with only 0 correct\n");
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        checkTopDiscard(game, card);
        printf("Has played 0, 2, 2\n");
        printf("now has %d cards in hand\n", playerCardCount(game, 0));

        //end turn
        move.action = END_TURN;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Turn has ended\n\n");
    }

//=============TEST SIX===============\\
//Testing insufficient card situation
    static void test6_empty_deck (void){
        int deck_size = 29;
        value values[] = {
            DRAW_TWO, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        color colors[] = {
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        suit suits[] = {
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
            1, 1, 1, 1, 1, 1, 1, 1, 1
        };

        Game game = newGame(deck_size, values, colors, suits);
        printf("~~~~~~~~~~~TEST SIX~~~~~~~~~~~\n");
        test6player0turn1 (game);
        test6player1turn1 (game);
        test6player2turn1 (game);
    }

    static void test6player0turn1 (Game game) {
        playerMove move;
        Card card;
        printf("test6player0turn1\n");

        //Draw a card from a the deck
        move.action = DRAW_CARD;
        printf("Drawing from an empty deck\n");
        assert(isValidMove(game, move) == TRUE);
        printf("Was able to recover discardPile as deck\n");
        playMove(game, move);

        //end turn
        move.action = END_TURN;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Turn has ended\n\n");
    }

    static void test6player1turn1 (Game game) {
        playerMove move;
        Card card;
        printf("test6player1turn1\n");

        //Draw a card from an empty
        move.action = DRAW_CARD;
        assert(isValidMove(game, move) == TRUE);
        printf("Draw the final card\n");
        playMove(game, move);
        assert(isValidMove(game, move) == FALSE);


        //end turn
        move.action = END_TURN;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Turn has ended\n\n");
    }

    static void test6player2turn1 (Game game) {
        playerMove move;
        Card card;
        printf("test6player2turn1\n");

        //Draw a card from an empty
        move.action = DRAW_CARD;
        printf("Try and draw\n");
        assert(isValidMove(game, move) == FALSE);
        printf("Was unable to draw as expected\n");
        printf("currentPlayer %d\n", currentPlayer(game));

        //find the required card
        card = findCardInHand(game, 2, 1, 1, 1);
        assert(card != NULL);
        //play the found card
        move.action = PLAY_CARD;
        move.card = card; 
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        checkTopDiscard(game, card);
        printf("Has played 1, 1, 1\n");

        //end turn
        move.action = END_TURN;
        assert(isValidMove(game, move) == TRUE);
        playMove(game, move);
        printf("Turn has ended\n\n");
    }

//===============Template Moves===============\\
//A template for future use
/*
static void test1_draw_two_once (void){
    int deck_size = 50;
    value values[] = {
        DRAW_TWO, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    };

    color colors[] = {
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    };

    suit suits[] = {
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    };

    Game game = newGame(deck_size, values, colors, suits);
    printf("~~~~~~~~~~~TEST ONE~~~~~~~~~~~\n");
    test1player0turn1 (game);
    test1player1turn1 (game);
}

static void test1player0turn1 (Game game) {
    playerMove move;
    Card card;
    printf("test1player0turn1\n");

    //find the required card
    card = findCardInHand(game, 0, 0, 0, 0);
    assert(card != NULL);
    //play the found card
    move.action = PLAY_CARD;
    move.card = card; 
    assert(isValidMove(game, move) == TRUE);
    playMove(game, move);
    checkTopDiscard(game, card);
    printf("Has played 0, 0, 0\n");

    //end turn
    move.action = END_TURN;
    assert(isValidMove(game, move) == TRUE);
    playMove(game, move);
    printf("Turn has ended\n\n");
}
*/

//===============Checking Functions===============\\
// Checks various aspects of the game's state
// Courtesy of Jacob Mikkelson 10/10/18 from the provided file Stage2.c
// NOTE THIS FUNCTION WAS NOT CREATE BY ME, TANSON WANG
static void checkGameState(Game game, int expectedPlayer, int expectedTurn,
        int expectedMoves, int expectedPreviousPlayer, int expectedTopDiscardTurn){

        assert(currentPlayer(game) == expectedPlayer);
        assert(currentTurn(game) == expectedTurn);
        assert(numTurns(game) == expectedTurn + 1);
        assert(currentTurnMoves(game) == expectedMoves);
        assert(getPreviousTurnPlayer(game) == expectedPreviousPlayer);
        assert(getTopDiscardTurnNumber(game) == expectedTopDiscardTurn);
    }

// Tries to find a card with the given values in a player's hand and returns it
// Courtesy of Jacob Mikkelson 10/10/18 from the provided file Stage2.c
// NOTE THIS FUNCTION WAS NOT CREATE BY ME, TANSON WANG
static Card findCardInHand(Game game, int player, value v, color c, suit s){
    int i = 0;
    Card card = getHandCard(game, player, i);
    while (card != NULL){
        if (cardMatchesComponents(card, v, c, s)){
            return card;
        }

        i++;
        card = getHandCard(game, player, i);
    }

    return NULL;
}

// Tries to find a card with the given values in the deck and returns it
// Courtesy of Jacob Mikkelson 10/10/18 from the provided file Stage2.c
// NOTE THIS FUNCTION WAS NOT CREATE BY ME, TANSON WANG
static Card findCardInDeck(Game game, value v, color c, suit s){
    int i = 0;
    Card card = getDeckCard(game, i);
    while (card != NULL){
        if (cardMatchesComponents(card, v, c, s)){
            return card;
        }

        i++;
        card = getDeckCard(game, i);
    }

    return NULL;
}

// Checks if the top of the discard value is a particular card
// Courtesy of Jacob Mikkelson 10/10/18 from the provided file Stage2.c
// NOTE THIS FUNCTION WAS NOT CREATE BY ME, TANSON WANG
static void checkTopDiscard(Game game, Card card){
    assert(getDiscardPileCard(game, 0) == card);
}

// Compare a card to the various components of a card
// Courtesy of Jacob Mikkelson 10/10/18 from the provided file Stage2.c
// NOTE THIS FUNCTION WAS NOT CREATE BY ME, TANSON WANG
static int cardMatchesComponents(Card card, value v, color c, suit s){
    return cardValue(card) == v && cardColor(card) == c && cardSuit(card) == s;
}

// Print cards by their components in a nice format
// Courtesy of Jacob Mikkelson 10/10/18 from the provided file Stage2.c
// NOTE THIS FUNCTION WAS NOT CREATE BY ME, TANSON WANG
static void printCardByComponents(value v, color c, suit s){
    char* valueStrings[NUM_VALUES] = {
        "ZERO", "ONE", "DRAW_TWO", "THREE", "FOUR",
        "FIVE", "SIX", "SEVEN", "EIGHT", "NINE",
        "A", "B", "C", "D", "E", "F"
    };

    char* colorStrings[NUM_COLORS] = {
        "RED", "BLUE", "GREEN", "YELLOW", "PURPLE"
    };

    char* suitStrings[NUM_SUITS] = {
        "HEARTS", "DIAMONDS", "CLUBS", "SPADES", "QUESTIONS"
    };

    printf("%s %s of %s", colorStrings[c], valueStrings[v], suitStrings[s]);
}


/*
//So previous testing work that may or may not have cost me 2 days of coding
//to fail, miserably at that. TT^TT
int main (void) {

    static int deck_size = 50;
    value values[] = {
        ZERO, ONE, DRAW_TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE,
        A, B, C, D, E, F, ZERO, ONE, DRAW_TWO, THREE,
        FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, A, B, C, D,
        E, F, ZERO, ONE, DRAW_TWO, THREE, FOUR, FIVE, SIX, SEVEN,
        EIGHT, NINE, A, B, C, D, E, F, ZERO, ONE
    };

    color colors[] = {
        RED, RED, RED, RED, RED, RED, RED, RED, RED, RED,
        BLUE, BLUE, BLUE, BLUE, BLUE, BLUE, BLUE, BLUE, BLUE, BLUE,
        GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN,
        YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW,
        PURPLE, PURPLE, PURPLE, PURPLE, PURPLE, PURPLE, PURPLE, PURPLE, PURPLE, PURPLE
    };

    suit suits[] = {
        HEARTS, DIAMONDS, CLUBS, SPADES, QUESTIONS, HEARTS, DIAMONDS, CLUBS, SPADES, QUESTIONS,
        HEARTS, DIAMONDS, CLUBS, SPADES, QUESTIONS, HEARTS, DIAMONDS, CLUBS, SPADES, QUESTIONS,
        HEARTS, DIAMONDS, CLUBS, SPADES, QUESTIONS, HEARTS, DIAMONDS, CLUBS, SPADES, QUESTIONS,
        HEARTS, DIAMONDS, CLUBS, SPADES, QUESTIONS, HEARTS, DIAMONDS, CLUBS, SPADES, QUESTIONS,
        HEARTS, DIAMONDS, CLUBS, SPADES, QUESTIONS, HEARTS, DIAMONDS, CLUBS, SPADES, QUESTIONS
    };

    Game thingy = newGame(deck_size, values, colors, suits);

    printf("Player has %d cards\n", playerCardNum(thingy ,1));

    node *nani = thingy->players[0]->handList;
    while (nani != NULL) {
    	printf("%d\n", nani->card->suit);

    	nani = nani->next;
    }

		int cancer = 0;
		node *curr;
		curr = thingy->deck;

		while (curr != NULL ) {
			//printf("hotdamn\n");
			printf("%d %d ~", curr->card->suit, cancer);
			curr = curr->next;
			cancer++;
		}
	*/
	/*    //printf("%d\n", topCardColor(thingy->discardPile));
	    //printf("neckmaself %d\n", thingy->players[1]->handList->card->color);
	    thingy->discardPile = playCard(thingy->players[1]->handList, thingy->players[1]->handList->card, thingy->discardPile);
		// printf("%d\n", topCardColor(thingy->discardPile));

	    playerMove *action = calloc(1, sizeof(playerMove));
	    while (thingy->GameWinner == NOT_FINISHED) {
	    	printf("ded\n");
	    	thingy->currentTurnMoves = 1;
	    	action = decideMove(thingy);
	   		action->action = decideMove(thingy).action;
	   		action->nextColor = decideMove(thingy).nextColor;
	   		action->card = decideMove(thingy).card;
	    	if (thingy->currentPlayer == 0){
	    		
	    		while (action->action != END_TURN) {
		    		action->action = decideMove(thingy).action;
		    		action->nextColor = decideMove(thingy).nextColor;
		    		action->card = decideMove(thingy).card;
		    		if (action->action == DRAW_CARD) {
		    			drawCard(thingy, 0);
		    			thingy->currentTurnMoves = thingy->currentTurnMoves + 1;
		    		}
		    		if(action->action == PLAY_CARD) {
		    			
		    		}
		    	}
		    	thingy->currentPlayer = 1;
		    }
		    int i = 0;
		    while (i < 4) {
		    	if (playerCardNum(thingy, i) == 1){
		    		thingy->GameWinner = i;
		    	}
		    }

		    if (thingy->deck == NULL && playerCardNum(thingy, 0) != 1) {
		    	thingy->GameWinner = NO_WINNER;
		    }
	    }

	   
	    return 0;
	}
*/
