### Strategy

#### Problem:
Building a system that is highly integrated - a system where every part is aware of the state of the whole.

e.g.
Making the Employee object spread the news about salary changes without tangling it up with the payroll system.

#### Solution:
Building a clean interface between the source of the news that some object has changed and the consumers of that news.

```employee.rb
class Employee
 attr_reader :name
 attr_accessor  :title, :salary

 def initialize( name, title, salary )
   @name = name
   @title = title
   @salary = salary
 end
end

# pooske = Emploee.new('Pooske Fuku', 'engineer', 30000.0)
# Pooske gets a raise
# pooske.salary = 35000.0
```

Here is a naive solution hardcoded.

```hardcoded.rb
class Payroll
  def update( changed_employee )
    puts "Cut a new check for #{changed_employee.name}!"
    puts "His salary is now #{changed_employee.salary}!"
  end
end

class Employee
  attr_reader :name, :title
  attr_reader :salary

  def initialize( name, title, salary, payroll)
   @name = name
   @title = title
   @salary = salary
   @payroll = payroll
  end

  def salary=(new_salary)
    @salary = new_salary
    @payroll.update(self)
  end
end
```
This code is hard-wired to inform the payroll only. There would be trouble if we needed other objects to be informed.

```employee.rb
class Employee
  attr_reader :name
  attr_accessor  :title, :salary

  def initialize(name, title, salary)
    @name = name
    @title = title
    @salary = salary
    @observers = []
  end

  def add_observer(observer)
    @observers << observer
  end

  def delete_observer(observer)
    @observers.delete(observer)
  end
end
```

```notify_observers.rb
def salary=(new_salary)
  @salary = new_salary
  notify_observers
end

def notify_observers
  @observers.each do |observer|
    observer.update(self)
  end
end

# pooske = Emploee.new('Pooske Fuku', 'engineer', 30000.0)

# payroll = Payroll.new
# pooske.add_observer(payroll)

# pooske.salary = 35000.0
```

Factoring out the observable support

```subject.rb
class Subject
  def initialize
    @observers = []
  end

  def add_observer(observer)
    @observers << observer
  end

  def delete_observer(observer)
    @observers.delete(observer)
  end

  def notify_observers
    @observers.each do |observer|
      observer.update(self)
    end
  end
end

class Employee < Subject
  attr_reader :name, :address
  attr_reader :salary

  def initialize( name, title, salary)
   super()
   @name = name
   @title = title
   @salary = salary
  end

  def salary=(new_salary)
    @salary = new_salary
    notify_observers
  end
end
```

However ruby only allows each class to have exactly one superclass. A module can be used to package the same methods and constants.

```module.rb
module Subject
  def initialize
    @observers=[]
  end

  def add_observer(observer)
    @observers << observer
  end

  def delete_observer(observer)
    @observers.delete(observer)
  end

  def notify_observers
    @observers.each do |observer|
      observer.update(self)
    end
  end
end

class Employee
  include Subject

  attr_reader :name, :address
  attr_reader :salary

  def initialize( name, title, salary)
   super()
   @name = name
   @title = title
   @salary = salary
  end

  def salary=(new_salary)
    @salary = new_salary
    notify_observers
  end
end
```

Note how `super()` is called even with the module, and that it has parentheses, to call the method in the superclass with exactly no arguments.

Ruby standard library also comes with Observable module.

```observable.rb
require 'observer'

class Employee
  include Observable

  attr_reader :name, :address
  attr_reader :salary

  def initialize( name, title, salary)
   @name = name
   @title = title
   @salary = salary
  end

  def salary=(new_salary)
    @salary = new_salary
    changed # boolean flag that says the object really has changed before notifying.
    notify_observers(self)
  end
end
```

The observer can also be a proc.

```proc.rb
module Subject
  def initialize
    @observers=[]
  end

  def add_observer(&observer)
    @observers << observer
  end

  def delete_observer(&observer)
    @observers.delete(observer)
  end

  def notify_observers
    @observers.each do |observer|
      observer.call(self)
    end
  end
end


class Employee
  include Subject

  attr_accessor :name, :title, :salary

  def initialize( name, title, salary )
    super()
    @name = name
    @title = title
    @salary = salary
  end

  def salary=(new_salary)
    @salary = new_salary
    notify_observers
  end
end

# fred = Employee.new('Fred', 'Crane Operator', 30000)
# fred.add_observer do |changed_employee|
#   puts "Cut a new check for #{changed_employee.name}!"
#   puts "His salary is now #{changed_employee.salary}!"
# end
# fred.salary = 40000
```

Similar to the Strategy pattern, both feature and object (called the observable in the Observer pattern and the context in the Strategy pattern) to make calls out to some other object. The diff is one of intent. In this case we are informing the other object to the events occurring back at the observable. Strategy gets the object to do some computing.
