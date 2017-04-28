### Singleton

Some things are unique.
If you only ever have one instance of a class and a lot of code that needs access to that instance:
build a Singleton, a class that can have only one instance and that provides global access to that one instance.

e.g. logging class for keeping track of the comings and goings of your program.
```multiton.rb
class SimpleLogger
  attr_accessor :level

  ERROR = 1
  WARNING = 2
  INFO = 3

  def initialize
    @log = File.open("log.txt", "w")
    @level = WARNING
  end

  def error(msg)
    @log.puts(msg)
    @log.flush
  end

  def warning(msg)
    @log.puts(msg) if @level >= WARNING
    @log.flush
  end

  def info(msg)
    @log.puts(msg) if @level >= info
    @log.flush
  end
end

# logger = SimpleLogger.new
# logger.level = SimpleLogger::INFO
#
# logger.info('Doing the first thing')
# logger.info('Doing the second thing')
#
```

The whole point of Singleton pattern is to avoid passing an object like the logger all over the place.
Instead, make the SimpleLogger class responsible for managing its single instance.

```singleton.rb
class SimpleLogger
  # code omitted

  @@instance = SimpleLogger.new

  def self.instance
    return @@instance
  end
end

# logger1 = SimpleLogger.instance
# logger2 = SimpleLogger.instance # returns the same logger

# SimpleLogger.instance.info('Computer wins chess game.')
# SimpleLogger.instance.warning('hardware failure')
# SimpleLogger.instance.error(
    'malfunction, take emergency action'
  )
```

To make sure that the one and only singleton is the sole instance of the singleton class, here is one way:

```private.rb
class SimpleLogger
  # code omitted...

  @@instance = SimpleLogger.new

  def self.instance
    return @@instance
  end

  private_class_method :new
end
```
This makes the new method private, preventing any other class from creating new instances of the logger.
In a broader sense new is just another class-level method (which does more behind the scenes).

#### Singleton Module
The solution above seems repetitive, if you want to make more.

```module.rb
require 'singleton'

class SimpleLogger
  include Singleton

  # code omitted...
end
```
The Singleton module creates the class variable and initializes it with the singleton instance, then creates the class-level instance method and makes new private.
Calling `SimpleLogger.instance` would already work.

The big difference is, the first example has `@@instance = SimpleLogger.new`, creating instance before anything is called.
Creating the singleton instance before you actually need it is called eager instantiation.
Singleton module is an example of lazy instantiation.

#### Alternatives
Global variables like `$logger`

Why not to:
- Can be reassigned anytime
- Not lazy

Constants

Why not to:
- Can be reassigned, with a warning returned
- Not lazy
- Cannot prevent more than one instance being created

Classes as Singletons

```class.rb
class ClassBasedLogger
  ERROR = 1
  WARNING = 2
  INFO = 3

  @@log = File.opne('log.txt', 'w')
  @@level = WARNING

  def self.error(msg)
    @@log.puts(msg)
    @@log.flush
  end

  def self.warning(msg)
    @@log.puts(msg) if @@level >= WARNING
    @@log.flush
  end

  def self.info(msg)
    @@log.puts(msg) if @@level >= INFO
    @@log.flush
  end

  def self.level=(new_level)
    @@lvel = new_level
  end

  def self.level
    @@level
  end
end

# ClassBasedLogger.level = ClassBasedLogger::INFO
#
# ClassBasedLogger.info('aaa')
# ClassBasedLogger.warning('bbb')
# ClassBasedLogger.error('error error')
```
Class can be a container for the singleton functionality, but you don't have control over the timing of initialization. Also, a lot of bolierplate code.

#### Module as Singletons

Similar to above.
It it not any better than class, because you cannot instantiate a module (the difference between a module and a class...).

#### Concerns

Singletons are not global variables. They are meant to model things that occur exactly once.

Some more examples:
Application with database connection that occur only once, so having the connection management a singleton.

```eg.rb
require 'singleton'

class DatabaseConnectionManager
  include Singleton

  def get_connection
    # Return the database connection...
  end
end
```
The question here: Which classes are actually aware that DatabaseConnectionManager is a singleton?
We could spread this information among others, like the preference readers and writers.

```preference.rb
class PreferenceManager
  def initialize
    @reader = PrefReader.new
    @writer = PrefWriter.new
    @preferences = { :display_splash => false, :background_color => :blue }
  end

  def save_preference
    preferences = {}
    @writer.write(@preferences)
  end

  def get_preferences
    @preferences = @reader.read
  end
end

class PrefWriter
  def write(preferences)
    connection = DatabaseConnectionManager.instance.get_connection
    # Write the preferences out
  end
end

class PrefReader
  def reader
    connection = DatabaseConnectionManager.instance.get_connection
    # Read the preferences and return them...
  end
end
```

A better approach is, concentrate the knowledge that DatabaseConnectionManager is a singleton in the PreferenceManager class.

```preference.rb
class PreferenceManager
  def initialize
    @reader = PrefReader.new
    @writer = PrefWriter.new
    @preferences = { :display_splash => false, :background_color => :blue }
  end

  def save_preference
    preferences = {}
    @writer.writer(DatabaseConnectionManager.instance, @preferences)
  end

  def get_preferences
    @preferences = @reader.read(DatabaseConnectionManager.instance)
  end
end
```
Why:
- less code to fix when singleton is no longer alone
- PrefWriter and PrefReader is much more testable
