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

  def print_cards
    whole_hand_string = ''
    @cards.each do |c|
      whole_hand_string << '  ' << c.character << c.suit
    end
    whole_hand_string
  end

  def print_cards_hidden
    whole_hand_string = ''
    @cards.each_with_index do |c, i|
      if i == 0
        whole_hand_string << '  **'
      else
        whole_hand_string << '  ' << c.character << c.suit
      end
    end
    whole_hand_string
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

  def add_win
    @wins += 1
  end

end

class Dealer < GameMember
  attr_accessor :cards, :name, :wins

  def initialize
    @name = 'Dealer      '
    @cards = []
    @wins = 0
  end
end

class Player < GameMember
  attr_accessor :cards, :name, :wins

  def initialize
    @name = set_name
    @cards = []
    @wins = 0
  end

  def set_name
    puts 'Enter player name:'
    player_name = gets.chomp
    until player_name.length <= 12
      puts 'Name too long, please choose a name 12 characters or less.'
      player_name = gets.chomp
    end
    spaces = 12 - player_name.length
    spaces.times { player_name << ' ' }
    player_name
  end

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
  attr_accessor :deck, :player, :dealer

  def initialize(p, d)
    @deck = Deck.new
    @player = p
    @dealer = d
    return_previous_cards
  end

  def return_previous_cards
    player.cards = []
    dealer.cards = []
  end

  def initial_deal
    display('')
    2.times do
      deck.deal_card(@player)
      display_hidden
      deck.deal_card(@dealer)
      display_hidden
    end
  end

  def display(message)
    sleep 0.8
    system 'clear'
    puts "\n wins\n"
    puts "  #{@dealer.wins}    #{@dealer.name}#{@dealer.print_cards}\n\n"
    puts "  #{@player.wins}    #{@player.name}#{@player.print_cards}\n\n"
    puts "#{message}"
  end

  def display_hidden
    sleep 0.8
    system 'clear'
    puts "\n wins\n"
    puts "  #{@dealer.wins}    #{@dealer.name}#{@dealer.print_cards_hidden}\n\n"
    puts "  #{@player.wins}    #{@player.name}#{@player.print_cards}\n\n"
  end

  def players_turn
    while !player.busted? && player.hit?
      deck.deal_card(@player)
      display_hidden
    end
  end

  def dealers_turn
    display('')
    while dealer.sum_cards < 17
      deck.deal_card(@dealer)
      display('')
    end
  end

  def result
    if player.sum_cards == dealer.sum_cards
      display("It's a push!  (#{player.sum_cards} vs. #{dealer.sum_cards})")
    elsif player.sum_cards > dealer.sum_cards
      player.add_win
      if player.sum_cards == 21
        display('You win with Blackjack! (^v^)V')
      else
        display("You win!  (#{player.sum_cards} vs. #{dealer.sum_cards})")
      end
    else
      dealer.add_win
      if player.sum_cards == 21
        display('Dealer wins Blackjack! (>_<)')
      else
        display("You lose!  (#{player.sum_cards} vs. #{dealer.sum_cards})")
      end
    end
  end

  def play_one_game
    initial_deal
    if player.blackjack?
      result
    else
      players_turn
      if player.busted?
        dealer.add_win
        display('You have busted! You lose! (>_<)')
      else
        dealers_turn
        if dealer.busted?
          player.add_win
          display('Dealer has busted! You win!')
        else
          result
        end
      end
    end
  end

end

class Session
  attr_accessor :player, :dealer

  def initialize
    system 'clear'
    puts 'Welcome to Blackjack 0.2!'
    @player = Player.new
    @dealer = Dealer.new
  end

  def start

    loop do
      game = Game.new(player, dealer)
      game.play_one_game
      sleep 1.5
      puts "\nPlay again? (y/n)"
      break if gets.chomp.downcase == 'n'
    end
  end

end

Session.new.start
