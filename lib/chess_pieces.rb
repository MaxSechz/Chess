class Piece
  attr_writer :pos
  attr_reader :pos, :color

  def initialize(pos, board, color)
    @pos, @board, @color = pos, board, color
  end

  def moves
    # return array of places can move
  end

  def dup(board)
    self.class.new(@pos, board, @color)
  end

  def move_into_check?(pos)
    test_board = @board.dup

    test_board.move!(@pos, pos)
    test_board.in_check?(@color)
  end

  def valid_moves
    self.moves.reject do |move|
      move_into_check?(move) || (@board[move] && @board[move].color == @color)
    end
  end

end

# bishop, rook, queen
class SlidingPiece < Piece

  def moves
    moves = []

    # chess board is 8x8
    8.times do |row|
      8.times do |col|
        pos = [row,col]
        next if pos == self.pos
        moves << pos if can_move?(pos)
      end
    end

    moves
  end

  def can_move?(pos)
  end

end

class Rook < SlidingPiece

  def can_move?(pos)
    self.pos.first == pos.first || self.pos.last == pos.last
  end

  def render
    color == :white ? 'r' : "R"
  end

end

class Bishop < SlidingPiece

  def can_move?(pos)
    (self.pos.first - pos.first).abs == (self.pos.last - pos.last).abs
  end

  def render
    color == :white ? 'b' : "B"
  end

end

class Queen < SlidingPiece

  def can_move?(pos)
    self.pos.first == pos.first || self.pos.last == pos.last ||
    (self.pos.first - pos.first).abs == (self.pos.last - pos.last).abs
  end

  def render
    color == :white ? 'q' : "Q"
  end

end
#king knight
class SteppingPiece < Piece

  def moves
    moves = []

    x, y = @pos
    self.class::DELTAS.each do |(dx,dy)|
      moves << [x + dx, y + dy]
    end

    moves
  end



end

class Knight < SteppingPiece

  DELTAS = [
            [2,1],
            [1,2],
            [-2,1],
            [2,-1],
            [-2,-1],
            [-1,2],
            [1,-2],
            [-1,-2]
            ]

  def render
    color == :white ? 'n' : "N"
  end

end

class King < SteppingPiece

  DELTAS = [
            [1,0],
            [-1,0],
            [0,1],
            [0,-1],
            [1,-1],
            [-1,1],
            [1,1],
            [-1,-1]
            ]

  def render
    color == :white ? 'k' : "K"
  end

end

class Pawn < Piece

  def initialize(pos, board, color)
    super
    @moved = false
  end

  def moves
    moves = []

    if @color == :white
      unless @board[pos[0] - 1, pos[1]]
        moves << [pos[0] - 1, pos[1]]
        moves << [pos[0] - 2, pos[1]] unless @moved || @board[pos[0] - 2, pos[1]]
      end
      # find diagonals
      # check diagonals for enemy pieces
      diagonals = [[pos[0] - 1, pos[1] - 1], [pos[0] - 1, pos[1] + 1]]
      moves += diagonals.select do |diagonal|
        @board[diagonal] &&
        @board[diagonal].color == :black
      end
    else
      unless @board[pos[0] + 1, pos[1]]
        moves << [pos[0] + 1, pos[1]]
        moves << [pos[0] + 2, pos[1]] unless @moved || @board[pos[0] + 2, pos[1]]
      end
      diagonals = [[pos[0] + 1, pos[1] - 1], [pos[0] + 1, pos[1] + 1]]
      moves += diagonals.select do |diagonal|
        @board[diagonal] &&
        @board[diagonal].color == :white
      end
    end

    @moved = true
    moves
  end

  def render
    color == :white ? 'p' : "P"
  end

end
