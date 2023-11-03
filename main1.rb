require 'pry-byebug'

class Connect4
  attr_reader :play_game, :number_of_players, :current_player, :current_player_name, :player1, :player2, :game_over,
              :game_board, :current_boxes_filled, :game_board_width, :result

  def initialize
    @play_game = false
    @player2 = 'the AI'
  end

  def play
    ask_to_play
    return unless @play_game == true

    one_or_two_players
    player_names
    clear_screen
    set_up_board
    game_loop
  end

  def ask_to_play
    puts 'Would you like to play Connect 4?'
    answer = gets.chomp.downcase
    unless %w[yes y].include?(answer)
      puts 'Ok, have a nice day.'
      return
    end
    @current_player = 1
    @play_game = true
  end

  def one_or_two_players
    puts 'Is there one or two players?'
    answer = gets.chomp.downcase
    if %w[1 one].include?(answer)
      @number_of_players = 1
    elsif %w[2 two].include?(answer)
      @number_of_players = 2
    else
      puts 'Invalid entry. This game is for one or two players only.'
      one_or_two_players
    end
  end

  def player_names
    puts 'Enter name for player 1'
    @player1 = gets.chomp
    @current_player_name = @player1
    return unless @number_of_players == 2

    puts 'Enter name for player 2'
    @player2 = gets.chomp
  end

  def set_up_board
    @game_board = GameBoard.new
    @current_boxes_filled = 0
    @game_board_width = @game_board.width
  end

  def game_loop
    until game_over == true
      @game_board.print_board
      whos_turn?
      @current_boxes_filled += 1
      game_over?
      switch_current_player
    end
    game_finish
  end

  def whos_turn?
    if current_player == 1
      select_column
    elsif current_player == 2 && number_of_players == 2
      select_column
    else
      computer_move
    end
  end

  def select_column
    puts "#{@current_player_name}, please choose a column."
    column = gets.chomp.to_i
    valid = @game_board.validate(column)

    if valid
      clear_screen
      @game_board.make_move(column, current_player)
    else
      select_column
    end
  end

  def switch_current_player
    @current_player = current_player == 2 ? 1 : 2
    @current_player_name = current_player == 2 ? player2 : player1
  end

  def computer_move
    clear_screen
    random_column = rand(1..@game_board_width)
    valid_choice = @game_board.validate(random_column)
    if valid_choice
      @game_board.make_move(random_column, 2)
    else
      computer_move
    end
  end

  def game_over?
    if winner?
      @game_over = true
      @result = @current_player_name
    elsif full_board?
      @game_over = true
      @result = 'tie'
    end
  end

  def full_board?
    all_boxes_filled = @current_boxes_filled == @game_board.number_of_boxes
    @game_over = all_boxes_filled
  end

  def winner?
    return true if @game_board.winner_check_rows(current_player)

    return true if @game_board.winner_check_columns(current_player)

    return true if @game_board.winner_check_diagonal_back_slash(current_player)

    return true if @game_board.winner_check_diagonal_forward_slash(current_player)

    false
  end

  def game_finish
    @game_board.print_board
    if @result == 'tie'
      puts 'Congratulations to no one. This game is a draw.'
    else
      puts "The winner is #{result}!!\nCongratulations, really, good job #{result}"
    end
  end

  def clear_screen
    return if $PROGRAM_NAME != __FILE__

    if RUBY_PLATFORM =~ /win32|win64|mingw|mswin/
      system('cls')
    else
      system('clear')
    end
  end
end

class GameBoard
  attr_accessor :board, :player1_board, :player2_board, :number_of_boxes

  def initialize
    @board = create_empty_board
    @player1_board = create_empty_board
    @player2_board = create_empty_board
    @number_of_boxes = @board.length * @board[0].length
  end

  def print_board
    3.times { puts }
    board.each_with_index do |row, row_index|
      line = '     |'
      row.each_index do |column_index|
        line << if board[row_index][column_index].zero?
                  '.|'
                elsif board[row_index][column_index] == 1
                  'x|'
                else
                  'o|'
                end
      end
      puts line
    end
    width = board[0].length
    print_bottom_line(width)
  end

  def print_bottom_line(width)
    bottom_line = '      '
    width.times do |num|
      bottom_line << "#{num + 1} "
    end
    puts "\n#{bottom_line}\n\n\n\n"
  end

  def validate(column)
    message = if !(1..board.length).include?(column)
                "Your choice is invalid. Please choose a column between 1 and #{board.length}."
              elsif board[0][column - 1] != 0
                'The column you have chosen is full'
              end

    if message
      puts "\n#{message}\n"
      false
    else
      true
    end
  end

  def make_move(column, current_player)
    row = 0
    @board.each_with_index do |line, index|
      break unless line[column - 1].zero?

      row = index
    end
    @board[row][column - 1] = current_player
    if current_player == 1
      @player1_board[row][column - 1] = 1
    else
      @player2_board[row][column - 1] = 2
    end
  end

  def width
    @board[0].length
  end

  def winner_check_rows(player)
    testing_board = player == 1 ? player1_board : player2_board
    count = 0
    testing_board.each do |row|
      row.each do |cell|
        if cell != 0
          count += 1
          return true if count == 4
        else
          count = 0
        end
      end
      count = 0
    end
    false
  end

  def winner_check_columns(player)
    testing_board = player == 1 ? player1_board : player2_board
    count = 0
    number_of_rows = testing_board.length
    testing_board[0].each_index do |index|
      number_of_rows.times do |row_number|
        if testing_board[row_number][index] != 0
          count += 1
          return true if count == 4
        else
          count = 0
        end
      end
      count = 0
    end
    false
  end

  def winner_check_diagonal_back_slash(player)
    testing_board = player == 1 ? player1_board : player2_board
    number_of_rows = testing_board.length
    number_of_columns = testing_board[0].length

    number_of_rows.times do |i|
      number_of_columns.times do |j|
        count = 0
        while i + count < number_of_rows && j + count < number_of_columns && testing_board[i + count][j + count] == player
          count += 1
          return true if count == 4
        end
      end
    end
    false
  end

  def winner_check_diagonal_forward_slash(player)
    testing_board = player == 1 ? player1_board : player2_board
    number_of_rows = testing_board.length
    number_of_columns = testing_board[0].length

    number_of_rows.times do |i|
      number_of_columns.times do |j|
        count = 0
        while i + count < number_of_rows && j - count >= 0 && testing_board[i + count][j - count] == player
          count += 1
          return true if count == 4
        end
      end
    end
    false
  end

  private

  def create_empty_board
    empty_board = []
    7.times do
      empty_board << Array.new(7, 0)
    end
    empty_board
  end
end

if $PROGRAM_NAME == __FILE__
  game = Connect4.new
  game.play
end
