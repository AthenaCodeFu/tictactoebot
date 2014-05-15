class Game

  attr_accessor :board, :players, :turn, :current_player, :send_output_to_terminal

  def initialize(player_x, player_o)
    @players = {
      :x => player_x,
      :o => player_o,
    }
    @board = (0..2).map {|y| (0..2).map { "." } } # 3x3 2d array
    @turn = 0
    @current_player = :x
    @send_output_to_terminal = true
  end

  # returns :x or :o if one of the players has three in a row; otherwise, returns nil
  def winner
    [
     [[0,0],[0,1],[0,2]], # column 0
     [[1,0],[1,1],[1,2]], # column 1
     [[2,0],[2,1],[2,2]], # column 2
     [[0,0],[1,0],[2,0]], # row 0
     [[0,1],[1,1],[2,1]], # row 1
     [[0,2],[1,2],[2,2]], # row 2
     [[0,0],[1,1],[2,2]], # descending diagonal
     [[0,2],[1,1],[2,0]], # ascending diagonal
    ].each do |cells|
      vals = cells.map {|x, y| board[y][x] }
      return :x if vals == %w( X X X )
      return :o if vals == %w( O O O )
    end      
    return nil
  end

  # returns true if the board is full and there is no winner
  def draw?
    winner.nil? && board.flatten.none? {|cell| cell == '.'}
  end

  def get_cell(x, y)
    board[y][x]
  end

  def set_cell(x, y, mark)
    board[y][x] = mark
  end

  def check_move_valid(x, y, mark)
    raise "cell #{x},#{y} is already marked" unless board[y][x] == '.'
    raise "invalid mark" unless mark == 'X' or mark == 'O'
  end

  def make_move(x, y, mark)
    check_move_valid(x, y, mark)
    set_cell(x, y, mark)
  end

  # def board_to_s
  #   # board template
  #   s =  "
  #            a     b     c
  #          _____ _____ _____
  #         |     |     |     |
  #      1  | 0,0 | 1,0 | 2,0 |
  #         |_____|_____|_____|
  #         |     |     |     |
  #      2  | 0,1 | 1,1 | 2,1 |
  #         |_____|_____|_____|
  #         |     |     |     |
  #      3  | 0,2 | 1,2 | 2,2 |
  #         |_____|_____|_____|
  #   ";

  #   # unindent
  #   s.sub!(/\A\n/, '')
  #   s.rstrip!
  #   s.gsub!(/^    /, '')

  #   # fill in spaces
  #   s.gsub!(/([012]),([012])/) do
  #     x = $1.to_i
  #     y = $2.to_i
  #     " #{get_cell(x, y)} "
  #   end

  #   return s
  # end

  def board_to_s
    board.map {|row| "  " + row.join(" ") + "\n"}.join
  end

  # send a message to any combination of the two players and the terminal
  def send(recipients, message)
    players[:x].print(message) if recipients.include? :x
    players[:o].print(message) if recipients.include? :o
    print message if recipients.include? :term and send_output_to_terminal
  end

  def prompt_for_move(warning=nil)
    s =  "BOARD:\n\n" + board_to_s + "\n"
    s += warning + "\n\n" if warning
    s += "Specify column a, b, or c (left to right) and row 1, 2, or 3 (top to bottom).\n"
    s += "For example, type 'a3' for the bottom-left corner.\n"
    s += "Player #{current_player.to_s.upcase}, what is your move?\n"
    players[current_player].print s
  end

  # prompts the specified player (:x or :o) for a move
  def get_move(symbol)
    player = players[symbol]
    warning = nil
    num_attempts = 0

    while true

      num_attempts += 1
      if (num_attempts > 100)
        STDERR.puts "100 failed attempts to specify a valid move"
        STDERR.puts "This probably indicates a logic error"
        raise "too many failed attempts to specify a valid move"
      end

      prompt_for_move(warning)
      warning = nil

      response = player.readline or raise "unexpected end of input"

      if response =~ /^ \s* ([abc]) \s* ([123]) \s* $/xi
        x = $1.downcase.tr('abc', '012').to_i
        y = $2.to_i - 1

        if get_cell(x, y) == '.'
          return [x, y, symbol.to_s.upcase]
        else
          warning = "'#{response.chomp}' is already occupied"
        end
      else
        warning = "'#{response.chomp}' is not a valid move"
      end

    end
  end

  def run
    while !winner && !draw?
      @turn += 1
      move = get_move(current_player)
      make_move(*move)
      @current_player = (current_player == :x) ? :o : :x
    end

    result = draw? ? :draw : winner
    message = "BOARD:\n\n" + board_to_s + "\n" + (draw? ? "DRAW!" : "PLAYER #{winner.to_s.upcase} WINS!") + "\n\n"
    players[:x].print message
    players[:o].print message
    return result
  end

end

