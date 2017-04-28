### Factory

How to produce the right objects for the problem at hand.
Picking the right class for the circumstance.

#### Problem

Imagine building a simulation of life in a pond.

```pond.rb
class Duck
  def initialize(name)
    @name = name
  end

  def eat
    puts("Duck #{@name} is eating.")
  end

  def speak
    puts("Duck #{@name} says Quack!")
  end

  def sleep
    puts("Duck #{@name} sleeps quietly.")
  end
end

class Pond
  def initialize(number_ducks)
    @ducks = []
    number_ducks.times do |i|
      duck = Duck.new("Duck#{i}")
      @ducks << duck
    end
  end

  def simulate_one_day
    @ducks.each {|duck| duck.speak}
    @ducks.each {|duck| duck.eat}
    @ducks.each {|duck| duck.sleep}
  end
end

# pond = Pond.new(3)
# pond.simulate_one_day
```

Now, frog is added:

```frog.rb
class Frog
  def initialize(name)
    @name = name
  end

  def eat
    puts("Frog #{@name} is eating.")
  end

  def speak
    puts("Frog #{@name} says Crooooaaaak!")
  end

  def sleep
    puts("Frog #{@name} doesn't sleep, he croaks all night!")
  end
end
```

The problem is, Pond class initialize method explicitly creates ducks.
You need to separate out things that are changing from the things that are` not.

The 'which class to use' decision can be solved by template method, applied to creating new objects.

```pond.rb
class Pond
  def initialize(number_animals)
    @animals = []
    number_animals.times do |i|
      animal = new_animal("Animal#{i}")
      @animals << animal
    end
  end

  def simulate_one_day
    @animals.each {|animal| animal.speak}
    @animals.each {|animal| animal.eat}
    @animals.each {|animal| animal.sleep}
  end
end

class DuckPond < Pond
  def new_animal(name)
    Duck.new(name)
  end
end

class FrogPond < Pond
  def new_animal(name)
    Frog.new(name)
  end
end

# pond = FrogPond.new(3)
# pond.simulate_one_day
```

Pushing 'which class' decision down on the subclass is called the Factory Method pattern.
Creators, the base and concrete class contain the factory method
Products are the objects that are being created.

The two products sharing a common base class are not actually relatives, they just share a common set of methods.

Moving further, plants are added:

```algae.rb
class Algae
  def initialize(name)
    @name = name
  end

  def grow
    puts("The Algae #{@name} soaks up the sun and grows")
  end
end

class WaterLily
  def initialize(name)
    @name = name
  end

  def grow
    puts("The water lily #{@name} floats, soaks up the sun and grows")
  end
end
```

now the pond has to be modified:

```pond.rb
class Pond
  def initialize(number_animals, number_plants)
    @animals = []
    number_animals.times do |i|
      animal = new_animal("Animal#{i}")
      @animals << animal
    end

    @plants = []
    number_plants.times do |i|
      plant = new_plant("Plant#{i}")
      @plants << plant
    end
  end

  def simulate_one_day
    @plants.each {|plant| plant.grow }
    @animals.each {|animal| animal.speak}
    @animals.each {|animal| animal.eat}
    @animals.each {|animal| animal.sleep}
  end
end


class DuckWaterLilyPond < Pond
  def new_animal(name)
    Duck.new(name)
  end

  def new_plant(name)
    WaterLily.new(name)
  end
end

class FrogAlgaePond < Pond
  def new_animal(name)
    Frog.new(name)
  end

  def new_plant(name)
    Algae.new(name)
  end
end
```

As seen, separating method for each type of object added that needs to be produced can become a burden.

A different approach is to have a single factory method that takes a parameter.

```parameterized.rb
class Pond
  def initialize(number_animals, number_plants)
    @animals = []
    number_animals.times do |i|
      animal = new_organism(:animal, "Animal#{i}")
      @animals << animal
    end

    @plants = []
    number_plants.times do |i|
      plant = new_organism(:plant, "Plant#{i}")
      @plants << plant
    end
  end

  # ...

  def simulate_one_day
    @plants.each {|plant| plant.grow}
    @animals.each {|animal| animal.speak}
    @animals.each {|animal| animal.eat}
    @animals.each {|animal| animal.sleep}
  end
end

class DuckWaterLilyPond < Pond
  def new_organism(type, name)
    if type == :animal
      Duck.new(name)
    elsif type == :plant
      WaterLily.new(name)
    else
      raise "Unknown organism type: #{type}"
    end
  end
