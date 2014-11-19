# encoding: utf-8

class ChessError < StandardError
end

class PromotionError < ChessError
end

class Piece
  attr_writer :pos, :has_moved
  attr_reader :pos, :color, :has_moved


  def initialize(pos, board, color, has_moved = false)
    @pos, @board, @color = pos, board, color
    #piece places self
    @board[@pos] = self
    @has_moved = has_moved
  end

  def moves
    # return array of places can move
  end

  def dup(board)
    self.class.new(@pos, board, @color)
  end
############################################
  def move_into_check?(pos)
    test_board = @board.dup
    p test_board[self.pos].class
    p self.pos
    p pos
    test_board.move!(self.pos, pos)
    test_board.in_check?(self.color)
  end
############################################

  def valid_moves
    self.moves.reject { |move| move_into_check?(move) }
  end

  protected

  def is_enemy?(piece)
    self.color != piece.color
  end

end

# bishop, rook, queen
class SlidingPiece < Piece

  def moves
    moves = []

    self.class::DELTAS.each do |(dx,dy)|
      x, y = @pos[0] + dx, @pos[1] + dy
      while x.between?(0,7) && y.between?(0,7) && @board[[x, y]].nil?
        moves << [x, y]
        x += dx
        y += dy
      end
      # check if enemy piece in [x, y], and add it
      moves << [x, y] if @board[[x,y]] && @board[[x,y]].is_enemy?(self)
    end

    moves
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
    color == :white ? '♖' : "♜"
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
    color == :white ? '♗' : "♝"
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
    color == :white ? '♕' : "♛"
  end

end

#king knight
class SteppingPiece < Piece

  def moves
    moves = []

    x, y = @pos
    self.class::DELTAS.each do |(dx,dy)|
      move = [x + dx, y + dy]
      next unless move.all? { |el| el.between?(0,7) }
      moves << move if @board[move].nil? || @board[move].is_enemy?(self)
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
    color == :white ? '♘' : "♞"
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

  def castle(start, end_pos)
    difference = start[1] - end_pos[1]
    return if difference.abs == 1

    if difference > 0
      rook_pos = [@pos.first, 0]
      @board.move!(rook_pos, [rook_pos[0], rook_pos[1] + 3])
    else
      rook_pos = [@pos.first, 7]

      @board.move!(rook_pos, [rook_pos[0], rook_pos[1] - 2])
    end
  end

  def valid_moves
    moves = super

    # find rooks that can castle
    # based on rooks, add move

    right_castle = [@pos.first, @pos.last + 2]
    left_castle = [@pos.first, @pos.last - 2]

    moves << right_castle if can_castle?(get_rooks[1])
    moves << left_castle if can_castle?(get_rooks[0])
    moves
  end

  def get_rooks
    rooks = @board.all_pieces(@color).select do |piece|
      piece.is_a?(Rook) && !piece.has_moved
    end

    right_rook = rooks.select { |rook| rook.pos[1] == 7 }.first
    left_rook = rooks.select { |rook| rook.pos[1] == 0 }.first

    [left_rook, right_rook]
  end

  def can_castle?(rook)
    return false if move_into_check?(@pos)
    return false if @has_moved
    return false if rook.nil?


    if self.pos[1] < rook.pos[1]
      (self.pos[1] + 1...rook.pos[1]).each do |col|
        space_pos = [self.pos[0], col]
        return false if @board[space_pos] || move_into_check?(space_pos)
      end

    else
      (rook.pos[1] + 1...self.pos[1]).each do |col|
        space_pos = [self.pos[0], col]
        return false if @board[space_pos] ||
                        (col > 1 && move_into_check?(space_pos))
      end
    end

    true
  end


  def render
    color == :white ? '♔' : '♚'
  end

end

class Pawn < Piece

  DIAGONALS = [
               [1,1],
               [1,-1]
              ]

  FORWARDS = [
              [1,0],
              [2,0]
             ]

  def moves
    forward_moves + diag_moves
  end

  def render
    color == :white ? '♙' : "♟"
  end

  def en_passant(start)
    passant_pawn = @board[[start[0], @pos[1]]]
    return if passant_pawn.nil?
    if passant_pawn.is_enemy?(self) && passant_pawn.has_moved == :two_spaces
      @board[[start[0], @pos[1]]] = nil
    end
  end


  def promote
    puts 'What would you like to promote your pawn to?'
    begin
      response = Object.const_get(gets.chomp.capitalize)
      if response == King || response == Pawn
        raise PromotionError.new("Cannot promote to #{response}")
      end
    rescue PromotionError => e
      puts e.message
      retry
    end

    response.new(@pos, @board, @color, true)
  end

  private

  def forward_moves
    moves = []
    operator = @color == :white ? :- : :+ # metaprogramming!!

    x, y = @pos
    FORWARDS.each do |(dx, dy)|
      move = [x.send(operator, dx), y + dy]
      moves << move unless @board[move] || @board[[x.send(operator, 1), y + dy]]
      break if @has_moved # don't count second move if already moved
    end

    moves
  end

  def diag_moves
    moves = []
    operator = @color == :white ? :- : :+ # metaprogramming!!

    x, y = @pos
    DIAGONALS.each do |(dx, dy)|
      move = [x.send(operator, dx), y + dy]
      passant_pawn = @board[[x, y + dy]]
      moves << move if passant_pawn && passant_pawn.is_enemy?(self) &&
                       passant_pawn.has_moved == :two_spaces
      moves << move if @board[move] && @board[move].is_enemy?(self)
    end

    moves
  end


end
