require_relative 'board.rb'

class Game

  attr_reader :game_board
  def initialize(white, black)
    @white, @black = white, black

    @game_board = Board.new
  end

  def run
    current_player = @white

    begin

      @game_board.render

      start, end_pos = current_player.get_move

      raise "Not your piece" if @game_board[start].color != current_player.color

      @game_board.move(start, end_pos)


      current_player = current_player == @white ? @black : @white
    rescue
      puts "try again"
      retry

    end until @game_board.checkmate?(current_player.color)
  end

end

class HumanPlayer

  attr_reader :color

  def initialize(color)
    @color = color
  end

  def get_move
    puts "Which piece would you like to move?"
    start = gets.chomp.split('')
    puts "Where would you like to move it?"
    end_pos = gets.chomp.split('')
    [convert(start), convert(end_pos)]
  end

  def convert(position)
    first = position[0].ord - 'a'.ord
    second = 8 - position[1].to_i
    [second, first]
  end

end

class ComputerPlayer

end