```

#### Classes are objects
When the application above expands, the number of possible subclasses added can be scary.

The thing to realize is that classes are just objects:
```pond.rb
class Pond
  def initialize(number_animals, animal_class,
                 number_plants, plant_class)

    #storing the classes here
    @animal_class = animal_class
    @plant_class = plant_class

    @animals = []
    number_animals.times do |i|
      animal = new_organism(:animal, "Animal#{i}")
      @animals << animal
    end

    @plants = []
    number_plants.times do |i|
      plant = new_organism(:plant, "Plant#{i}")
      @plants << plant
    end
  end

  def simulate_one_day
    @plants.each {|plant| plant.grow}
    @animals.each {|animal| animal.speak}
    @animals.each {|animal| animal.eat}
    @animals.each {|animal| animal.sleep}
  end

  def new_organism(type, name)
    if type == :animal
      @animal_class.new(name)
    elsif type == :plant
      @plant_class.new(name)
    else
      raise "Unknown organism type: #{type}"
    end
  end
end

# pond = Pond.new(3, Duck, 2, WaterLily)
# pond.simulate_one_day
```

Imagine your simulator expanding even further:

```jungle.rb
class Tree
  def initialize(name)
    @name = name
  end

  def grow
    puts("The tree #{@name} grows tall")
  end
end

class Tiger
  def initialize(name)
    @name = name
  end

  def eat
    puts("Tiger #{@name} is eating anything it wants.")
  end

  def speak
    puts("Tiger #{@name} Roars!")
  end

  def sleep
    puts("Tiger #{@name} sleeps anywhere it wants.")
  end
end
```
Now it is more appropriate to name the creator class `Habitat` like
```habitat.rb
jungle = Habitat.new(1, Tiger, 4, Tree)
jungle.simulate_one_day

pond = Habitat.new(2, Duck, 4, WaterLily)
pond.simulate_one_day
```

#### Bundles of Object Creation (Abstract factory class)
Problem Again.
Habitat class should not create incoherent combinations. In this case, things that are ecologically unsound.

Instead of passing individual plants and animal classes, we can pass a single object that knows how to create a consistent set of products.
An object dedicated to creating a compatible set of objects is called an Abstract Factory.

```abs.rb
class PondOrganismFactory
  def new_animal(name)
    Frog.new(name)
  end

  def new_plant(name)
    Algae.new(name)
  end
end

class JungleOrganismFactory
  def new_animal(name)
    Tiger.new(name)
  end

  def new_plant(name)
    Tree.new(name)
  end
end
```

now Habitat can use the abstract factory instead:

```habitat.rb
class Habitat
  def initialize(number_animals, number_plants, organism_factory)
    @organism_factory = organism_factory

    @animals = []
    number_animals.times do |i|
      animal = @organism_factory.new_animal("Animal#{i}")
      @animals << animal
    end

    @plants = []
    number_plants.times do |i|
      plant  = @organism_factory.new_plant("Plant#{i}")
      @plants << plant
    end    
  end

  # Rest of the class ...

  def simulate_one_day
    @plants.each {|plant| plant.grow}
    @animals.each {|animal| animal.speak}
    @animals.each {|animal| animal.eat}
    @animals.each {|animal| animal.sleep}
  end

  def new_organism(type, name)
    if type == :animal
      @animal_class.new(name)
    elsif type == :plant
      @plant_class.new(name)
    else
      raise "Unknown organism type: #{type}"
    end
  end
end

# jungle = Habitat.new(1, 4, JungleOrganismFactory.new)
# jungle.simulate_one_day
#
# pond = Habitat.new(2, 4, PondOrganismFactory.new)
# pond.simulate_one_day
```

The abstract factory pattern boils down to a problem and a solution.
The problem is that you need to create sets of compatible objects.
The solution is that you write a separate class to handle the creation.

#### Classes are just objects (again)

One way to look at the abstract factory is to view it as a sort of super-duper-class object.
While ordinary objects know how to create only one type of object, an instance of themselves, the abstract factory knows how to create several different types of objects, its products.

To sum up:
Bundle of class objects, with one class for each product.
The important thing about the abstract factory is to encapsulate the knowledge of which product types go together.

Use this technique when you have a choice of several different, related classes and you need to choose among them.
