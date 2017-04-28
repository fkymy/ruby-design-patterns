### Composite

"The sum acts like one of the parts"

You are trying to build a hierarchy or tree of objects, and you do not want the code that uses the tree to constantly have to worry about whether it is dealing with a single object or a whole branch.

The base class or the interface is the component. Ask yourself, what will my basic and higher-level objects all have in common?

The simple, individual building blocks of the process are called the leaf classes.

The composite is a component, but also a higher level object that is built from subcomponents.

e.g. Baking cake task

```task.rb
class Task
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def get_time_required
    0.0
  end
end

# Leaf classes
class AddDryIngredientsTask < Task

  def initialize
    super('Add dry ingredients')
  end

  def get_time_required
    1.0
  end
end

class MixTask < Task

  def initialize
    super('Mix that batter up!')
  end

  def get_time_required
    3.0
  end
end

```

Task is an abstract base class in the sense that is it not really complete.

Here is a composite class:

```make_batter.rb
class MakeBatterTask < Task
  def initialize
    super('Make batter')
    @sub_tasks = []
    add_sub_task( AddDryIngredientsTask.new )
    add_sub_task( MixTask.new )
  end

   def add_sub_task(task)
    @sub_tasks << task
  end

  def remove_sub_task(task)
    @sub_tasks.delete(task)
  end

  def get_time_required
    time=0.0
    @sub_tasks.each {|task| time += task.get_time_required}
    time
  end
end
```

While they are built up internally of any number of subtasks, from the outside they look just like any other Task.

It also make sense to factor out the details into another base:
```composite_task.rb
class CompositeTask < Task
  def initialize(name)
    super(name)
    @sub_tasks = []
  end

  def add_sub_task(task)
    @sub_tasks << task
  end

  def remove_sub_task(task)
    @sub_tasks.delete(task)
  end

  def get_time_required
    time=0.0
    @sub_tasks.each {|task| time += task.get_time_required}
    time
  end
end

class MakeBatterTask < CompositeTask
  def initialize
    super('Make batter')
    add_sub_task( AddDryIngredientsTask.new )
    add_sub_task( AddLiquidsTask.new )
    add_sub_task( MixTask.new )
  end
end

class MakeCakeTask < CompositeTask
  def initialize
    super('Make cake')
    add_sub_task( MakeBatterTask.new )
    add_sub_task( FillPanTask.new )
    add_sub_task( BakeTask.new )
    add_sub_task( FrostTask.new )
    add_sub_task( LickSpoonTask.new )
  end
end
```

The CompositeTask looks like the standard Ruby collections (Array, Hash). It is also cool to add similar operators:
```
def <<(task)
  @sub_tasks << task
end

def [](index)
  @sub_tasks[index]
end

def []=(index, new_value)
  @sub_tasks[index] = new_value
end

# composite = CompositeTask.new('example')
# composite << MixTask.new

# puts composite[0].get_time_required

# composite[1] = AddDryIngredientsTask.new
```

It could also inherit Array class to begin with, but its more of a task than an array, so you might regret it later.
```array.rb
class CompositeTask < Array
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def get_time_required
    time=0.0
    each {|task| time += task.get_time_required}
    time
  end
end

class MakeBatterTask < CompositeTask
  def initialize
    super('Make batter')
    self << AddDryIngredientsTask.new
    self << AddLiquidsTask.new
    self << MixTask.new
  end
end
```

#### Concern

Making overrides of method between composites.
Assuming wrong number of depth level in the tree.
