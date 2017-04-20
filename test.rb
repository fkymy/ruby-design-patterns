kind = case year
       when 1850..1889 then 'Blues'
       when 1890..1909 then 'Ragtime'
       else 'Jazz'
       end

result = if some_condition
           calc_something
         else
           calc_something_else
         end

class FooError < StandardError; end
# or
FooError = Class.new(StandardError)

def some_method
  data = initialize(options)

  data.manipulate!

  data.result
end

def some_method
  result
end

some_method(size, count, color)

def some_method(arg1 = :default, arg2 = nil, arg3 = [])
  #do something here...
end

def send_mail(source)
  Mailer.deliver(to: 'aaa@example.com', from: 'us@example.com', subject: 'aaaa', body: source.text)
end

def send_mail(source)
  Mailer.deliver(
    to: 'aaaa',
    from: '',
    subject: 'bbbb',
    body: source.text
  )
end

def send_mail(source)
  Mailer.deliver(to: 'aaaa',
                 from: 'bbb',
                 body: source.text)
end


menu_iten = [
  'a', 'b', 'c', 'd'
]


menu_iten =
  ['a', 'b',
    'c', 'd']
num = 1_000_000

first, *list = [1, 2, 3, 4]

hello_array = *'Hello' #=> ['hello']

a = *(1..3)

#bad
if condition
  result = x
else
  result = y
end

result =
  if condition
    x
  else
    y
  end
# because if and case returns last value
ok = got_needed_args && args_are_valid

fail(RuntimeError, 'Failed to save document!') unless document.save
# or
document.save || fail(RuntimeError, 'Failed to save document.')

do_something if some_condition
some_condition && do_something

do_something while some_condition

#bad
do_something while !some_condition
#ok
do_something until some_condition

#infinite loop Kerne#loop
# not
while true
  do_something
end
until false
  do_something
end

loop do
  do_something
end

loop do
  puts val
  val +=1
  break unless val < 0
end

user.set(name: 'John', age: 45, permissions: { read: true })

class Person < ActiveRecord::Base
  # not
  validates(:name, { presence: true, length: { within: 1..10 } })
  # but
  validates :name, presence: true, length: { within: 1..10  }
end

# not
names.map { |name| name.upcase }
# but
names.map(&:upcase)

names.each do |name|
  puts name
end

names.each { |name| puts name }

names.select { |name| name.start_with?('S') }.map(&:upcase)

def with_tmp_dir(&block)
  Dir.mktmpdir do |tmp_dir|
    Dir.chdir(tmp_dir, &block)
  end
end

with_tmp_dir do |dir|
  puts "dir is accessible as parameter and pwd is set: #{dir}"
end

def ready?
  if last_reviewed_at > last_updated_at
    worker.update(content, options)
    self.status = :in_progress
  end
  status == :verified
end

class Foo
  attr_accessor :options

  def initialize(options)
    self.options = options
  end

  def do_something(params = {})
    unless params[:when] == :later
      output(options[:message])
    end
  end
end

if (v = array.grep(/foo/))
  do_something(v)
end

v = array.grep(/foo/)
if v
  do_somthing(v)
end

name = name ? name : 'Bozhidar'
name ||= 'Boshidar'

enabeled ||= true
# to
enabled = true if enabled.nil?

something = something.downcase if something
# to
something = something && something.downcase
something &&= something.downcase

something.is_a?(Array)
(1..100).include?(7)
some_string =~ /something/

# not
$:.unshift File.dirname(__FILE__)
# but
require 'English'
$LOAD_PATH.unshift File.dirname(__FILE__)

def foo(x)
  def bar(y)
    # body
  end

  bar(x)
end

def bar(y)
  # something
end

def foo(x)
  bar(x)
end

def foo(x)
  bar = ->(y) { ... }
  bar.call(x)
end

l = ->(a, b) { a + b }
l.call(1, 2)

l = lambda do |a, b|
  tmp = a * 6
  tmp * b / 10
end

l = -> { something }

p = Proc.new { |n| puts n }

p = proc { |n| puts n }

l = ->(v) { puts v }
l.call(1)

