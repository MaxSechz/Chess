
class HumanPlayer
  attr_accessor :moves_in_row, :last_move
  attr_reader :color

  def initialize(color)
    @color = color
    @moves_in_row = 0
    @last_move = nil
  end

  def get_move(game_board)
    game_board.render
    puts "#{@color.to_s.capitalize}'s turn"
    puts "You are in check" if game_board.in_check?(@color)
    puts
    puts "Enter 'save' to save, 'quit' to quit"
    puts "Which piece would you like to move?"

    start = gets.chomp.split('')
    return start.to_sym if start == "save" || start == "quit"
    start = convert(start)
    puts "Where would you like to move it?"
    end_pos = gets.chomp.split('')
    return end_pos.to_sym if end_pos == "save" || end_pos == "quit"
    end_pos = convert(end_pos)

    raise EnemyPieceError if game_board[start] &&
            game_board[start].color != self.color
            
    [start, end_pos]
  end

  def convert(position)
    raise InvalidPositionError if !("a".."z").include?(position[0]) ||
                                  !("1".."8").include?(position[1])
    first = position[0].ord - 'a'.ord
    second = 8 - position[1].to_i

    [second, first]
  end

end

module Computer
  attr_accessor :moves_in_row, :last_move

  PIECE_VALS = {"NilClass" => 0,
    "Pawn" => 1,
    "Knight" => 3,
    "Bishop" => 3,
    "Rook" => 5,
    "Queen" => 9
  }

  def initialize(color)
    @color = color
    @moves_in_row = 0
    @last_move = nil
  end

  def get_move(game_board)
    @game_board = game_board
    @game_board.render
    puts "#{@color.to_s.capitalize}'s turn"
    puts "You are in check" if game_board.in_check?(@color)


    get_move_data
  end

  def enemy
    self.color == :white ? :black : :white
  end

  def get_move_piece_value(move)
    PIECE_VALS[@game_board[move].class.to_s]
  end

  def get_move_control_value(piece, move)
    dummy_board = @game_board.dup
    dummy_board.move!(piece.pos, move)
    all_moves = dummy_board.all_valid_moves(@color)
    all_open_moves = all_moves.reject do |move|
      dummy_board.all_pieces(@color).any? {|piece| piece.pos == move}
    end

    all_moves.count
  end

  def stalemate?(move)
    moves_in_row == 5 && last_move == move.reverse
  end
end

class ComputerPlayer
  include Computer
  attr_reader :color

  def get_move_data
    piece = nil
    move = nil
    while true
      piece = @game_board.all_pieces(@color).sample
      move = piece.valid_moves.sample
      break unless piece.nil? || move.nil?
    end
    [piece.pos, move]
  end
end

class CheckmateComputerPlayer
  include Computer
  attr_reader :color

  def get_move_data
    taret_piece = nil
    target_move = nil

    while true
      target_piece = @game_board.all_pieces(@color).sample
      target_move = target_piece.valid_moves.sample
      break unless target_piece.nil? || target_move.nil?
    end

    @game_board.all_pieces(@color).each do |piece|
      piece.valid_moves.each do |move|
        if @game_board.dup.move!(piece.pos, move).checkmate?(enemy)
          target_piece = piece
          target_move = move
          break
        end
      end
    end
    [target_piece.pos, target_move]
  end
end

class SafeComputerPlayer
  include Computer
  attr_reader :color

  def get_move_data
    taret_piece = nil
    target_move = nil
    attempts = 0
    while true
      target_piece = @game_board.all_pieces(@color).sample
      target_move = target_piece.valid_moves.sample
      next if target_piece.nil? || target_move.nil?
      next attempts += 1 if @game_board.dup.move!(target_piece.pos, target_move).all_moves(enemy).include?(target_move) && attempts < 10
      break
    end

    @game_board.all_pieces(@color).each do |piece|
      piece.valid_moves.each do |move|
        if @game_board.dup.move!(piece.pos, move).checkmate?(enemy)
          target_piece = piece
          target_move = move
          break
        end
      end
    end
    [target_piece.pos, target_move]
  end
end

class ControlComputerPlayer
  include Computer
  attr_reader :color

  def get_move_data
    control_value = 0
    target_piece = nil
    target_move = [0,0]

    @game_board.all_pieces(@color).each do |piece|
      piece.valid_moves.each do |move|
        if @game_board.dup.move!(piece.pos, move).checkmate?(enemy)
          target_piece = piece
          target_move = move
          break
        end
        next if @game_board.dup.move!(piece.pos, move).all_moves(enemy).include?(move)
        value = get_move_control_value(piece, move)
        if (value >= control_value && piece.class != King) ||
          (value > control_value && piece.class == King)
          control_value = value
          target_piece = piece
          target_move = move
        end
      end
    end
    [target_piece.pos, target_move]
  end
end

class GreedyComputerPlayer
  include Computer
  attr_reader :color

  def get_move_data
    piece_value = 0
    target_piece = nil
    target_move = [0,0]
    @game_board.all_pieces(@color).each do |piece|
      piece.valid_moves.each do |move|
        if @game_board.dup.move!(piece.pos, move).checkmate?(enemy)
          target_piece = piece
          target_move = move
          break
        end

        next if (@game_board.dup.move!(piece.pos, move).all_moves(enemy).include?(move) &&
        !@game_board.in_check?(@color))

        piece_val = get_move_piece_value(move)
        if piece_val >= piece_value
          piece_value = piece_val
          target_piece = piece
          target_move = move
        end

      end
    end
    [target_piece.pos, target_move]
  end
end

class SmarterComputerPlayer
  include Computer
  attr_reader :color

  def get_move_data
    control_value = 0
    piece_value = 0
    target_piece = nil
    target_move = [0,0]

    @game_board.all_pieces(@color).each do |piece|
      piece.valid_moves.each do |move|
        if @game_board.dup.move!(piece.pos, move).checkmate?(enemy)
          target_piece = piece
          target_move = move
          break
        end


        next if (@game_board.dup.move!(piece.pos, move).all_moves(enemy).include?(move) &&
        !@game_board.in_check?(@color))

        value = get_move_control_value(piece, move)
        piece_val = get_move_piece_value(move)
        if piece_val > piece_value
          piece_value = piece_val
          control_value = value
          target_piece = piece
          target_move = move
        elsif piece_val == piece_value
          if (value >= control_value && piece.class != King) ||
            (value > control_value && piece.class == King)
            control_value = value
            target_piece = piece
            target_move = move
          end
        end
      end
    end
    [target_piece.pos, target_move]
  end
end
