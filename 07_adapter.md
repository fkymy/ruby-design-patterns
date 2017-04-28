### Adapter

>Convert the interface of a class into another interface clients expect. An adapter lets classes work together that could not otherwise because of incompatible interfaces.

Bridge between the gap between mismatching software interfaces.

Imagine an existing class that encrypts a file:

```encrypter.rb
class Encrypter
  def initialize(key)
    @key = key
  end

  def encrypt(reader, writer)
    key_index = 0
    while not reader.eof?
      clear_char = reader.getc
      encrypted_char = clear_char.ord ^ @key[key_index].ord
      writer.putc(encrypted_char.chr)
      key_index = (key_index + 1) % @key.size
    end
  end
end

#
# open two files, and call encrypt with a secret key
#

# reader = File.open('message.txt')
# writer = File.open('message.encrypted','w')
# encrypter = Encrypter.new('my secret key')
# encrypter.encrypt(reader, writer)
# writer.close
```
What happens if the data we want to secure happens to be in a string rather than a file?
Solution: we need an object that looks like an open file that supports the same interface as the Ruby IO object on the outside.

```string.rb
class StringIOAdapter
  def initialize(string)
    @string = string
    @position = 0
  end

  def getc
    if @position >= @string.length
      raise EOFError
    end
    ch = @string[@position]
    @position += 1
    return ch
  end

  def eof?
    return @position >= @string.length
  end
end

#
# similar interface!
#

# encrypter = Encrypter.new('XYZZY')
# reader= StringIOAdapter.new('We attack at dawn')
# writer=File.open('out.txt', 'w')
# encrypter.encrypt(reader, writer)
# writer.close
```

The client excepts the target to have a certain interface, but unknown to the client is that the target object is really an adapter, and buried inside of the adapter is a reference to a second object, the adaptee which actually performs the work.

#### Near Misses
There are however frustrating situations where the interfaces are ALMOST the same.

```renderer.rb
class Renderer
  def render(text_object)
    text = text_object.text
    size = text_object.size_inches
    color = text_object.color

    # render the text ...

    "#{text}/#{size}/#{color}"
  end
end

#
# very similar adaptees
#
class TextObject
  attr_reader :text, :size_inches, :color

  def initialize(text, size_inches, color)
    @text = text
    @size_inches = size_inches
    @color = color
  end
end

class BritishTextObject
  attr_reader :string, :size_mm, :colour

  # ...

  def initialize(string, size_mm, colour)
    @string = string
    @size_mm = size_mm
    @colour = colour
  end
end

```

By using the normal Adapter pattern:

```oneway.rb
class BritishTextObjectAdapter < TextObject
  def initialize(bto)
    @bto = bto
  end

  def text
    return @bto.string
  end

  def size_inches
    return @bto.size_mm / 25.4
  end

  def color
    return @bto.colour
  end
end

```

But this seems like too much work for a tweak.

#### Adapter Alternative

Ruby allows for classes to be modified at runtime. Consequently, rather than create an adapter to modify a classes API, we can simply modify the class at runtime to add or alter methods.

```alternative.rb
#
# Make sure the original class is loaded
#
require_relative 'british_text_object'

#
# Now add some methods to the original class
#
class BritishTextObject
  def color
    return colour
  end

  def text
    return string
  end

  def size_inches
    return size_mm / 25.4
  end
end
```
You shouldn't, however, get too excited and monkey patch like this:

```monkey.rb
class Fixnum
  def abs
    return 42
  end
end
```

Alternatively, Ruby also allows the runtime modification of individual instances.

```instance.rb
bto = BritishTextObject.new('hello', 50.8, :blue)

class << bto
  def color
    colour
  end

  def text
    string
  end

  def size_inches
    return size_mm/25.4
  end
end

puts bto.text
puts bto.color
puts bto.size_inches
```

This is the same as defining methods on the instances:
```
bto = BritishTextObject.new('hello', 50.8, :blue)

def bto.color
  colour
end

def bto.text
  string
end

def bto.size_inches
  return size_mm/25.4
end

puts bto.text
puts bto.color
puts bto.size_inches

```
Methods that are unique to an object is called singleton methods. (This has nothing to do with the Singleton Pattern)

In the example above, Ruby actually looks into the singleton class first for the method called, so any method defined in the singleton class will override the method in the regular classes and modules.

Modifying instances or classes at run-time is advisable only when:

- The modifications are simple
- You understand the class you're modifying well and are sure your changes wont break things.


For clever application this pattern, check out ActiveRecord and how it deals with different database systems.

---

The Adapter pattern is the first member of a family of patterns we will encounter; a family of patterns (others being proxy and decorator) in which one object stands in for another object. The difference between those is the intent.
