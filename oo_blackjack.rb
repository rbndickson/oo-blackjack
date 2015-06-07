# requirements

# You have 1 player and 1 dealer.
# There is a deck of cards.
# The cards are shuffled.
# the 2 cards each are dealt.
# check if player has blackjack.
# Player can hit or stay until stay or bust. (Player's turn)
# If player has stayed, dealer takes turn.

# player
#   choose hit or stay
#
# dealer
#   play / take_turn
#
# deck
#   shuffle
#   calclate_score
#
# card


class Deck
  attr_accessor :cards

  def initialize
    @cards = create_cards
    @cards.shuffle!
  end

  def create_cards
    suits = ['H', 'D', 'S', 'C']
    charachters = ['A', '2', '3', '4', '5', '6', '7',
                   '8', '9', '10', 'J', 'Q', 'K']
    values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]

    one_full_deck = []

    suits.each do |suit|
      charachters.each_with_index do |charachter, i|
        one_full_deck << Card.new(suit, charachter, values[i])
      end
    end

    one_full_deck
  end

  def deal_card (person)
    card = @cards.pop
    person.hand << card
  end

end

class Card
  attr_reader :suit, :value

  def initialize(suit, charachter, value)
    @suit = suit
    @charachter = charachter
    @value = value
  end
end

class GameMember
  attr_accessor :hand

  def initialize
    @hand = []
  end

end

class Dealer < GameMember

end


class Player < GameMember

end

deck = Deck.new
dealer = Dealer.new
player = Player.new
deck.deal_card(dealer)
deck.deal_card(player)
deck.deal_card(dealer)
deck.deal_card(player)

p dealer
p player
p deck
