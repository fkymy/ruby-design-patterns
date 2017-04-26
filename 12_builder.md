### Builder

A pattern designed to help configure complex objects.

e.g. building a computer.

```computer.rb
class Computer
  attr_accessor :display
  attr_accessor :motherboard
  attr_reader   :drives

  def initialize(display=:crt, motherboard=Motherboard.new, drives=[])
    @motherboard = motherboard
    @drives = drives
    @display = display
  end
end

class CPU
  # Common CPU stuff...
end

class BasicCPU < CPU
  # Lots of not very fast CPU related stuff...
end

class TurboCPU < CPU
  # Lots of very fast CPU stuff...
end

class Motherboard
  attr_accessor :cpu
  attr_accessor :memory_size

  def initialize(cpu=BasicCPU.new, memory_size=1000)
    @cpu = cpu
    @memory_size = memory_size
  end
end

class Drive
  attr_reader :type # :hard_disk, :cd or :dvd
  attr_reader :size # in mb
  attr_reader :writable # true if this drive is writable

  def initialize(type, size, writable)
    @type = type
    @size = size
    @writable = writable
  end
end
```

It will be painful to build a computer this way...
```build_comp.rb
motherboard = Motherboard.new(TurboCPU.new, 4000)

drives = []
drives << Drive.new(:hard_drive, 200000, true)
drives << Drive.new(:cd, 760, true)
drives << Drive.new(:dvd, 4700, false)

computer = Computer.new(:lcd, motherboard, drives)
```

Such construction logic can be encapsulated in a class of its own.
```simple_builder.rb
class ComputerBuilder
  attr_reader :computer

  def initialize
    @computer = Computer.new
  end

  def turbo(has_turbo_cpu=true)
    @computer.motherboard.cpu = TurboCPU.new
  end

  def display=(display)
    @computer.display=display
  end

  def memory_size=(size_in_mb)
    @computer.motherboard.memory_size = size_in_mb
  end

  def add_cd(writer=false)
    @computer.drives << Drive.new(:cd, 760, writer)
  end

  def add_dvd(writer=false)
    @computer.drives << Drive.new(:dvd, 4000, writer)
  end

  def add_hard_disk(size_in_mb)
    @computer.drives << Drive.new(:hard_disk, size_in_mb, true)
  end  
end
```

Now to make a new instance:
```build_comp.rb
builder = ComputerBuilder.new
builder.turbo
builder.add_cd(true)
builder.add_dvd
builder.add_hard_disk(100)

computer = builder.computer
```
Less burden, and hides implementation details (when building the computer, we ignored which classes represented the DVDs or the hard disks, and went on with the configuration).

#### Polymorphic Builders
Factoring out all of the construction code is the main motivation, but builders can also support the 'which class to build' decisions.

```polymorphic.rb
class DesktopComputer < Computer
  # Lots of interesting desktop details omitted...
end

class LaptopComputer < Computer
  def initialize( motherboard=Motherboard.new,  drives=[] )
    super(:lcd, motherboard, drives)
  end

  # Lots of interesting laptop details omitted...
end

class ComputerBuilder
  attr_reader :computer

  def turbo(has_turbo_cpu=true)
    @computer.motherboard.cpu = TurboCPU.new
  end

  def memory_size=(size_in_mb)
    @computer.motherboard.memory_size = size_in_mb
  end
end

class DesktopBuilder < ComputerBuilder
  def initialize
    @computer = DesktopComputer.new
  end

  def display=(display)
    @display = display
  end

  def add_cd(writer=false)
    @computer.drives << Drive.new(:cd, 760, writer)
  end

  def add_dvd(writer=false)
    @computer.drives << Drive.new(:dvd, 4000, writer)
  end

  def add_hard_disk(size_in_mb)
    @computer.drives << Drive.new(:hard_disk, size_in_mb, true)
  end  
end

class LaptopBuilder < ComputerBuilder
  def initialize
    @computer = LaptopComputer.new
  end

  def display=(display)
    raise "Laptop display must be lcd" unless display == :lcd
  end

  def add_cd(writer=false)
    @computer.drives << LaptopDrive.new(:cd, 760, writer)
  end

  def add_dvd(writer=false)
    @computer.drives << LaptopDrive.new(:dvd, 4000, writer)
  end

  def add_hard_disk(size_in_mb)
    @computer.drives << LaptopDrive.new(:hard_disk, size_in_mb, true)
  end  
end
```
Alternatively, we could have written a single builder class that creates either a laptop or a desktop system depending on the params.

#### Builders Ensure Sane objects
Builders can make object construction safer. It can make sure that the configuration requested by the client makes sense. (you can raise exceptions or handle incomplete configs)

#### Reusable Builders
It is vital to make consider whether you can use a single builder instance to create multiple objects (and not fall in the reference variable trap).
```
builder = LaptopBuilder.new
builder.add_hard_disk(1000)
builder.turbo

computer_a = builder.computer
computer_b = builder.computer

# a and b end up being references to the same computer.
```
One way to solve is to add a reset method.

#### More Elegance with Magic Methods

Magic method let the caller make up a method name according to a specific pattern, using the method_missing technique. Catch all unexpected methods calls and parse the method name:

```magic.rb
class ComputerBuilder

  def method_missing(name, *args)
    words = name.to_s.split("_")
    return super(name, *args) unless words.shift == 'add'
    words.each do |word|
      next if word == 'and'
      add_cd if word == 'cd'
      add_dvd if word == 'dvd'
      add_hard_disk(100000) if word == 'harddisk'
      turbo if word == 'turbo'
    end
  end

end

```
You can find magic methods in the finder methods of ActiveRecord.

Builder is certainly an improvement over spreading/scattering all of the object creation, configuration, and validation code throughout your application. Same object creation logic should be bundled up in one place. Builder pattern takes a multipart specification of new object and deals with all the complexity of creating it. It controls configuration and prevents invalid objects to be constructed. 
