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
    test_board.in_check?(self.color)
  end

  def valid_moves
    self.moves.reject do |move|
      move_into_check?(move)
    end
  end

end

# bishop, rook, queen
class SlidingPiece < Piece

  def moves
    moves = []

    self.class::DELTAS.each do |(dx,dy)|
      x, y = @pos
      while true
        x += dx
        y += dy
        break unless x.between?(0,7) && y.between?(0,7)
        break if @board[[x,y]] && @board[[x,y]].color == self.color
        moves << [x, y]
        break if @board[[x,y]] && @board[[x,y]].color == @board.enemy_color(self.color)
      end
    end

    moves
  end

  def can_move?(pos)
  end

end

class Rook < SlidingPiece

  DELTAS = [
            [1,0],
            [-1,0],
            [0,1],
            [0,-1],
          ]

  def render
    color == :white ? 'r' : "R"
  end

end

class Bishop < SlidingPiece

  DELTAS = [
            [1,-1],
            [-1,1],
            [1,1],
            [-1,-1]
            ]

  def render
    color == :white ? 'b' : "B"
  end

end

class Queen < SlidingPiece

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
    color == :white ? 'q' : "Q"
  end

end
#king knight
class SteppingPiece < Piece

  def moves
    moves = []

    x, y = @pos
    self.class::DELTAS.each do |(dx,dy)|
      new_move = [x + dx, y + dy]
      next unless new_move.all? { |el| el.between?(0,7) }
      next if @board[new_move] && @board[new_move].color == self.color
      moves << new_move
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
    @start = @pos
    @moved = false
  end

  def moves
    moves = []

    if @color == :white
      unless @board[[pos[0] - 1, pos[1]]]
        moves << [pos[0] - 1, pos[1]]
        moves << [pos[0] - 2, pos[1]] unless @start != @pos || @board[[pos[0] - 2, pos[1]]]
      end
      # find diagonals
      # check diagonals for enemy pieces
      diagonals = [[pos[0] - 1, pos[1] - 1], [pos[0] - 1, pos[1] + 1]]
      moves += diagonals.select do |diagonal|
        @board[diagonal] &&
        @board[diagonal].color == :black
      end
    else
      unless @board[[pos[0] + 1, pos[1]]]
        moves << [pos[0] + 1, pos[1]]
        moves << [pos[0] + 2, pos[1]] unless @start != @pos || @board[[pos[0] + 2, pos[1]]]
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
