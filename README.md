### Design Patterns in Ruby by Russ Olsen

must buy.

![cover](cover.jpg "Cover")

Assumptions:
- ruby 2.2.0
- some parts does not follow the [ruby-style-guide](https://github.com/fortissimo1997/ruby-style-guide)

---

Gang of Four design patterns stuck to the middle ground of object-oriented design, and focused on some key questions:

How do objects like the ones you tend to find in most systems relate to one another?
How should they be coupled together?
What should they know about each other?
How can we swap out parts that are likely to change frequently?

The answer boils down to these points:

- Separate out the things that change fro those that stay the same.
- Program to an interface, not an implementation.
- Prefer composition over inheritance.
- Delegate, deletage, deletage.
- You ain't gonna need it.

#### Separate out the things that change fro those that stay the same.

A key goal of software engineering is to build systems that allow us to contain the damage. In an ideal system, all changes are local. When you make a change, it shouldn't ripple through to all of the code. If you an identify which aspects of your system design are likely to change, you can isolate those bits from the more stable parts. The changes can be confined to those walled-off, change-prone areas and the rest of your code can live on in stable peace. But how?

#### Program to an interface, not an implementation.

A good start is to write code that is less tightly coupled to itself in the first place.

For example,

```car.rb
my_car = Car.new
my_car.drive(200)
```

This bit of code is married to the Car class. Now a second type of vehicle is added

```monstrosity.rb
if is_car
  my_car = Car.new
  my_car.drive(200)
else
  my_plane = AirPlane.new
  my_plane.fly(200)  
```

Not only is this code messy, but it is now also coupled to both cars and airplanes. You can imagine the nightmare of adding more vehicles to this code.

A better solution is to return to OOP 101 and apply a liberal dose of *polymorphism*.

```better.rb
my_vehicle = get_vehicle
my_vehicle.travel(200)
```
This second example illustrates the principle of programming to an interface.

The idea here is to program to the most general type you can. Ruby, a language that lacks interfaces in the built-in syntax sense, actually encourages  you to program to your interfaces in the sense of programming to the most general types.

#### Prefer composition over inheritance.

Another approach to the first point is compotition.

Inheritence may seem like the solution to every problem, but it tends to marry the subclass to the superclass. Change the behavior of the superclass, and there is a excellent chance that you have also changed the behavior of the subclass.

For composition, we try to avoid saying that an object *is a kind of* something and instead say it *has* something

```inheritence.rb
class Vehicle
  def start_engine
  end

  def stop_engine
  end
end

class Car < Vehicle
  def sunday_drive
    start_engin
    stop_engine
  end
end
```

```composition.rb
class Engine
  def start
  end

  def stop
  end
end

class Car
  def initialize
    @engine = Engine.new
  end

  def sunday_drive
    @engine.start
    @engine.end
  end
end
```

Assembling functionality with composition offers advantages:
- The engine code is factored out into its own class, ready for reuse.
- By untangling the engine-related code from Vehicle, we have simplified the Vehicle class.
- We have increased encapsulation. Separating out the engine-related code from Vehicle ensures that a firm wall of interface exists between the car and its engine.
- Opened the possibility of other kinds of engines, the Engine class itself could become an abstract type, and we have a variety of engines, such as GasolineEngine and DieselEngine.


#### Delegate, delegate, delegate.

The original Car class in inheritence.rb exposed `start_engine` and `stop_engine` method to the world. Of course, we can do the same thing in our composition implementation of Car by simply foisting off the work onto the Engine object:

```delegate.rb
class Car
  def initialize
    @engine = GasolineEngine.new
  end

  def sunday_drive
    @engine.start
    @engine.stop
  end

  def switch_to_diesel
    @engine = DieselEngine.new
  end

  def start_engine
    @engine.start
  end

  def stop_engine
    @engine.stop
  end
end

```

This simple 'pass the buck' technique goes by the somewhat pretentious name of delegation. When `start_engine` or `stop_engine` is called, the car object stays 'Not my department', and hands the whole problem tot the engine. The Car class knows that Engine can do the job, but knows nothing else about engines.

The combination of composition and delegation is a powerful and flexible alternative to inheritance.

#### You Ain't Gonna Need It (YAGNI)

The YAGNI principle says simply that you should not implement features, or design in flexibility, that you don't need right now. Why? Because the chances are, you ain't gonna need it later, either.

More reasons:

- We tend to be wrong when we try to anticipate exactly what we will need in the future.
- We are betting to write code now that will solve a problem in the future, which has not come up yet.
- You are guilty of programming while stupid; if you wait until you really need the thing, you are likely to have a better understanding of what you need to do and how you should go about doing it.
