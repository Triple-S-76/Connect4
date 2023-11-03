require_relative '../main1'
require 'pry-byebug'

describe Connect4 do
  context 'initial game setup' do

    it '#ask_to_play = no' do
      expect(subject).to receive(:puts).with('Would you like to play Connect 4?').once
      expect(subject).to receive(:gets).and_return('no')
      expect(subject).to receive(:puts).with('Ok, have a nice day.')
      subject.ask_to_play
    end

    it '#ask_to_play = N' do
      expect(subject).to receive(:puts).with('Would you like to play Connect 4?').once
      expect(subject).to receive(:gets).and_return('N')
      expect(subject).to receive(:puts).with('Ok, have a nice day.')
      subject.ask_to_play
    end

    it '#ask_to_play = yes' do
      expect(subject).to receive(:puts).with('Would you like to play Connect 4?')
      expect(subject).to receive(:gets).and_return('yes')
      expect(subject.play_game).to be false
      subject.ask_to_play
      expect(subject.play_game).to be true
    end

    it '#ask_to_play = Y' do
      expect(subject).to receive(:puts).with('Would you like to play Connect 4?')
      expect(subject).to receive(:gets).and_return('Y')
      expect(subject.play_game).to be false
      subject.ask_to_play
      expect(subject.play_game).to be true
    end

    it '#one_or_two_players = 1' do
      expect(subject).to receive(:puts).with('Is there one or two players?')
      expect(subject).to receive(:gets).and_return('1')
      expect(subject.number_of_players).to be_nil
      subject.one_or_two_players
      expect(subject.number_of_players).to eq(1)
    end

    it '#one_or_two_players = 2' do
      expect(subject).to receive(:puts).with('Is there one or two players?')
      expect(subject).to receive(:gets).and_return('2')
      expect(subject.number_of_players).to be_nil
      subject.one_or_two_players
      expect(subject.number_of_players).to eq(2)
    end

    it '#one_or_two_players = ONE' do
      expect(subject).to receive(:puts).with('Is there one or two players?')
      expect(subject).to receive(:gets).and_return('ONE')
      expect(subject.number_of_players).to be_nil
      subject.one_or_two_players
      expect(subject.number_of_players).to eq(1)
    end

    it '#one_or_two_players = TWO' do
      expect(subject).to receive(:puts).with('Is there one or two players?')
      expect(subject).to receive(:gets).and_return('TWO')
      expect(subject.number_of_players).to be_nil
      subject.one_or_two_players
      expect(subject.number_of_players).to eq(2)
    end

    it '#one_or_two_players = Bob' do
      expect(subject).to receive(:puts).with('Is there one or two players?').twice
      expect(subject).to receive(:gets).and_return('Bob', '2')
      expect(subject.number_of_players).to be_nil
      expect(subject).to receive(:puts).with('Invalid entry. This game is for one or two players only.').once
      subject.one_or_two_players
      expect(subject.number_of_players).to eq(2)
    end

    it '#player_names - When @number_of_players = 1: sets player name' do
      subject.instance_variable_set(:@number_of_players, 1)
      expect(subject).to receive(:puts).with('Enter name for player 1')
      expect(subject).to receive(:gets).and_return('John')

      subject.player_names
      expect(subject.player1).to eq('John')
      expect(subject.player2).to eq('the AI')
    end

    it '#player_names - When @number_of_players = 2: sets players names' do
      subject.instance_variable_set(:@number_of_players, 2)
      expect(subject).to receive(:puts).with('Enter name for player 1')
      expect(subject).to receive(:puts).with('Enter name for player 2')
      expect(subject).to receive(:gets).and_return('John', 'Doe')
      subject.player_names
      expect(subject.player1).to eq('John')
      expect(subject.player2).to eq('Doe')
    end

    it '#set_up_board - sends the GameBoard.new message' do
      game_board_double = double(GameBoard)
      expect(GameBoard).to receive(:new).and_return(game_board_double)
      expect(game_board_double).to receive(:width).and_return(99)
      expect(subject.game_board_width).to be_nil
      expect(subject.current_boxes_filled).to be_nil
      subject.set_up_board
      expect(subject.current_boxes_filled).to eq(0)
      expect(subject.game_board_width).to eq(99)
    end
  end

  context 'main game loop' do
    before(:each) do
      subject.instance_variable_set(:@player1, 'John')
      subject.instance_variable_set(:@player2, 'Doe')
      subject.instance_variable_set(:@current_player, 1)
      subject.instance_variable_set(:@current_player_name, 'John')
      subject.instance_variable_set(:@current_boxes_filled, 0)
    end

    it '#game_loop' do
      game_board_double = double('GameBoard')
      expect(game_board_double).to receive(:print_board).exactly(3).times

      subject.instance_variable_set(:@game_board, game_board_double)
      subject.instance_variable_set(:@number_of_players, 2)
      expect(subject).to receive(:whos_turn?).exactly(3).times

      expect(subject).to receive(:game_over).and_return(false, false, false, true)
      expect(subject).to receive(:switch_current_player).exactly(3).times
      expect(subject).to receive(:game_over?).exactly(3).times
      expect(subject).to receive(:game_finish).once
      expect(subject.current_boxes_filled).to eq(0)
      subject.game_loop
      expect(subject.current_boxes_filled).to eq(3)
    end

    it 'whos_turn? - player 1 turn against player 2' do
      subject.instance_variable_set(:@current_player, 1)
      subject.instance_variable_set(:@number_of_players, 2)
      expect(subject).to receive(:select_column).once
      subject.whos_turn?
    end

    it 'whos_turn? - player 1 turn against the pc' do
      subject.instance_variable_set(:@current_player, 1)
      subject.instance_variable_set(:@number_of_players, 1)
      expect(subject).to receive(:select_column).once
      subject.whos_turn?
    end

    it 'whos turn? - player 2 turn against player 1' do
      subject.instance_variable_set(:@current_player, 2)
      subject.instance_variable_set(:@number_of_players, 2)
      expect(subject).to receive(:select_column).once
      subject.whos_turn?
    end

    it 'whos turn? - computer turn against player 1' do
      subject.instance_variable_set(:@current_player, 2)
      subject.instance_variable_set(:@number_of_players, 1)
      expect(subject).to receive(:computer_move).once
      subject.whos_turn?
    end

    it '#select_column - player 1 (John) chooses column 3' do
      game_board_double = double('GameBoard')
      allow(game_board_double).to receive(:validate)
      subject.instance_variable_set(:@game_board, game_board_double)

      expect(subject).to receive(:puts).with('John, please choose a column.')
      expect(subject).to receive(:gets).and_return('3')
      expect(game_board_double).to receive(:validate).with(3).and_return(true)
      expect(game_board_double).to receive(:make_move).with(3, 1).once

      subject.select_column
    end

    it '#select_column - player 1 (John) chooses a letter, then an invalid number, then a valid number' do
      game_board_double = double('GameBoard')
      allow(game_board_double).to receive(:validate)
      subject.instance_variable_set(:@game_board, game_board_double)

      expect(subject).to receive(:puts).with('John, please choose a column.').exactly(3).times
      expect(subject).to receive(:gets).and_return('j', '9999', '3')
      expect(game_board_double).to receive(:validate).with(0).and_return(false)
      expect(game_board_double).to receive(:validate).with(9999).and_return(false)
      expect(game_board_double).to receive(:validate).with(3).and_return(true)
      expect(game_board_double).to receive(:make_move).with(3, 1).once

      subject.select_column
    end

    it '#switch_current_player - makes sure the current player is switched to player 2' do
      expect(subject.current_player).to eq(1)
      expect(subject.current_player_name).to eq('John')

      subject.switch_current_player
      expect(subject.current_player).to eq(2)
      expect(subject.current_player_name).to eq('Doe')
    end

    it '#switch_current_player - makes sure the current player is switched to player 1' do
      subject.instance_variable_set(:@current_player, 2)
      subject.instance_variable_set(:@current_player_name, 'Doe')
      expect(subject.current_player).to eq(2)
      expect(subject.current_player_name).to eq('Doe')

      subject.switch_current_player
      expect(subject.current_player).to eq(1)
      expect(subject.current_player_name).to eq('John')
    end

    it 'computer_move - makes sure make move is sent for valid move' do
      game_board_double = double(GameBoard)
      subject.instance_variable_set(:@game_board, game_board_double)
      expect(subject).to receive(:rand).and_return(7)
      expect(game_board_double).to receive(:validate).and_return(true)
      expect(game_board_double).to receive(:make_move).with(7, 2)
      subject.computer_move
    end

    it 'computer_move - makes sure make move is sent once for 3 invalid moves then 1 valid move' do
      game_board_double = double(GameBoard)
      subject.instance_variable_set(:@game_board, game_board_double)
      expect(subject).to receive(:rand).exactly(4).times.and_return(7)
      expect(game_board_double).to receive(:validate).and_return(false, false, false, true)
      expect(game_board_double).to receive(:make_move).with(7, 2).once
      subject.computer_move
    end

    it '#game_over? - when there is a winner' do
      expect(subject).to receive(:winner?).and_return(true)
      expect(subject.game_over).to be_nil
      expect(subject.result).to be_nil
      subject.game_over?
      expect(subject.game_over).to be true
      expect(subject.result).to eq('John')
    end

    it '#game_over? - when the board is full' do
      expect(subject).to receive(:winner?).once
      expect(subject).to receive(:full_board?).and_return(true).once
      expect(subject.game_over).to be_nil
      expect(subject.result).to be_nil
      subject.game_over?
      expect(subject.game_over).to be true
      expect(subject.result).to eq('tie')
    end

    it 'full_board? - checks for a full board' do
      expect(subject.game_over).to be_nil
      game_board_double = double('GameBoard')
      subject.instance_variable_set(:@game_board, game_board_double)
      expect(game_board_double).to receive(:number_of_boxes).and_return(100)
      subject.instance_variable_set(:@current_boxes_filled, 25)
      subject.full_board?
      expect(subject.game_over).to be false
    end

    it 'full board? - checks for a full board when board is full' do
      expect(subject.game_over).to be_nil
      game_board_double = double('GameBoard')
      subject.instance_variable_set(:@game_board, game_board_double)
      expect(game_board_double).to receive(:number_of_boxes).and_return(100)
      subject.instance_variable_set(:@current_boxes_filled, 100)
      subject.full_board?
      expect(subject.game_over).to be true
    end

    it '#game_finish - tie game' do
      game_board_double = double(GameBoard)
      subject.instance_variable_set(:@game_board, game_board_double)
      subject.instance_variable_set(:@result, 'tie')
      expect(game_board_double).to receive(:print_board).once
      expect(subject).to receive(:puts).with('Congratulations to no one. This game is a draw.')
      subject.game_finish
    end

    it '#game_finish - player 1 wins' do
      game_board_double = double(GameBoard)
      subject.instance_variable_set(:@game_board, game_board_double)
      subject.instance_variable_set(:@result, 'John')
      expect(game_board_double).to receive(:print_board).once
      expect(subject).to receive(:puts).with("The winner is John!!\nCongratulations, really, good job John")
      subject.game_finish
    end


  end
