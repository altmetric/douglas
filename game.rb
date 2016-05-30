require 'hamster'

newspaper = Hamster::Hash[description: 'A damp copy of the Daily Herald', names: Hamster::Set['paper', 'newspaper', 'herald']]
lobby = Hamster::Hash[description: 'You are in a dimly-lit hotel lobby, it seems to have been abandoned some time ago.']
outside = Hamster::Hash[description: 'It is far too bright to see', items: Hamster::Vector[newspaper]]

outside = outside.put(:north, lobby)
lobby = lobby.put(:south, outside)

def run(world, input)
  case input
  when 'look', 'l'
    puts world.fetch(:description)
    unless world.fetch(:items, []).empty?
      puts
      puts 'You can see the following items here:'

      world.fetch(:items).each do |item|
        puts "* #{item.fetch(:description)}"
      end
    end

    [world, nil]
  when /pick up (?<name>\S+)/
    name = $~[:name]
    item = world.fetch(:items, []).find { |item| item.fetch(:names).include?(name) }

    if item
      puts 'You pick it up.'

      [world.put(:items) { |items| items.delete(item) }, nil]
    else
      puts 'You cannot see anything of that name here.'

      [world, nil]
    end
  when 'north', 'n'
    if world.key?(:north)
      [world.fetch(:north), 'look']
    else
      puts 'There is nothing to the north'

      [world, nil]
    end
  when 'east', 'e'
    if world.key?(:east)
      [world.fetch(:east), 'look']
    else
      puts 'There is nothing to the east'

      [world, nil]
    end
  when 'south', 's'
    if world.key?(:south)
      [world.fetch(:south), 'look']
    else
      puts 'There is nothing to the south'

      [world, nil]
    end
  when 'west', 'w'
    if world.key?(:west)
      [world.fetch(:west), 'look']
    else
      puts 'There is nothing to the west'

      [world, nil]
    end
  when 'quit', 'exit', 'q'
    [nil, nil]
  when 'help', 'h', '?'
    puts 'Try LOOKing or moving to the NORTH, EAST, SOUTH or WEST.'

    [world, nil]
  when ''
    [world, nil]
  else
    puts 'Sorry, I do not know what you mean.'

    [world, nil]
  end
end

world = lobby
input = 'look'

while world
  input ||= gets.chomp
  world, input = run(world, input)
end

puts 'Thanks for playing!'
