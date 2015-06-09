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
    deck = []

    suits.each do |suit|
      characters.each do |character|
        deck << Card.new(suit, character)
      end
    end

    deck
  end

  def deal_card(person)
    person.cards << @cards.pop
  end

end

class Card
  attr_reader :suit, :character

  def initialize(suit, character)
    @suit = suit
    @character = character
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
    sum = @cards.inject(0) do |a, e|
      if ['J', 'Q', 'K'].include?(e.character)
        a + 10
      elsif e.character == 'A'
        a + 11
      else
        a + e.character.to_i
      end
    end

    aces.times do
      sum -= 10 if sum > Game::BLACKJACK_AMOUNT
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
    sum_cards > Game::BLACKJACK_AMOUNT
  end

  def blackjack?
    sum_cards == Game::BLACKJACK_AMOUNT && cards.count == 2
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

  BLACKJACK_AMOUNT = 21
  DEALER_MIN_STAY = 17

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


  def display_name(game_member)
    spaces = String.new
    (12 - game_member.name.length).times { spaces << ' ' }
    game_member.name + spaces
  end

  def display(message)
    sleep 0.8
    system 'clear'
    puts "\n wins\n"
    puts "  #{@dealer.wins}    #{display_name(dealer)}" \
         "#{@dealer.print_cards}\n\n"
    puts "  #{@player.wins}    #{display_name(player)}" \
         "#{@player.print_cards}\n\n"
    puts "#{message}"
  end

  def display_hidden
    sleep 0.8
    system 'clear'
    puts "\n wins\n"
    puts "  #{@dealer.wins}    #{display_name(dealer)}" \
         "#{@dealer.print_cards_hidden}\n\n"
    puts "  #{@player.wins}    #{display_name(player)}" \
         "#{@player.print_cards}\n\n"
  end

  def players_turn
    while !player.busted? && player.hit?
      deck.deal_card(@player)
      display_hidden
    end
  end

  def dealers_turn
    display('')
    while dealer.sum_cards < DEALER_MIN_STAY
      deck.deal_card(@dealer)
      display('')
    end
  end

  def result_display
    "#{player.sum_cards} vs. #{dealer.sum_cards}"
  end

  def result
    if player.sum_cards == dealer.sum_cards
      display("It's a push!  (#{result_display})")
    elsif player.sum_cards > dealer.sum_cards
      player.add_win
      if player.sum_cards == BLACKJACK_AMOUNT && player.cards.count == 2
        display('You win with Blackjack! (^v^)V')
      else
        display("You win!  (#{result_display})")
      end
    else
      dealer.add_win
      if dealer.sum_cards == BLACKJACK_AMOUNT && dealer.cards.count == 2
        display('Dealer wins with Blackjack! (>_<)')
      else
        display("You lose!  (#{result_display})")
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
      sleep 1
      puts "\nPlay again? (y/n)"
      break if gets.chomp.downcase == 'n'
    end
  end

end

Session.new.start
