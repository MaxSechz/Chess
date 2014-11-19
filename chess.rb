require './lib/game.rb'

puts "Welcome to Chess!!!"
puts "Would you like to load a game? (y/n)"
if gets.chomp == "y"
  # prompt for file name
  # load file
else
  game = Game.new(HumanPlayer.new(:white), HumanPlayer.new(:black))
end

game.run
