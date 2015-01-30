require './lib/game.rb'

puts "Welcome to Chess!!!"
puts "Would you like to load a game? (y/n)"
if gets.chomp == "y"
  puts "Put the file name of the saved board"
  file_name = gets.chomp
  game = YAML.load(File.read(file_name))
else
  player_class = [HumanPlayer, ComputerPlayer, CheckmateComputerPlayer, SafeComputerPlayer, ControlComputerPlayer, GreedyComputerPlayer, SmarterComputerPlayer]
  begin
    puts "Who will be white? 1. Human 2. Random Computer 3. Checkmate Computer 4. Safe Computer 5. Control Computer 6. Greedy Computer 7. Smartest Computer"
    response = gets.chomp.to_i
    player_one = player_class[response - 1]
  rescue
    puts "#{response} is an invalid choice, try again"
    retry
  end
  begin
    puts "Who will be black? 1. Human 2. Random Computer 3. Checkmate Computer 4. Safe Computer 5. Control Computer 6. Greedy Computer 7. Smartest Computer"
    response = gets.chomp.to_i
    player_two = player_class[response - 1]
  rescue
    puts "#{response} is an invalid choice, try again"
    retry
  end
  game = Game.new(player_one.new(:white), player_two.new(:black))
end

game.run
