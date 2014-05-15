require 'game'

def boards
  {
    :empty       => [%w( . . . ),
                     %w( . . . ),
                     %w( . . . )],

    :unfinished  => [%w( X O X ),
                     %w( . O . ),
                     %w( . . O )],

    :draw        => [%w( O X O ),
                     %w( X X O ),
                     %w( X O X )],

    :x_win_early => [%w( O O X ),
                     %w( . X O ),
                     %w( X . X )],

    :x_win_end   => [%w( X O X ),
                     %w( X X O ),
                     %w( O O X )],

    :o_win_early => [%w( . X X ),
                     %w( O O O ),
                     %w( . . . )],

    :o_win_end   => [%w( O X O ),
                     %w( O X X ),
                     %w( O O X )],
  }
end

def win_patterns
  {
    :row0 => [%w( X X X ),
              %w( . . . ),
              %w( . . . )],
    :row1 => [%w( . . . ),
              %w( X X X ),
              %w( . . . )],
    :row2 => [%w( . . . ),
              %w( . . . ),
              %w( X X X )],
    :col0 => [%w( X . . ),
              %w( X . . ),
              %w( X . . )],
    :col1 => [%w( . X . ),
              %w( . X . ),
              %w( . X . )],
    :col2 => [%w( . . X ),
              %w( . . X ),
              %w( . . X )],
    :asc  => [%w( . . X ),
              %w( . X . ),
              %w( X . . )],
    :desc => [%w( X . . ),
              %w( . X . ),
              %w( . . X )],
  }
end

# mock player interface - remembers messages sent to it by the game, and sends a
# predefined list of responses when the game asks it for a move
class DummyPlayerInterface
  attr_accessor :moves, :messages
  def initialize
    @moves, @messages = [], ""
  end
  def print(s)
    @messages += s
  end
  def readline
    @moves.empty? ? nil : @moves.shift + "\n"
  end
end

# factory method to create game instances for testing
def make_game(board=nil)

  # create a game and connect it to two DummyPlayerInterfaces
  g = Game.new(DummyPlayerInterface.new, DummyPlayerInterface.new)

  # initialize the game's board to the given state
  board ||= boards[:empty]
  (0..2).each do |y|
    (0..2).each do |x|
      g.set_cell(x, y, board[y][x]) if board[y][x] =~ /[XO]/
    end
  end

  # keep the tests tidy by suppressing output to the terminal
  g.send_output_to_terminal = false

  return g
end



describe Game do

  describe "#winner" do

    it "should return nil for an empty board" do
      expect(make_game(boards[:empty]).winner).to be_nil
    end

    it "should return nil for an unfinished game" do
      expect(make_game(boards[:unfinished]).winner).to be_nil
    end

    it "should return nil for a full board with no winners" do
      expect(make_game(boards[:draw]).winner).to be_nil
    end

    it "should return :x if there are three Xs in a row" do
      expect(make_game(boards[:x_win_early]).winner).to be(:x)
      expect(make_game(boards[:x_win_end]).winner).to be(:x)
    end

    it "should return :o if there are three Os in a row" do
      expect(make_game(boards[:o_win_early]).winner).to be(:o)
      expect(make_game(boards[:o_win_end]).winner).to be(:o)
    end

    it "should find any of the eight possible winning rows" do
      win_patterns.values.each do |b|
        expect(make_game(b).winner).to be(:x)
      end
    end

  end

  describe "#draw?" do

    it "should return false if the board is not full" do
      [:empty, :unfinished, :x_win_early, :o_win_early].each do |key|
        expect(make_game(boards[key]).draw?).to be_false
      end
    end

    it "should return false if the board is full but there is a winner" do
      [:x_win_end, :o_win_end].each do |key|
        expect(make_game(boards[key]).draw?).to be_false
      end
    end

    it "shoud return true if the board is full with no winner" do
      expect(make_game(boards[:draw]).draw?).to be_true
    end

  end

  describe "board manipulation" do

    let(:game) { make_game }

    it "should have an initial cell value of '.'" do
      expect(game.get_cell(1, 1)).to eq('.')
    end

    it "should allow a cell to be marked" do
      expect {game.make_move(1, 1, 'X')}.not_to raise_error
      expect(game.get_cell(1, 1)).to eq('X')
    end

    it "should allow a cell to be set only once" do
      expect {game.make_move(1, 1, 'X')}.not_to raise_error
      expect {game.make_move(1, 1, 'X')}.to raise_error
      expect {game.make_move(1, 1, 'O')}.to raise_error
    end

    it "should only allow an 'X' or 'O' move" do
      expect {game.make_move(1, 1, 'x')}.to raise_error
      expect {game.make_move(1, 1, '?')}.to raise_error
    end

  end

  describe "#board_to_s" do

    let(:game) { make_game(boards[:unfinished]) }

    it "should contain nine characters representing the spaces ('.', 'X', or 'O')" do
      expect(game.board_to_s).to match(/\A(\s*[.XO]){9}\s*\Z/m)
    end

    it "should contain the spaces in the correct order" do
      expect(game.board_to_s.gsub(/[^.XO]/, '')).to eq("XOX.O...O")
    end

  end

  describe "#get_move" do

    let(:game) { make_game(boards[:unfinished]) }

    # prepare player X to send 'a2' as its first move
    before(:each) { game.players[:x].moves = ['a2'] }

    # helper: run a block and ignore any errors it raises
    def suppress_errors
      begin
        yield
      rescue
      end
    end

    it "should prompt for a move" do
      game.get_move(:x)
      expect(game.players[:x].messages).to match(/what is your move?/)
    end

    it "should display the board" do
      game.get_move(:x)
      expect(game.players[:x].messages).to match(/BOARD:(\s*[.XO]){9}/)
    end

    it "should get a valid move" do
      expect(game.get_move(:x)).to eq([0, 1, 'X'])
    end

    it "should get the first valid move" do
      game.players[:x].moves = ['z9', 'middle square', 'c2', 'a2']  # the first valid move is 'c2'
      expect(game.get_move(:x)).to eq([2, 1, 'X'])
    end

    it "should raise an error if the input ends" do
      game.players[:x].moves = []  # input ends with the first request for a move
      expect { game.get_move(:x) }.to raise_error(/unexpected end of input/)
    end

    it "should reject an invalid response" do
      game.players[:x].moves = ['invalid response']
      suppress_errors { game.get_move(:x) }
      expect(game.players[:x].messages).to match(/'invalid response' is not a valid move/)
    end

    it "should reject a move for an already occupied space" do
      game.players[:x].moves = ['a1']
      suppress_errors { game.get_move(:x) }
      expect(game.players[:x].messages).to match(/'a1' is already occupied/)
    end

  end

  describe "#run" do

    let(:game) { make_game }

    def setup_draw
      game.current_player = :x
      game.players[:x].moves = %w( b2    c1    a2    b3    c3 )
      game.players[:o].moves = %w(    a1    a3    c2    b1    )
    end

    it "should end when there is a draw" do
      setup_draw
      expect(game.run).to eq(:draw)
    end

    it "should tell all players if there is a draw" do
      setup_draw
      game.run
      expect(game.players[:x].messages).to match(/DRAW!/)
      expect(game.players[:o].messages).to match(/DRAW!/)
    end

    it "should leave the board in its final state" do
      setup_draw
      game.run
      expected = [%w( O O X ),
                  %w( X X O ),
                  %w( O X X )]
      (0 .. 2).each do |y|
        (0 .. 2).each do |x|
          expect(game.get_cell(x, y)).to eq(expected[y][x])
        end
      end
    end

  end

end
