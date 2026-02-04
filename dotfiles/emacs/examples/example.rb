#!/usr/bin/env ruby
# Example Ruby file

class Person
  attr_reader :name, :age

  def initialize(name, age)
    @name = name
    @age = age
  end

  def greet
    "Hello, my name is #{name}"
  end
end

def process_items(items)
  items.select { |item| item.length > 3 }
    .map(&:upcase)
end

if __FILE__ == $PROGRAM_NAME
  person = Person.new("Alice", 30)
  puts person.greet

  items = %w[foo bar hello world]
  puts process_items(items)
end
