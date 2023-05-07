#!/usr/bin/env python
from random import shuffle
from inspect import isclass

# Pinochle deck definition
duplicate_cards_in_pinochle_deck=2 # There are two of each of the following cards in a deck
ranks=['9','J','Q','K','10','A']
suits=['hearts','clubs','diamonds','spades']
suits_emoji={
    'hearts':   f"\u2661",
    'clubs':    f"\u2663",
    'diamonds': f"\u2662",
    'spades':   f"\u2660"
}
scoring_rules={ #Points per each of the following
    'pinochle':               4,
    'double_pinochle':       30,
    'marriage_trump':         4,
    'double_marriage_trump': 30,
    'off_marriage':           2,
    '9_trump':                0,
    'A_round':                0,
    'double_A_round':         0,
    'K_round':                0,
    'double_K_round':         0,
    'Q_round':                0,
    'double_Q_round':         0,
    'J_round':                0,
    'double_J_round':         0
}
9s_for_misdeal=5 # Number of 9s needed for a mis-deal


class Card:
    def __init__(self,suit,rank):
        if suit not in suits or rank not in ranks:
            raise ValueError("Invalid suit or rank, cannot instantiate Card.")
        self.suit=suit
        self.rank=rank
    def print_text(self):
        return str(self.rank)+" of "+str(self.suit)
    def print_pretty(self):
        return str(self.rank)+str(suits_emoji[self.suit])
    def __str__(self):
        return self.print_pretty()
    def __lt__(self,other_card):
        assert isclass(other_card,Card)
        return ranks.index(self.rank) < ranks.index(other_card.rank)
    def __gt__(self,other_card):
        assert isclass(other_card,Card)
        return ranks.index(self.rank) > ranks.index(other_card.rank)
    def __le__(self,other_card):
        assert isclass(other_card,Card)
        return ranks.index(self.rank) >= ranks.index(other_card.rank)
    def __ge__(self,other_card):
        assert isclass(other_card,Card)
        return ranks.index(self.rank) >= ranks.index(other_card.rank)


class Deck:
    def __init__(self):
        
        # Define constraints for a deck
        self.max_num_a_card=duplicate_cards_in_pinochle_deck # Number of duplicate cards in a filled deck
        self.min_num_a_card=0 # Number of duplicate cards in a filled deck

        # Declare the deck default attributes
        self.deck=list() # This is the order tracker
        self.dict=dict() # This tracks the number of each type of card in the deck
        for suit in suits:
            self.dict(suit)=dict()
        self.empty() # Start with an empty deck by default
    
    def __str__(self):
        return str([str(card) for card in self.deck])
    
    def assert_card_count(card): # Assert that the count of a card in the deck is within the bounds
        assert self.dict[card.suit][card.rank] <= self.max_num_a_card
        assert self.dict[card.suit][card.rank] <= self.max_num_a_card
        return

    def empty(self): # Remove all cards from the deck
        for suit in suits:
            for rank in ranks:
                self.dict[suit][rank]=0
        del self.deck[:] # Empty the deck order tracker
        return

    def append(self,card): # Add a card to the top of the deck
        assert isclass(card,Card)
        self.deck.append(card)
        self.dict[card.suit][card.rank]+=1
        self.assert_card_count(card)
        return

    def fill(self): # Fill the deck with all possible cards
        self.empty()
        for suit in suits:
            for rank in ranks:
                self.dict[suit][rank]=self.max_num_a_card
                for i in self.range(max_num_a_card):
                    self.append(Card(suit,rank))
        return

    def pop(self): # Take a card off the top of the deck stack
        card=self.deck.pop()
        self.dict[card.suit][card.rank] -= 1
        self.assert_card_count(card)
        return card

    def pull(self,card): #Pull a card out of the deck with particular type
        assert isclass(card,Card)
        for i in len(self.deck): # Iterate over the items in the deck
            if self.deck[i] == card:
                del self.deck[i]
                self.dict[card.suit][card.rank] -= 1
                self.assert_card_count(card)
                return card
            else:
            return False

    def shuffle(self): # Order the deck randomly
        self.deck=random.shuffle(self.deck)
        return
    def sort(self): # Order the deck logically like how you'd want to read it
        del self.deck[:] # Empty the deck order tracker
        for suit in suits:
            for rank in list(reversed(ranks)):
                for i in range(self.dict[suit][rank]):
                    self.deck.append(Card(suit,rank))
        return

class Meld:
    def __init__(self,hand,trump,scoring_rules=scoring_rules): # You have to pass in a hand to meld
        assert trump in suits
        self.scoring_rules=scoring_rules
        self.scores=self.score()
    def score(self):
        self.meldt_counts={
            'pinochle':              0,
            'double_pinochle':       0,
            'marriage_trump':        0,
            'double_marriage_trump': 0,
            'off_marriage':          0,
            '9_trump':               0,
            'A_round':               0,
            'double_A_round':        0,
            'K_round':               0,
            'double_K_round':        0,
            'Q_round':               0,
            'double_Q_round':        0,
            'J_round':               0,
            'double_J_round':        0
        }
        self.meldt_counts['pinochle']      =self.score_pinochles()
        self.meldt_counts['marriage_trump']=self.score_marriages()
        self.meldt_counts['off_marriage']=self.score_marriages()
        self.meldt_counts['9_trump']       =self.score_9s()

        self.score=sum(self.meldt_counts(key)*self.scoring_rules(key) for key in self.meldt_counts())

