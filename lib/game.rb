require_relative 'board.rb'

class EnemyPieceError < ChessError
  def message
    "You chose an enemy piece!"
  end
end

class Game

  attr_reader :game_board

  def initialize(white, black)
    @white, @black = white, black

    @game_board = Board.new
  end

  def run
    @current_player = @white

    until @game_board.checkmate?(@current_player.color)
      begin
        start, end_pos = @current_player.get_move(@game_board)
        @game_board.move(start, end_pos)
        switch_player

      rescue ChessError => e
        puts e.message
        retry
      end
    end

    end_game
  end
  

  private

  def end_game
    # current player is in checkmate
    switch_player

    puts "Congratulations, #{@current_player.color.to_s.capitalize}!"
    puts "You won!"
  end

  def switch_player
    @current_player = @current_player == @white ? @black : @white
  end


end

class HumanPlayer

  attr_reader :color

  def initialize(color)
    @color = color
  end

  def get_move(game_board)
    game_board.render
    puts "#{@color.to_s.capitalize}'s turn"
    puts "You are in check" if game_board.in_check?(@color)
    puts "Which piece would you like to move?"
    start = gets.chomp.split('')
    puts "Where would you like to move it?"
    end_pos = gets.chomp.split('')
    start, end_pos = convert(start), convert(end_pos)

    raise EnemyPieceError if @game_board[start] &&
                             @game_board[start].color != self.color

    [start, end_pos]
  end

  def convert(position)
    first = position[0].ord - 'a'.ord
    second = 8 - position[1].to_i

    [second, first]
  end

end

class ComputerPlayer

end