end

describe GameBoard do
  it '#create_empty_board - Initializes the empty board arrays' do
    empty_board_info = [
      [0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0]
    ]
    expect(subject.board).to eq(empty_board_info)
  end

  it '#print_board - Prints an empty board' do
    original_stdout = $stdout
    $stdout = StringIO.new
    subject.print_board
    output = $stdout.string
    $stdout = original_stdout
    expect(output).to include('|.|.|.|.|.|.|.|')
  end

  it '#print_board - Prints a game in progress' do
    subject.board[6][4] = 1
    subject.board[6][3] = 2
    subject.board[6][5] = 1
    subject.board[6][2] = 2
    subject.board[5][2] = 1
    subject.board[5][5] = 2
    subject.board[5][4] = 1
    subject.board[5][3] = 2

    original_stdout = $stdout
    $stdout = StringIO.new

    subject.print_board

    output = $stdout.string
    $stdout = original_stdout

    expect(output).to include('|.|.|x|o|x|o|.|')
    expect(output).to include('|.|.|o|o|x|x|.|')
  end

  it '#print_bottom_line - Prints the bottom line with 7 columns' do
    original_stdout = $stdout
    $stdout = StringIO.new

    subject.print_bottom_line(7)
    output = $stdout.string

    $stdout = original_stdout
    expect(output).to eq("\n      1 2 3 4 5 6 7 \n\n\n\n")
  end

  it '#print_bottom_line = Prints the bottom line with 20 columns' do
    original_stdout = $stdout
    $stdout = StringIO.new

    subject.print_bottom_line(20)
    output = $stdout.string
    $stdout = original_stdout
    expect(output).to eq("\n      1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 \n\n\n\n")
  end

  it '#validate - player chooses an invalid column: 55' do
    expect(subject).to receive(:puts).with("\nYour choice is invalid. Please choose a column between 1 and 7.\n")
    expect(subject.validate(55)).to eq(false)
  end

  it '#validate - player chooses a column that is full' do
    subject.board[6][4] = 1
    subject.board[5][4] = 2
    subject.board[4][4] = 1
    subject.board[3][4] = 2
    subject.board[2][4] = 1
    subject.board[1][4] = 2
    subject.board[0][4] = 1

    expect(subject).to receive(:puts).with("\nThe column you have chosen is full\n")
    expect(subject.validate(5)).to eq(false)
  end

  it '#validate - player chooses a valid move' do
    subject.board[3][1] = 1
    subject.board[4][1] = 2
    subject.board[5][1] = 1
    subject.board[6][1] = 2

    expect(subject.validate(1)).to eq(true)
  end

  it '#make_move - move is correctly added to the arrays' do
    new_board =
      [
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 0, 0],
        [0, 0, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 2, 0, 0],
        [0, 0, 0, 0, 1, 0, 0]
      ]
    player1_board =
      [
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 0, 0]
      ]

    player2_board =
      [
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 0, 0],
        [0, 0, 0, 0, 0, 0, 0]
      ]

    subject.instance_variable_set(:@board, new_board)
    subject.instance_variable_set(:@player1_board, player1_board)
    subject.instance_variable_set(:@player2_board, player2_board)
    expect(subject.board[2][4]).to eq(0)
    expect(subject.player1_board[2][4]).to eq(0)
    expect(subject.player2_board[2][4]).to eq(0)
    subject.make_move(5, 1)
    expect(subject.board[2][4]).to eq(1)
    expect(subject.player1_board[2][4]).to eq(1)
    expect(subject.player2_board[2][4]).to eq(0)
  end

  it '#make_move - move is correctly added to the arrays' do
    new_board =
      [
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 0, 0],
        [0, 0, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 2, 0, 0],
        [0, 0, 0, 0, 1, 0, 0]
      ]
    player1_board =
      [
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 0, 0]
      ]

    player2_board =
      [
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 0, 0],
        [0, 0, 0, 0, 0, 0, 0]
      ]

    subject.instance_variable_set(:@board, new_board)
    subject.instance_variable_set(:@player1_board, player1_board)
    subject.instance_variable_set(:@player2_board, player2_board)
    expect(subject.board[2][4]).to eq(0)
    expect(subject.player1_board[2][4]).to eq(0)
    expect(subject.player2_board[2][4]).to eq(0)
    subject.make_move(5, 2)
    expect(subject.board[2][4]).to eq(2)
    expect(subject.player1_board[2][4]).to eq(0)
    expect(subject.player2_board[2][4]).to eq(2)
  end

  context 'check for winner - horizontal' do
    it '#winner_check_rows - checks empty board' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_rows(current_player)).to be false
    end

    it '#winner_check_rows - player 1 - checks bottom row win' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 1, 1, 1, 1, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_rows(current_player)).to be true
    end

    it '#winner_check_rows - player 2 - checks bottom row win' do
      current_player = 2
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 2, 2, 2, 2, 0, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_rows(current_player)).to be true
    end

    it '#winner_check_rows - player 1 - checks top row win' do
      current_player = 1
      new_board =
        [
          [1, 1, 1, 1, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_rows(current_player)).to be true
    end

    it '#winner_check_rows - player 2 - checks top row win' do
      current_player = 2
      new_board =
        [
          [0, 0, 2, 2, 2, 2, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_rows(current_player)).to be true
    end

    it '#winner_check_rows - player 1 - checks middle row win' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 1, 1, 1, 1],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_rows(current_player)).to be true
    end

    it '#winner_check_rows - player 2 - checks middle row win' do
      current_player = 2
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 2, 2, 2, 2, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_rows(current_player)).to be true
    end

    it '#winner_check_rows - player 1 - checks full board' do
      current_player = 1
      new_board =
        [
          [1, 0, 1, 0, 1, 0, 1],
          [0, 1, 0, 1, 0, 1, 0],
          [1, 0, 1, 0, 1, 0, 1],
          [0, 1, 0, 1, 0, 1, 0],
          [1, 0, 1, 0, 1, 0, 1],
          [0, 1, 0, 1, 0, 1, 0],
          [1, 0, 1, 0, 1, 0, 1]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_rows(current_player)).to be false
    end

    it '#winner_check_rows - player 2 - checks full board' do
      current_player = 2
      new_board =
        [
          [0, 2, 0, 2, 0, 2, 0],
          [2, 0, 2, 0, 2, 0, 2],
          [0, 2, 0, 2, 0, 2, 0],
          [2, 0, 2, 0, 2, 0, 2],
          [0, 2, 0, 2, 0, 2, 0],
          [2, 0, 2, 0, 2, 0, 2],
          [0, 2, 0, 2, 0, 2, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_rows(current_player)).to be false
    end

    it '#winner_check_rows - player 1 - checks full board win' do
      current_player = 1
      new_board =
        [
          [1, 1, 1, 1, 0, 0, 0],
          [0, 1, 0, 1, 0, 1, 0],
          [1, 0, 1, 0, 1, 0, 1],
          [0, 1, 0, 1, 0, 1, 0],
          [1, 0, 1, 0, 1, 0, 1],
          [0, 1, 0, 1, 0, 1, 0],
          [1, 0, 1, 0, 1, 0, 1]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_rows(current_player)).to be true
    end

    it '#winner_check_rows - player 2 - checks full board win' do
      current_player = 2
      new_board =
        [
          [0, 0, 0, 2, 2, 2, 2],
          [2, 0, 2, 0, 2, 0, 2],
          [0, 2, 0, 2, 0, 2, 0],
          [2, 0, 2, 0, 2, 0, 2],
          [0, 2, 0, 2, 0, 2, 0],
          [2, 0, 2, 0, 2, 0, 2],
          [0, 2, 0, 2, 0, 2, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_rows(current_player)).to be true
    end

    it '#winner_check_rows - does not count between consecutive on different lines' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 1, 1, 1],
          [1, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_rows(current_player)).to be false
    end
  end

  context 'check for winner - vertical' do
    it '#winner_check_columns - checks empty board' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_columns(current_player)).to be false
    end

    it '#winner_check_columns - player 1 - checks left column win' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [1, 0, 0, 0, 0, 0, 0],
          [1, 0, 0, 0, 0, 0, 0],
          [1, 0, 0, 0, 0, 0, 0],
          [1, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_columns(current_player)).to be true
    end

    it '#winner_check_columns - player 2 - checks left column win' do
      current_player = 2
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [2, 0, 0, 0, 0, 0, 0],
          [2, 0, 0, 0, 0, 0, 0],
          [2, 0, 0, 0, 0, 0, 0],
          [2, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_columns(current_player)).to be true
    end

    it '#winner_check_columns - player 1 - checks right column win' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 1],
          [0, 0, 0, 0, 0, 0, 1],
          [0, 0, 0, 0, 0, 0, 1],
          [0, 0, 0, 0, 0, 0, 1],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_columns(current_player)).to be true
    end

    it '#winner_check_columns - player 2 - checks right column win' do
      current_player = 2
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 2],
          [0, 0, 0, 0, 0, 0, 2],
          [0, 0, 0, 0, 0, 0, 2],
          [0, 0, 0, 0, 0, 0, 2]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_columns(current_player)).to be true
    end

    it '#winner_check_columns - player 1 - checks middle column win' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 1, 0, 0, 0],
          [0, 0, 0, 1, 0, 0, 0],
          [0, 0, 0, 1, 0, 0, 0],
          [0, 0, 0, 1, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_columns(current_player)).to be true
    end

    it '#winner_check_columns - player 2 - checks middle column win' do
      current_player = 2
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 2, 0, 0, 0],
          [0, 0, 0, 2, 0, 0, 0],
          [0, 0, 0, 2, 0, 0, 0],
          [0, 0, 0, 2, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_columns(current_player)).to be true
    end

    it '#winner_check_columns - player 1 - checks full board' do
      current_player = 1
      new_board =
        [
          [1, 0, 1, 0, 1, 0, 1],
          [0, 1, 0, 1, 0, 1, 0],
          [1, 0, 1, 0, 1, 0, 1],
          [0, 1, 0, 1, 0, 1, 0],
          [1, 0, 1, 0, 1, 0, 1],
          [0, 1, 0, 1, 0, 1, 0],
          [1, 0, 1, 0, 1, 0, 1]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_columns(current_player)).to be false
    end

    it '#winner_check_columns - player 2 - checks full board' do
      current_player = 2
      new_board =
        [
          [0, 2, 0, 2, 0, 2, 0],
          [2, 0, 2, 0, 2, 0, 2],
          [0, 2, 0, 2, 0, 2, 0],
          [2, 0, 2, 0, 2, 0, 2],
          [0, 2, 0, 2, 0, 2, 0],
          [2, 0, 2, 0, 2, 0, 2],
          [0, 2, 0, 2, 0, 2, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_columns(current_player)).to be false
    end

    it '#winner_check_columns - player 1 - checks full board win' do
      current_player = 1
      new_board =
        [
          [1, 0, 1, 0, 1, 0, 1],
          [0, 1, 1, 1, 0, 1, 0],
          [1, 0, 1, 0, 1, 0, 1],
          [0, 1, 1, 1, 0, 1, 0],
          [1, 0, 0, 0, 1, 0, 1],
          [0, 1, 0, 1, 0, 1, 0],
          [1, 0, 1, 0, 1, 0, 1]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_columns(current_player)).to be true
    end

    it '#winner_check_columns - player 2 - checks full board win' do
      current_player = 2
      new_board =
        [
          [0, 2, 0, 2, 0, 2, 0],
          [2, 0, 2, 0, 2, 0, 2],
          [0, 2, 0, 2, 0, 2, 0],
          [2, 0, 2, 0, 2, 0, 2],
          [0, 2, 0, 2, 2, 2, 0],
          [2, 0, 2, 0, 2, 0, 2],
          [0, 2, 0, 2, 2, 2, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_columns(current_player)).to be true
    end

    it '#winner_check_columns - does not count between consecutive in different columns' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 1, 1, 1],
          [1, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_columns(current_player)).to be false
    end
  end

  context 'check_for_winner - diagonal back slash' do
    it 'winner_check_diagonal_back_slash - player 1 - empty board' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_diagonal_back_slash(current_player)).to be false
    end

    it 'winner_check_diagonal_back_slash - player 2 - empty board' do
      current_player = 2
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_diagonal_back_slash(current_player)).to be false
    end

    it 'winner_check_diagonal_back_slash - player 1 - win from left' do
      current_player = 1
      new_board =
        [
          [1, 0, 0, 0, 0, 0, 0],
          [0, 1, 0, 0, 0, 0, 0],
          [0, 0, 1, 0, 0, 0, 0],
          [0, 0, 0, 1, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_diagonal_back_slash(current_player)).to be true
    end

    it 'winner_check_diagonal_back_slash - player 2 - win from left' do
      current_player = 2
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [2, 0, 0, 0, 0, 0, 0],
          [0, 2, 0, 0, 0, 0, 0],
          [0, 0, 2, 0, 0, 0, 0],
          [0, 0, 0, 2, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_diagonal_back_slash(current_player)).to be true
    end

    it 'winner_check_diagonal_back_slash - player 1 - win from middle' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 1, 0, 0, 0, 0, 0],
          [0, 0, 1, 0, 0, 0, 0],
          [0, 0, 0, 1, 0, 0, 0],
          [0, 0, 0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_diagonal_back_slash(current_player)).to be true
    end

    it 'winner_check_diagonal_back_slash - player 2 - win from middle' do
      current_player = 2
      new_board =
        [
          [0, 0, 0, 2, 0, 0, 0],
          [0, 0, 0, 0, 2, 0, 0],
          [0, 0, 0, 0, 0, 2, 0],
          [0, 0, 0, 0, 0, 0, 2],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_diagonal_back_slash(current_player)).to be true
    end

    it 'winner_check_diagonal_back_slash - player 1 - win on right' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 1, 0, 0, 0],
          [0, 0, 0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0, 1, 0],
          [0, 0, 0, 0, 0, 0, 1],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_diagonal_back_slash(current_player)).to be true
    end

    it 'winner_check_diagonal_back_slash - player 2 - win on right' do
      current_player = 2
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 2, 0, 0, 0],
          [0, 0, 0, 0, 2, 0, 0],
          [0, 0, 0, 0, 0, 2, 0],
          [0, 0, 0, 0, 0, 0, 2]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_diagonal_back_slash(current_player)).to be true
    end

    it 'winner_check_diagonal_back_slash - player 1 - checks full board' do
      current_player = 1
      new_board =
        [
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_diagonal_back_slash(current_player)).to be false
    end

    it 'winner_check_diagonal_back_slash - player 2 - checks full board' do
      current_player = 2
      new_board =
        [
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_diagonal_back_slash(current_player)).to be false
    end

    it 'winner_check_diagonal_back_slash - player 1 - checks full board win' do
      current_player = 1
      new_board =
        [
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 0, 0, 1, 0, 1],
          [1, 0, 1, 1, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 1, 1],
          [1, 0, 1, 0, 1, 0, 1]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_diagonal_back_slash(current_player)).to be true
    end

    it 'winner_check_diagonal_back_slash - player 2 - checks full board win' do
      current_player = 2
      new_board =
        [
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [2, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 2, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_diagonal_back_slash(current_player)).to be true
    end
  end

  context 'check_for_winner - diagonal back slash' do
    it 'winner_check_diagonal_forward_slash - player 1 - empty board' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_diagonal_forward_slash(current_player)).to be false
    end

    it 'winner_check_diagonal_forward_slash - player 2 - empty board' do
      current_player = 2
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_diagonal_forward_slash(current_player)).to be false
    end

    it 'winner_check_diagonal_forward_slash - player 1 - win from left' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 1, 0, 0, 0],
          [0, 0, 1, 0, 0, 0, 0],
          [0, 1, 0, 0, 0, 0, 0],
          [1, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_diagonal_forward_slash(current_player)).to be true
    end

    it 'winner_check_diagonal_forward_slash - player 2 - win from left' do
      current_player = 2
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 2, 0, 0, 0],
          [0, 0, 2, 0, 0, 0, 0],
          [0, 2, 0, 0, 0, 0, 0],
          [2, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_diagonal_forward_slash(current_player)).to be true
    end

    it 'winner_check_diagonal_forward_slash - player 1 - win from middle' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 1, 0],
          [0, 0, 0, 0, 1, 0, 0],
          [0, 0, 0, 1, 0, 0, 0],
          [0, 0, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_diagonal_forward_slash(current_player)).to be true
    end

    it 'winner_check_diagonal_forward_slash - player 2 - win from middle' do
      current_player = 2
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 2, 0],
          [0, 0, 0, 0, 2, 0, 0],
          [0, 0, 0, 2, 0, 0, 0],
          [0, 0, 2, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_diagonal_forward_slash(current_player)).to be true
    end

    it 'winner_check_diagonal_forward_slash - player 1 - win on right' do
      current_player = 1
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 1],
          [0, 0, 0, 0, 0, 1, 0],
          [0, 0, 0, 0, 1, 0, 0],
          [0, 0, 0, 1, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_diagonal_forward_slash(current_player)).to be true
    end

    it 'winner_check_diagonal_forward_slash - player 2 - win on right' do
      current_player = 2
      new_board =
        [
          [0, 0, 0, 0, 0, 0, 2],
          [0, 0, 0, 0, 0, 2, 0],
          [0, 0, 0, 0, 2, 0, 0],
          [0, 0, 0, 2, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_diagonal_forward_slash(current_player)).to be true
    end

    it 'winner_check_diagonal_forward_slash - player 1 - checks full board' do
      current_player = 1
      new_board =
        [
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_diagonal_forward_slash(current_player)).to be false
    end

    it 'winner_check_diagonal_forward_slash - player 2 - checks full board' do
      current_player = 2
      new_board =
        [
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_diagonal_forward_slash(current_player)).to be false
    end

    it 'winner_check_diagonal_forward_slash - player 1 - checks full board win' do
      current_player = 1
      new_board =
        [
          [1, 0, 1, 1, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 1, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1]
        ]
      subject.instance_variable_set(:@player1_board, new_board)
      expect(subject.winner_check_diagonal_forward_slash(current_player)).to be true
    end

    it 'winner_check_diagonal_forward_slash - player 2 - checks full board win' do
      current_player = 2
      new_board =
        [
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 2],
          [0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 2, 2, 0],
          [0, 2, 0, 2, 0, 2, 0]
        ]
      subject.instance_variable_set(:@player2_board, new_board)
      expect(subject.winner_check_diagonal_forward_slash(current_player)).to be true
    end
  end
end
