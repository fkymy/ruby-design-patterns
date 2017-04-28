### Strategy

#### Problem:
How do you vary part of an algorithm?
The previous answer was the Template Method: create a base class with a template method that controls the overall processing and then to use subclasses to fill in the details.
But there are drawbacks from the fact that it's built around inheritance. Subclasses are destined to tangle up with their superclass. There is also limit to runtime flexibility (after creating a whole new report object).

#### Solution:
Instead of creating a subclass for each variation, isolate the varying algorithm in its own class.
Delegate tasks to a family of encapsulated algorithms which are interchangeable at runtime.

```formatter.rb
class Formatter
  def output_report(title, text)
    raise 'Abstract method called'
  end
end

class HTMLFormatter < Formatter
  def output_report( title, text )
    puts('<html>')
    puts('  <head>')
    puts("    <title>#{title}</title>")
    puts('  </head>')
    puts('  <body>')
    text.each do |line|
      puts("    <p>#{line}</p>" )
    end
    puts('  </body>')
    puts('</html>')
  end
end

class PlainTextFormatter < Formatter
  def output_report(title, text)
    puts("***** #{title} *****")
    text.each do |line|
      puts(line)
    end
  end
end

class Report
  attr_reader :title, :text
  attr_accessor :formatter

  def initialize(formatter)
    @title = 'Monthly Report'
    @text =  ['Things are going', 'really, really well.']
    @formatter = formatter
  end

  def output_report
    @formatter.output_report( @title, @text)
  end
end

# report = Report.new(HTMLFormatter.new)
# report.output_report
#
# # switch strategies at runtime
# report.formatter = PlainTextFormatter.new
# report.output_report
```

GOF calls this "pull the algorithm out into a separate object" technique the Strategy pattern.
Define a family of objects, the strategies, which all do the same job with the same interface - in this case, format report.
Report class, the user of the strategy (called the context class) can treat the strategies like interchangeable parts, because they all look alike and all perform the same function. It is relieved of any responsibility for the report file format.

##### Sharing data between the Context and the Strategy
Context object passes a reference to itself to the strategy object, and strategy object can call methods on the context to get at the data it needs.

```sharing_data.rb
class Report
  attr_reader :title, :text

  attr_accessor :formatter

  def initialize(formatter)
    @title = 'Monthly Report'
    @text =  ['Things are going', 'really, really well.']
    @formatter = formatter
  end

  def output_report
    @formatter.output_report(self)
  end
end


class Formatter
  def output_report(context)
    raise 'Abstract method called'
  end
end

class HTMLFormatter < Formatter
  def output_report(context)
    puts('<html>')
    puts('  <head>')
    puts("    <title>#{context.title}</title>")
    puts('  </head>')
    puts('  <body>')
    context.text.each do |line|
      puts("    <p>#{line}</p>")
    end
    puts('  </body>')
    puts('</html>')
  end
end

class PlainTextFormatter < Formatter
  def output_report(context)
    puts("***** #{context.title} *****")
    context.text.each do |line|
      puts(line)
    end
  end
end
```

* There is also no need for Formatter class, if you follow Ruby's duck typing philosophy. (It only existed to define a common interface for all the formatter subclasses, but the subclasses already share a common interface as they both implement `output_report` method. )

##### Using Procs
What strategy does is similar to the description of Proc (a chunk of code wrapped in an object).

```proc.rb
class Report
  attr_reader :title, :text
  attr_accessor :formatter

  def initialize(&formatter)
    @title = 'Monthly Report'
    @text =  [ 'Things are going', 'really, really well.' ]
    @formatter = formatter
  end

  def output_report
    @formatter.call( self )
  end
end


HTML_FORMATTER = lambda do |context|
  puts('<html>')
  puts('  <head>')
  puts("    <title>#{context.title}</title>")
  puts('  </head>')
  puts('  <body>')
  context.text.each do |line|
    puts("    <p>#{line}</p>" )
  end
  puts('  </body>')
  puts('</html>')
end


PLAIN_FORMATTER = lambda do |context|
  puts("***** #{context.title} *****")
  context.text.each do |line|
    puts(line)
  end
end

# report = Report.new &HTML_FORMATTER
# report.output_report
#
# #or even on the fly:
# report = Report.new do |context|
#   puts("***** #{context.title} *****")
#   context.text.each do |line|
#   puts(line)
# end
```