result = hash.map { |_k, v| v + 1 }

def something(x)
  _unsused_var, used_var = something_else(x)
  # some code
end

result = hash.map { |_, v| v + 1 }
def something(x)
  _, used_var = something_else(x)
end

# $stdout over STDOUT
# warn over $stderr.puts

sprintf('%{first} %{second}', first: 20, second: 10)

format('%d %d', 20, 10)

%w[one two three].join(', ')

# not
paths = [paths] unless paths.is_a?(Array)
paths.each { |path| do_something(path) }

# or
[*paths].each { |path| do_something(path) }

# but
Array(paths).each { |path| do_something(path) }

do_something if x.between?(100, 200)

do_something if something != nil
# to
do_something if somethig

def value_set?
  !@some_boolean.nil?
end

at_exit { puts 'Goodbye!' }

# bad
def compute_thing(thing)
  if thing[:foo]
    update_with_bar(thing[:foo])
    if thing[:foo][:bar]
      partial_compute(thing)
    else
      re_compute(thing)
    end
  end
end
# good (guard clause)
def compute_thing(thing)
  return unless thing[:foo]
  update_with_bar(thing[:foo])
  return re_compute(thing) unless thing[:foo][:bar]
  partial_compute(thing)
end

array.each do |item|
  if item > 1
    puts item
  end
end

array.each do |item|
  next unless item > 1
  puts item
end

all_songs = users.map(&:songs).flatten.uniq
# better
all_songs = users.flat_map(&:songs).uniq

class Array
  def flatten_once!
    res = []

    each do |e|
      [*e].each { |f| res << f }
    end

    replace(res)
  end

  def flatten_once
    dup.flatten_once!
  end
end

class SomeClass
  def self.some_method
    # somethihg
  end

  def self.some_other_method
    # other
  end
end

# => prefer modules
module SomeModule
  module_function # over extend self

  def some_method
  end

  def some_other_method
  end
end

module SomeModule
  extend self

  def parse_something(string)
    # do something
  end

  def other_util(num, string)
    # other thing
  end
end

class Person
  attr_reader :first_name, :last_name

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end

  def to_s
    "#{@first_name} #{@last_name}"
  end
end

# use attriburte names for accessors(readers) and attr_name= for mutators(writers)
# bad
class Person
  def get_name
    "#{@first_name} #{@last_name}"
  end

  def set_name(name)
    @first_name, @last_name = name.split(' ')
  end
end

# good
class Person
  def name
    "#{@first_name} #{@last_name}"
  end

  def name=(name)
    @first_name, @last_name = name.split(' ')
  end
end

person = Person.new)
person.name= first_last


class Person
  attr_accessor :first_name, :last_name

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end
end

Person = Struct.new(:first_name, :last_name) do

end

# factory methods
class Person
  def self.create(optional_has)
    # some other sensible way of creating instances
  end
end

class TestClass
  # bad
  def self.call(param1, param2)
    self.new(param1).call(param2)
  end

  def self.call(param1, param2)
    new(param1).call(param2)
  end
end

# returning in ensure means no raise
def foo
  raise
ensure
  return 'very bad idea'
end


def foo
  # mail logic
rescue
  # failure handling
end

# COOL!

begin
  something_that_might_fail
rescue IOError
  # handle IOError
end

begin
  something_else_that_might_fail
rescue IOError
  # handle IOError
end

# to
def with_io_error_handling
  yield
rescue IOError
end

with_io_error_handling { something_that_might_fail }
with_io_error_handling { something_else_that_might_fail }

# DO NOT USE EXCEPTION FOR FLOW CONTROL

# release external resources obtained by your program
f = File.open('testfile')
begin
  # some process
rescue
  # handle error
ensure
  f.close if f
end

# or
File.open('testfile') do |f|
  # some action
end

# Use hash fetch with dealing with hash keys that should be present
heroes = { batman: 'aaa', superman: 'bbbb' }

heroes[:batman] # => aaa
heroes[:superrrrmannn] # => nil

heroes.fetch(:superrrmannn) # => raise KeyError

code = <<~END
  def test
    some_method
    other_method
  end
END


















