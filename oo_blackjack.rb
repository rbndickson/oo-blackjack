# oo_blackjack.rb

class Deck
  attr_accessor :cards

  def initialize
    @cards = create_cards
    @cards.shuffle!
  end

  def create_cards
    suits = ["\xE2\x99\xA5", "\xE2\x99\xA6", "\xE2\x99\xA3", "\xE2\x99\xA0"]
    characters = %w(A 2 3 4 5 6 7 8 9 10 J Q K)
    values = [11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]

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
    whole_hand_string = ''
    @cards.each do |c|
      whole_hand_string << '  ' << c.character << c.suit
    end
    whole_hand_string
  end

  def print_cards_hidden
    '' << '  **  ' << @cards[1].character << @cards[1].suit
  end

  def sum_cards
    sum = @cards.inject(0) { |a, e| a + e.value }
    aces.times do
      sum -= 10 if sum > 21
    end
    sum
  end

  def aces
    aces = 0
    @cards.each do |c|
      aces += 1 if c.character == 'A'
    end
    aces
  end

  def busted?
    sum_cards > 21
  end

  def blackjack?
    sum_cards == 21 && aces == 1
  end

end

class Dealer < GameMember

end

class Player < GameMember

  def hit?
    puts 'Hit (h) or stay (s)?'
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

  def pause_puts(message)
    sleep 0.5
    puts message
  end

  def initial_deal
    2.times do
      deck.deal_card(@player)
      deck.deal_card(@dealer)
    end
  end

  def display
    system 'clear'
    puts "\n Dealer     #{@dealer.print_cards}"
    puts "\n You        #{@player.print_cards}\n\n"
  end

  def display_hidden
    system 'clear'
    puts "\n Dealer     #{@dealer.print_cards_hidden}"
    puts "\n You        #{@player.print_cards}\n\n"
  end

  def players_turn
    while !player.busted? && player.hit?
      sleep 1
      deck.deal_card(@player)
      display_hidden
    end
  end

  def dealers_turn
    sleep 0.5
    display
    while dealer.sum_cards < 17
      sleep 1
      deck.deal_card(@dealer)
      display
    end
  end

  def compare
    sleep 0.5
    if player.sum_cards > dealer.sum_cards
      pause_puts 'You win!'
    elsif dealer.sum_cards > player.sum_cards
      pause_puts 'You lose!'
    else
      pause_puts "It's a draw!"
    end
  end

  def play_one_game
    initial_deal
    display_hidden
    if player.blackjack?
      compare
    else
      players_turn
      if player.busted?
        pause_puts 'You have busted! You lose! (>_<) '
      else
        dealers_turn
        if dealer.busted?
          pause_puts 'Dealer has busted! You win!'
        else
          compare
        end
      end
    end
  end

end

class Session

  def start
    loop do
      Game.new.play_one_game
      sleep 0.5
      puts 'Play again? (y/n)'
      break if gets.chomp.downcase == 'n'
    end
  end

end

Session.new.start
