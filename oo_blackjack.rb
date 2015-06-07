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

require 'pry'

class Deck
  attr_accessor :cards

  def initialize
    @cards = create_cards
    @cards.shuffle!
  end

  def create_cards
    suits = ['H', 'D', 'S', 'C']
    characters = ['A', '2', '3', '4', '5', '6', '7',
                   '8', '9', '10', 'J', 'Q', 'K']
    values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]

    one_full_deck = []

    suits.each do |suit|
      characters.each_with_index do |character, i|
        one_full_deck << Card.new(suit, character, values[i])
      end
    end

    one_full_deck
  end

  def deal_card(person)
    card = @cards.pop
    person.cards << card
  end

end

class Card
  attr_reader :suit, :character, :value

  def initialize(suit, character, value)
    @suit = suit
    @character = character
    @value = value
  end
end

class GameMember
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def print_cards
    whole_hand_string = String.new
    @cards.each do |c|
      whole_hand_string  << '  ' << c.character << c.suit
    end
    whole_hand_string
  end

  def sum_cards
    @cards.inject(0) { |sum, card| sum + card.value }
  end

  def busted?
    sum_cards > 21
  end

end

class Dealer < GameMember

end


class Player < GameMember

  def hit?
    puts "Hit (h) or stay (s)?"
    choice = gets.chomp.downcase
    until ['h', 's'].include?(choice)
      puts 'Please re-enter - Hit (h) or stay (s) ?'
      choice = gets.chomp.downcase
    end
    choice == 'h'
  end
end

class Game
  attr_accessor :player, :dealer, :deck

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    @deck = Deck.new
  end

  def initial_deal
    deck.deal_card(@player)
    deck.deal_card(@dealer)
    deck.deal_card(@player)
    deck.deal_card(@dealer)
  end

  def display
    system 'clear'
    puts "Dealer has #{@dealer.print_cards}"
    puts "You have #{@player.print_cards}"
    puts ""
  end

  def players_turn
    while player.hit? && !player.busted?
      deck.deal_card(@player)
      display
    end
  end

  def dealers_turn
    while dealer.sum_cards < 17
      deck.deal_card(@dealer)
      display
    end
  end

  def compare
    if player.sum_cards > dealer.sum_cards
      puts 'You win!'
    elsif dealer.sum_cards > player.sum_cards
      puts 'You lose!'
    else
      puts "It's a draw!"
    end
  end

  def play
    initial_deal
    display
    players_turn
    if player.busted?
      puts 'Busted! You lose! >< '
    else
      dealers_turn
      if dealer.busted?
        puts 'Dealer has busted! You win!'
      else
        compare
      end
    end
  end

end

Game.new.play
