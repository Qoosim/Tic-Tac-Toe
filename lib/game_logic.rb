# frozen_string_literal: true

# Class cell for grid
class Cell
  attr_accessor :value
  def initialize(value = ' ')
    @value = value
  end
end

# Class for intializing the players
class Player
  attr_reader :color, :name
  def initialize(name, color)
    @name = name
    @color = color
  end
end

# Class for initializing the Board
class Board
  attr_reader :grid
  def initialize(grid = empty_grid)
    @grid = grid
  end

  def empty_grid
    Array.new(3) { Array.new(3) { Cell.new } }
  end

  def get_cell(x, y)
    grid[x][y]
  end

  def set_cell(x, y, value)
    return false if get_cell(x, y).value != ' '

    get_cell(x, y).value = value
    true
  end

  def game_over
    return :winner if winner?

    false
  end

  private

  def winner?
    for n in 0..2
      return true if (get_cell(n, 0).value == get_cell(n, 1).value && get_cell(n, 1).value == get_cell(n, 2).value) && get_cell(n, 0).value != ' '
    end
    for n in 0..2
      return true if (get_cell(0, n).value == get_cell(1, n).value && get_cell(1, n).value == get_cell(2, n).value) && get_cell(0, n).value != ' '

    end
    return true if ((get_cell(0, 0).value == get_cell(1, 1).value && get_cell(1, 1).value == get_cell(2, 2).value) && get_cell(0, 0).value != ' ') || ((get_cell(0, 2).value == get_cell(1, 1).value && get_cell(1, 1).value == get_cell(2, 0).value) && get_cell(1, 1).value != ' ')

    false
  end
end

# Class to initialize and control the game
class Game
  attr_reader :players, :board, :player_one, :player_two
  def initialize(players = players_generator, board = Board.new)
    @players = players
    @board = board
    @player_one, @player_two = players.shuffle
  end

  def turns_switch
    @player_one, @player_two = @player_two, @player_one
  end

  def get_move
    outputs = Outputs.new
    human_input = outputs.chomper
    range = ['1', '2', '3', '4', '5', '6', '7', '8', '9']
    return false unless range.include?(human_input)

    human_to_coord(human_input)
  end

  def human_to_coord(human_input)
    map = {
      '1' => [0, 0],
      '2' => [0, 1],
      '3' => [0, 2],
      '4' => [1, 0],
      '5' => [1, 1],
      '6' => [1, 2],
      '7' => [2, 0],
      '8' => [2, 1],
      '9' => [2, 2]
    }
    map[human_input]
  end

  def visual
    "
    +-----+-----+-----+
    |  #{board.get_cell(0, 0).value}  |  #{board.get_cell(0, 1).value}  |  #{board.get_cell(0, 2).value}  |
    +-----+-----+-----+
    |  #{board.get_cell(1, 0).value}  |  #{board.get_cell(1, 1).value}  |  #{board.get_cell(1, 2).value}  |
    +-----+-----+-----+
    |  #{board.get_cell(2, 0).value}  |  #{board.get_cell(2, 1).value}  |  #{board.get_cell(2, 2).value}  |
    +-----+-----+-----+
  "
  end


  def play_mode
    outputs = Outputs.new
    outputs.rules_question
    outputs.player_one_responses
    turn_counter = 1
    while turn_counter < 10
      outputs.putter(visual)
      outputs.sampler(ask_move)
      errors = 0
      truthy = true
      while truthy
        outputs.sampler(ask_move_error) if errors.positive?
        breaking_condition = get_move
        if breaking_condition != false
          x, y = breaking_condition
          secondary_condition = board.set_cell(x, y, @player_one.color)
          if secondary_condition != false
            board.set_cell(x, y, @player_one.color)
            break
          end
        end
        errors += 1
      end
      if board.game_over
        outputs.putter(visual)
        outputs.putter(game_over_message)
        outputs.putter(rematch)
        Board.new
        return
      else
        turns_switch
      end
      turn_counter += 1
    end
    outputs.putter(visual)
    outputs.putter(game_over_message)
    outputs.putter(rematch)
  end
end
