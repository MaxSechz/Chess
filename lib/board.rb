require_relative 'chess_pieces.rb'

class ChessError < StandardError
end

class PieceSelectionError < ChessError
  def message
    "You chose an empty spot!"
  end
end

class InCheckError < ChessError
  def message
    "You're still in check!"
  end
end

class InvalidMoveError < ChessError
  def message
    "Invalid move!"
  end
end

class InvalidPositionError < ChessError
end


class Board

  def initialize
    @board = Array.new(8) {Array.new(8)}

    initialize_sides
  end

  def move(start, end_pos)
    piece = self[start]

    raise PieceSelectionError if piece.nil?
    raise InCheckError if piece.move_into_check?(end_pos)
    raise InvalidMoveError unless piece.valid_moves.include?(end_pos)

    #call move!
    self[start] = nil
    self[end_pos] = piece
    piece.pos = end_pos
  end

  def move!(start, end_pos)
    piece = self[start]
    raise PieceSelectionError if piece.nil?

    self[start] = nil
    self[end_pos] = piece
    piece.pos = end_pos
  end

  # have each piece place itself on board
  def dup
    dupped_board = Board.new

    @board.each_index do |row|
      @board[row].each_with_index do |piece, col|
        pos = [row, col]

        new_piece = piece.nil? ? nil : piece.dup(dupped_board)

        dupped_board[pos] = new_piece
      end
    end

    dupped_board
  end


  def render
    puts "   " + ('A'..'H').to_a.join("   ")
    puts " ┌" + "───┬" * 7 + "───┐"
    @board.each_with_index do |row, index|
      print (8-index).to_s
      row.each do |piece|
        print piece.nil? ? "│   " : "│ #{piece.render} "
      end
      print "│" + (8-index).to_s
      puts
      puts " ├" + "───┼" * 7 + "───┤" unless index == 7
    end
    puts " └" + "───┴" * 7 + "───┘"
    puts "   " + ('A'..'H').to_a.join("   ")
  end


  def [](pos)
    x,y = pos
    return nil unless x.between?(0,7) && y.between?(0,7)
    @board[x][y]
  end

  def []=(pos, value)
    x,y = pos
    raise InvalidPositionError unless x.between?(0,7) && y.between?(0,7)
    @board[x][y] = value
  end

  def checkmate?(color)
    return false unless in_check?(color)

    all_valid_moves(color).empty?
  end

  def in_check?(color)
    king = find_king(color)

    all_moves(enemy_color(color)).include?(king.pos)
  end


  private

  def find_king(color)
    all_pieces(color).select { |piece| piece.is_a?(King) }.first
  end

  def initialize_sides
    initialize_pieces(:white)
    initialize_pieces(:black)
  end


  def initialize_pieces(color)
    row = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    back_row, front_row = (color == :white ? [7,6] : [0,1])

    8.times { |col| Pawn.new([front_row, col], self, color) }

    row.each_with_index do |piece, col|
      piece.new([back_row, col], self, color)
    end
  end

  def enemy_color(color)
    color == :white ? :black : :white
  end

  def all_moves(color)
    all_moves = []

    all_pieces(color).each { |piece| all_moves += piece.moves }

    all_moves.uniq
  end

  def all_valid_moves(color)
    all_valid_moves = []

    all_pieces(color).each { |piece| all_valid_moves += piece.valid_moves }

    all_valid_moves.uniq
  end

  def all_pieces(color)
    @board.flatten.select { |piece| piece && piece.color == color }
  end

end
