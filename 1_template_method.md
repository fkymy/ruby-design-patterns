### Template Method

#### Problem:
A complex code with one goal, that needs its bits to vary from time to time.

e.g. A generator that requires different formats for different use cases.

imagine a class that outputs monthly reports in neat HTML

```situation.rb
class Report
  def initialize
    @title = 'Monthly Report'
    @text =  ['Things are going', 'really, really well.']
  end

  def output_report
    puts('<html>')
    puts('  <head>')
    puts("    <title>#{@title}</title>")
    puts('  </head>')
    puts('  <body>')
    @text.each do |line|
      puts("    <p>#{line}</p>" )
    end
    puts('  </body>')
    puts('</html>')
  end
end

# report = Report.new
# report.output_report
```

then you are required to add another format for output

```situation2.rb
class Report
  def initialize
    @title = 'Monthly Report'
    @text =  ['Things are going', 'really, really well.']
  end

  def output_report(format)
    if format == :plain
      puts("*** #{@title} ***")
    elsif format == :html
      puts('<html>')
      puts('  <head>')
      puts("    <title>#{@title}</title>")
      puts('  </head>')
      puts('  <body>')
    else
      raise "Unknown format: #{format}"
    end

    @text.each do |line|
      if format == :plain
        puts(line)
      else
        puts("    <p>#{line}</p>" )
      end
    end

    if format == :html
      puts('  </body>')
      puts('</html>')
    end
  end
end
```

Not only is this messy, but this mixes up code that is changing with code that is not changing.


#### Solution:
Separate the stuff that stays the same (the basic algorithm expressed in the template method) from the stuff that changes (the details supplied by the subclasses)
Define an abstract base class with a master method that performs the basic steps, but leave the details of each step to a subclass.
Keep what doesn't change (the abstract steps) as a skeleton, and override specific bits that changes with a subclass.

e.g.

The basic flow of Report remains the same. (The thing that doesn't change)
1. Output header information required by the format.
2. Output title.
3. Output each line of body.
4. Output any trailing stuff required by the format.

```template.rb
# Abstract class:

class Report
  def initialize
    @title = 'Monthly Report'
    @text =  ['Things are going', 'really, really well.']
  end

  # Template Method! (Skeletal Method)
  def output_report
    output_start
    output_head
    output_body_start
    output_body
    output_body_end
    output_end
  end

  def output_body
    @text.each do |line|
      output_line(line)
    end
  end

  def output_start
    raise 'Called abstract method: output_start'
  end

  def output_head
    raise 'Called abstract method: output_head'
  end

  def output_body_start
    raise 'Called abstract method: output_body_start'
  end

  def output_line(line)
    raise 'Called abstract method: output_line'
  end

  def output_body_end
    raise 'Called abstract method: output_body_end'
  end

  def output_end
    raise 'Called abstract method: output_end'
  end
end


# Subclasses:

class HTMLReport < Report
  def output_start
    puts('<html>')
  end

  def output_head
    puts('  <head>')
    puts("    <title>#{@title}</title>")
    puts('  </head>')
  end

  def output_body_start
    puts('<body>')
  end

  def output_line(line)
    puts("  <p>#{line}</p>")
  end

  def output_body_end
    puts('</body>')
  end

  def output_end
    puts('</html>')
  end
end

class PlainTextReport < Report
  def output_start
  end

  def output_head
    puts("**** #{@title} ****")
    puts
  end

  def output_body_start
  end

  def output_line(line)
    puts line
  end

  def output_body_end
  end

  def output_end
  end
end

# report = HTMLReport.new
# report.output_report

# report = PlainTextReport.new
# report.output_report
```

Again, the general idea of the Template Method pattern is to build an abstract base class with a skeletal method, which makes calls to abstract methods, which are then supplied by the concrete subclasses.
The abstract base class controls the higher-level processing through the template method; the subclasses simply fill in the details.

Hook methods can also be added to the skeleton class, permitting the concrete classes (1) to override the base implementation and do something different or (2) to simply accept the default implementation.

e.g.

```hook.rb
class Report
  def initialize
    @title = 'Monthly Report'
    @text =  ['Things are going', 'really, really well.']
  end

  def output_report
    output_start
    output_head
    output_body_start
    @text.each do |line|
      output_line(line)
    end
    output_body_end
    output_end
  end

  def output_start
  end

  def output_head
    output_line(@title)
  end

  def output_body_start
  end

  def output_line(line)
    raise 'Called abstract method: output_line'
  end

  def output_body_end
  end

  def output_end
  end
```

The hook method `output_start` tells the subclasses that it is ready to start outputting the report, if needed, add any details now.
