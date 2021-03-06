# encoding: utf-8

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
  def message
    "Thats not a real place"
  end
end


class Board

  def initialize(players)
    @board = Array.new(8) {Array.new(8)}
    @players = players
    initialize_sides
  end

  def move(start, end_pos)
    piece = self[start]

    raise PieceSelectionError if piece.nil?
    raise InCheckError if piece.move_into_check?(end_pos)
    raise InvalidMoveError unless piece.valid_moves.include?(end_pos)

    move!(start, end_pos)
    piece.promote if piece.is_a?(Pawn) && (end_pos[0] == 0 || end_pos[0] == 7)
    self
  end

  def move!(start, end_pos)
    piece = self[start]
    # raise PieceSelectionError if piece.nil?

    piece.castle(start, end_pos) if piece.is_a?(King)
    self[start] = nil
    self[end_pos] = piece
    piece.pos = end_pos
      if piece.is_a?(Pawn) && (start[0] - end_pos[0]).abs == 2
      piece.has_moved = :two_spaces
    else
      piece.has_moved = true
    end
    piece.en_passant(start) if piece.is_a?(Pawn)
    self
  end

  # have each piece place itself on board
  def dup
    dupped_board = Board.new(@players)

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
    return nil unless valid_pos?(x, y)
    @board[x][y]
  end

  def []=(pos, value)
    x,y = pos
    raise InvalidPositionError unless valid_pos?(x, y)
    @board[x][y] = value
  end

  def valid_pos?(x, y)
    x.between?(0,7) && y.between?(0,7)
  end

  def stalemate?(color)
    return false if checkmate?(color)
    all_valid_moves(color).empty?
  end

  def checkmate?(color)
    return false unless in_check?(color)

    all_valid_moves(color).empty?
  end

  def in_check?(color)
    king = find_king(color)
    all_moves(enemy_color(color)).include?(king.pos)
  end

  def all_pieces(color)
    @board.flatten.select { |piece| piece && piece.color == color }
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

  def non_uniq_valid_moves(color)
    all_valid_moves = []
    all_pieces(color).each { |piece| all_valid_moves += piece.valid_moves }
  end

  private

  def find_king(color)
    king = all_pieces(color).select { |piece| piece.is_a?(King) }.first
    king
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

end
