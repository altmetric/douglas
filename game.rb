class Game
  def run(state)
    while (input = prompt)
      state = state.run(input)
      puts state.description

      unless state.items.empty?
        puts
        state.items.each do |item|
          puts "There is #{item.name} here."
        end
      end

      unless state.inventory.empty?
        puts
        puts "You are carrying the following items in your satchel:"
        state.inventory.each do |item|
          puts "- #{item.name}"
        end
      end
    end
  end

  def prompt
    $stdout << '> '

    gets.to_s.strip
  end
end

class State
  attr_reader :environment

  def initialize(environment)
    @environment = environment
  end

  def run(input)
    case input
    when "help", "h"
      Help.new(environment.merge(previous_state: self))
    when "look", "l"
      self
    when /look at (.+)/i
      Looking.new(environment.merge(previous_state: self, subject: items.find { |item| item.names.include?($1) }))
    when /(quit|exit)/i
      Quit.new(environment)
    when /pick up (.+)/i
      PickingUp.new(environment.merge(previous_state: self, subject: items.find { |item| item.names.include?($1) }))
    else
      self
    end
  end

  def items
    []
  end

  def name
    environment.fetch(:name)
  end

  def previous_state
    environment.fetch(:previous_state)
  end

  def subject
    environment.fetch(:subject)
  end

  def inventory
    environment.fetch(:inventory, [])
  end
end

class Greeting < State
  def run(name)
    if name.strip.empty?
      self.class.new(environment.merge(name_attempts: name_attempts + 1))
    else
      OutsideOffices.new(environment.merge(name: name, outside_offices: { items: [AccessCard.new] }))
    end
  end

  def description
    case name_attempts
    when 1
      "No need to be shy; pray tell, what is your name?"
    when 5
      "Cut me some slack here, I'm going to keep asking you forever. WHAT IS THE NAME?"
    else
      "Seriously! What's your name?"
    end
  end

  def name_attempts
    environment.fetch(:name_attempts, 1)
  end
end

class OutsideOffices < State
  def run(input)
    case input
    when /east/i
      Reception.new(environment.merge(reception: { items: [] }))
    else
      super
    end
  end

  def items
    environment.fetch(:outside_offices).fetch(:items) + [Statues.new, ConfusedMemberOfThePublic.new]
  end

  def description
    <<~DESC
      You are standing outside some glorious corporate offices.

      There are shiny glass doors to the east.
    DESC
  end
end

class Reception < State
  def run(input)
    case input
    when /west/i
      OutsideOffices.new(environment)
    else
      super
    end
  end

  def items
    environment.fetch(:reception).fetch(:items) + [Receptionist.new]
  end

  def description
    <<~DESC
      Behind the reception desk, you spy a bland corporate logo.

      You can exit to the west.
    DESC
  end
end

class Receptionist
  def name
    "a grumpy-looking receptionist"
  end

  def pickupable?
    false
  end

  def names
    ['receptionist', 'grumpy receptionist']
  end

  def description
    "They don't look very happy at all."
  end
end

class PickingUp < State
  def run(input)
    if subject&.pickupable?
      previous_state.class.new(previous_state.environment.merge(items: [], inventory: inventory + [subject])).run(input)
    else
      previous_state.run(input)
    end
  end

  def description
    if subject&.pickupable?
      "You pick up #{subject.name} and put it neatly in your satchel."
    elsif subject
      "You can't possibly pick up #{subject.name}, you mad horse!"
    else
      "I can't pick up something I can't see!"
    end
  end
end

class Statues
  def name
    "a pair of weird statues"
  end

  def pickupable?
    false
  end

  def names
    ['weird statues', 'pair of weird statues', 'a pair of weird statues', 'statues', 'statue', 'art', 'faces']
  end

  def description
    "The statues fill you with an unprecedented sense of serenity."
  end
end

class ConfusedMemberOfThePublic
  def name
    "a confused member of the public"
  end

  def pickupable?
    false
  end

  def names
    ["confused member of the public", "member of the public"]
  end

  def description
    "They look very confused indeed"
  end
end

class AccessCard
  def name
    "an access card"
  end

  def pickupable?
    true
  end

  def names
    ["access card", "card"]
  end

  def description
    "Some sort of access card with quite an ugly mug on it. The name reads \"Tarquin Thunder\"."
  end
end

class Looking < State
  def run(input)
    previous_state.run(input)
  end

  def description
    return "I can't see any such thing" unless subject

    subject.description
  end
end

class Help < State
  def run(input)
    previous_state.run(input)
  end

  def description
    <<~DESC
      You can try to pick things up by typing "pick up SOMETHING", you can try
      to look at things by typing "look at SOMETHING". Other than that, I
      can't help you, #{name}!
    DESC
  end
end

class Quit < State
  def run(_input)
    exit
  end

  def description
    "Any last words?"
  end
end

trap 'INT' do
  puts "Byesibye!"
  exit
end

puts "\e[2J"
puts "Greetings, traveller! What is your name?"
Game.new.run(Greeting.new({}))
