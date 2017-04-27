### Decorator

Among the most basic questions of software engineering is this: How do you add features to your program without turning the whole thing into a huge, unmanageable mess?

What do you do when sometimes your object needs to do a little more, but sometimes a little less?

Decorator is one approach to enhancing existing object; layer features atop one another to construct objects that have exactly the right set of capabilities that you need for a given situation.

e.g. Imagine an enhanced writer:

```sample.rb
class SimpleWriter
  def initialize(path)
    @file = File.open(path, 'w')
  end

  def write_line(line)
    @file.print(line)
    @file.print("\n")
  end

  def pos
    @file.pos
  end

  def rewind
    @file.rewind
  end

  def close
    @file.close
  end
end

class NumberingWriter < WriterDecorator
  def initialize(real_writer)
    super(real_writer)
    @line_number = 1
  end

  def write_line(line)
    @real_writer.write_line("#{@line_number}: #{line}")
    @line_number += 1
  end
end

# writer = NumberingWriter.new(SimpleWriter.new('final.txt'))
# writer.write_line('Hello out there')
```


```mroe.rb
class CheckSummingWriter < WriterDecorator
  attr_reader :check_sum

  def initialize(real_writer)
    @real_writer = real_writer
    @check_sum = 0
  end

  def write_line(line)
    line.each_byte {|byte| @check_sum = (@check_sum + byte.ord) % 256 }
    @check_sum = (@check_sum + "\n".ord) % 256
    @real_writer.write_line(line)
  end
end

class TimeStampingWriter < WriterDecorator
  def initialize(component)
    super(component)
  end

  def write_line(line)
    @real_writer.write_line("#{Time.new}: #{line}")
  end
end
```

Now you can build chains of decorators with each one adding its own ingredient to the whole.

```
writer = TimeStampingWriter.new(NumberingWriter.new(
             CheckSummingWriter.new(SimpleWriter.new('final.txt'))))
writer.write_line('Hello out there')
```

These above all implement the component interface.
- ConcreteComponent is the real object that implements the basic component functionality
- Decorator class has a reference to a Component (the next Component in the chain) and it implements all of the methods of the Component type.


#### Dynamic Alternatives
Ruby allows for dynamically modifying instances. We can use to this feature to add decorators at run-time.

This is a quick and dirty approach to adding decorators to an instance. Create an alias for the original method, then add a module with the same name as the original method. This is shown below:

```dirty.rb
w = SimpleWriter.new('out')

class << w

  alias old_write_line write_line

  def write_line
    old_write_line("#{Time.new}: #{line}")
  end
end
```

Be careful of method name collisions though.
