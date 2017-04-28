### Iterator
Need for a composite to sequence through all of the subobjects without needing to know any of the details of how the aggregate object is storing them.

Provide a way to access the elements of an aggregate object sequentially without exposing its underlying representation.

An iterator provides the outside world with a sort of movable pointer into the objects stored inside an otherwise opaque aggregate object.

#### external iterator

Things like `java.util.Iterator` are external because the iterator is a separate object from the aggretate.

Here is a Java-like external iterator in Ruby:
```external.rb
class ArrayIterator
  def initialize(array)
    @array = array
    @index = 0
  end

  def has_next?
    @index < @array.length
  end

  def item
    @array[@index]
  end

  def next_item
    value = @array[@index]
    @index += 1
    value
  end
end

# array = [1, 2, 3]
# i = ArrayIterator.new(array)
# while i.has_next?
#   puts i.next_item # i.next_item.chr with strings
# end
```

#### internal iterator
All the iterating logic occurs inside the aggregate object. Use a code block to pass your logic into the aggregate which then calls the block for each of it's elements.

```internal.rb
def for_each_element(array)
  i = 0
  while i < array.length
    yield(array[i])
    i += 1
  end
end

# a = [1, 2, 3]
# for_each_element(a) { |element| puts element }
```
This is the same as the each method. Those loops are not in fact, actual built-into-the-language loops, but rather applications of internal iterators.

#### Enumerable mixin module
The Enumerable mixin provides collection classes with several traversal and searching methods like #include?(obj) #min #max #all? #sort and also <=> operator.

e.g.
```
class Account
  attr_accessor :name, :balance

  def initialize(name, balance)
    @name = name
    @balance = balance
  end
end

class Portfolio
  include Enumerable

  def initialize
    @accounts = []
  end

  def each(&block)
    @accounts.each(&block)
  end

  def add_account(account)
    @accounts << account
  end
end

# my_portfolio.any? { |account| account.balance > 2000 }
# my_portfolio.all? { |account| account.balance >= 10 }
```

#### Concerns

To make collections resistant to changes:
```immutable.rb
class ChangeResistantArrayIterator
  def initialize(array)
    @array = Array.new(array)
    @index = 0
  end

  def change_resistant_for_each_element(array)
    copy = Array.new(array)
    i = 0
    while i < copy.length
      yield(copy[i])
      i += 1
    end
  end
end
```

Concurrent modification problem
```concurrent.rb
array = ['red', 'green', 'blue', 'purple']

array.each do |color|
  puts color
  if color == 'green'
    array,delete(color)
  end
end

# outputs:
# red
# green
# purple #messed up indexing
```

ObjectSpace module is an example of internal iterator in Ruby.
`objectSpace.each_object { |object| puts "Object: #{object}" }`

```eg.rb
def subclasses_of(superclass)
  subclasses = []
  ObjectSpace.each_object(Class) do |k|
    next if !k.ancestors.include?(superclass) || superclass == k ||
             k.to_s.include?('::') || subclasses.include?(k.to_s)
    subclasses << k.to_s
  end
  subclasses
end

# subclasses_of(Numeric)
# => bignum float fixnum and integer
```
