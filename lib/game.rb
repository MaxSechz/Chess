require 'yaml'
require_relative 'board.rb'
require_relative 'players.rb'
class EnemyPieceError < ChessError
  def message
    "You chose an enemy piece!"
  end
end

class Game

  attr_reader :game_board

  def initialize(white, black, board = nil)
    @players = [white, black]
    board ||= Board.new(@players)
    @game_board = board
    @turn = 1.0
  end

  def run

    until over?
      begin

        start, end_pos = current_player.get_move(@game_board)
        if start == :save
          save_game
          redo
        elsif start == :quit
          return
        end
        @game_board.move(start, end_pos)
        stalemate_count([start, end_pos])
        puts "Turn #{@turn.to_i}"
        @turn += 0.5
        switch_player

      rescue ChessError => e
        puts e.message
        retry
      end
    end

    end_game
  end

  def save_game
    puts "Enter a file name for the saved game"
    file_name = gets.chomp
    File.open(file_name, 'w') do |file|
      file.puts self.to_yaml
    end
  end

  private

  def over?
    @game_board.checkmate?(current_player.color) ||
    stalemate?
  end

  def stalemate?
    @game_board.stalemate?(current_player.color) || @players[1].moves_in_row == 6
  end

  def end_game
    @game_board.render
    # current player is in checkmate
    if stalemate?
      puts "Stalemate"
    else
      switch_player

      puts "Congratulations, #{current_player.color.to_s.capitalize}!"
      puts "You won!"
    end
  end

  def stalemate_count(move)
    if current_player.last_move == move.reverse
      current_player.moves_in_row += 1
    end

    current_player.last_move = move
  end

  def switch_player
    @players.reverse!
  end

  def current_player
    @players[0]
  end
end
