require './lib/game.rb'

puts "Welcome to Chess!!!"
puts "Would you like to load a game? (y/n)"
if gets.chomp == "y"
  puts "Put the file name of the saved board"
  file_name = gets.chomp
  game = YAML.load(File.read(file_name))
else
  game = Game.new(HumanPlayer.new(:white), HumanPlayer.new(:black))
end

game.run
