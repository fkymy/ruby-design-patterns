### Commands

Solution through inheritance:
```problem.rb
class SlickButton
  # Lots of button drawing and management
  # code omitted...

  def on_button_push
    # Do something when the button is pushed.
  end
end

class SaveButton < SlickButton
  def on_button_push
    # Save the current document...
  end
end

class NewDocumentButton < SlickButton
  def on_button_push
    # Create a new document...
  end
end
```
But inheritance is so permanent and not flexible.
An easier way is to package little actions into commands, and bundle them up to perform application specific tasks.

```commands.rb
class SlickButton
  attr_accessor :command

  def initialize(command)
    @command = command
  end

  # Lots of button drawing and management
  # code omitted...

  def on_button_push
    @command.execute if @command
  end
end

class SaveCommand
  def execute
    # Save the current document...
  end
end

# save_button = SlickButton.new(SaveCommand.new)
```

It factors out the action code, and it is easy to change commands on the fly, at runtime.

A command, or a wrapper around some code that knows how to do one specific task, sounds like a code block object or a Proc.

```proc.rb
class SlickButton
  attr_accessor :command

  def initialize(&block)
    @command = block
  end

  def on_button_push
    @command.call if @command
  end
end

# new_button = SlickButton.new do
# # create new doc...
# end
```

If the task is straightforward, a Proc is a fair option. If its complex, create a command that will carry around a lot of state information or that naturally decomposes into several methods, create a command class.

Command pattern can be useful in keeping track of actions done.

```cmd.rb
class Command
  attr_reader :description

  def initialize(description)
    @description = description
  end

  def execute
  end
end

class CreateFile < Command
  def initialize(path, contents)
    super("Create file: #{path}")
    @path = path
    @contents = contents
  end

  def execute
    f = File.open(@path, "w")
    f.write(@contents)
    f.close
  end
end

class DeleteFile < Command
  def initialize(path)
    super("Delete file: #{path}")
    @path = path
  end

  def execute
    File.delete(@path)
  end
end

class CopyFile < Command
  def initialize(source, target)
    super("Copy file: #{source} to #{target}")
    @source = source
    @target = target
  end

  def execute
    FileUtils.copy(@source, @target)
  end
end

#
# A composite command.
#
class CompositeCommand < Command
  def initialize
    @commands = []
  end

  def add_command(cmd)
    @commands << cmd
  end

  def execute
    @commands.each {|cmd| cmd.execute}
  end

  def description
    description = ''
    @commands.each {|cmd| description += cmd.description + "\n"}
    description
  end
end

# commands = CompositeCommand.new
# commands.add_command(CreateFile.new("file1.txt", "hello world\n"))
# commands.add_command(CopyFile.new("file1.txt", "file2.txt"))
# commands.add_command(DeleteFile.new("file1.txt"))
# commands.execute
# puts commands.description
```

Undoing things:

```undo.rb
class Command
  attr_reader :description

  def initialize(description)
    @description = description
  end

  def execute
  end

  def unexecute
  end
end

class CreateFile < Command
  def initialize(path, contents)
    super "Create file: #{path}"
    @path = path
    @contents = contents
  end

  def execute
    f = File.open(@path, "w")
    f.write(@contents)
    f.close
  end

  def unexecute
    File.delete(@path)
  end
end

class DeleteFile < Command
  def initialize(path)
    super "Delete file: #{path}"
    @path = path
  end

  def execute
    if File.exists?(@path)
      @contents = File.read(@path)
    end
    f = File.delete(@path)
  end

  def unexecute
    if @contents
      f = File.open(@path,"w")
      f.write(@contents)
      f.close
    end
  end
end

class CopyFile < Command
  def initialize(source, target)
    super "Copy file: #{source} to #{target}"
    @source = source
    @target = target
  end

  def execute
    if File.exists?(@target)
      @contents = File.open(@target).read
    end
    FileUtils.copy(@source, @target)
  end

  def unexecute
    File.delete(@target)
    if @contents
      f = File.open(@target,"w")
      f.write(@contents)
      f.close
    end
  end
end

#
# A composite command.
#
class CompositeCommand < Command
  def initialize
    @commands = []
  end

  def add_command(cmd)
    @commands << cmd
  end

  def execute
    @commands.each { |cmd| cmd.execute }
  end

  # cool use of reverse!
  def unexecute
    @commands.reverse.each { |cmd| cmd.unexecute }
  end

  def description
    description = ''
    @commands.each { |cmd| description += cmd.description + "\n" }
    return description
  end
end
```

Commands can also be queued up, so you can execute all of your commands at once in a while, saving some resource.

Checkout ActiveRecord as a command. (Migrations up and down)

The key about the Command pattern is that it separates the thought from the deed. It is not 'do this' but a 'remember how to do this' and 'do that thing that i told you to remember'. A command object only knows how to do a specific task, but not interested in the state of the thing that executed it.
