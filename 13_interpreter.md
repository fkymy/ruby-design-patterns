### Interpreter

The Interpreter pattern is good at solving well-bounded problems such as query or configuration languages and is a good option for combining chunks of existing functionality together. The basic idea is to have a class for each symbol that may occur in expression. If we instantiate these classes and connect the objects together they will form a syntax tree of the language.

Disadvantages:
- Traversing AsT will inevitably exact some speed penalty of its own.
- Sometimes complexity.

Advantages:
- Flexibility. Once you build an interpreter it is easy to add new operations to it.
- AST itself. AST is a data structure that represents some specific bit of programming logic. Manipulate and control output.

e.g. File-Finding Interpreter

```find.rb
require 'find'

class Expression
  def |(other)
    Or.new(self, other)
  end

  def &(other)
    And.new(self, other)
  end
end


class FileName < Expression
 def initialize(pattern)
   @pattern = pattern
 end

 def evaluate(dir)
   results= []
   Find.find(dir) do |p|
     next unless File.file?(p)
     name = File.basename(p)
     results << p if File.fnmatch(@pattern, name)
   end
   results
 end
end

class All < Expression
 def evaluate(dir)
   results= []
   Find.find(dir) do |p|
     next unless File.file?(p)
     results << p
   end
   results
 end
end

class Not < Expression
 def initialize(expression)
   @expression = expression
 end

 def evaluate(dir)
   All.new.evaluate(dir) - @expression.evaluate(dir)
 end
end


class Bigger < Expression
 def initialize(size)
   @size = size
 end

 def evaluate(dir)
   results = []
   Find.find(dir) do |p|
     next unless File.file?(p)
     results << p if( File.size(p) > @size)
   end
   results
 end
end

class Writable < Expression
 def evaluate(dir)
   results = []
   Find.find(dir) do |p|
     next unless File.file?(p)
     results << p if( File.writable?(p) )
   end
   results
 end
end

class Or < Expression
 def initialize(expression1, expression2)
   @expression1 = expression1
   @expression2 = expression2
 end

 def evaluate(dir)
   result1 = @expression1.evaluate(dir)
   result2 = @expression2.evaluate(dir)
   (result1 + result2).sort.uniq
 end
end

class And < Expression
 def initialize(expression1, expression2)
   @expression1 = expression1
   @expression2 = expression2
 end

 def evaluate(dir)
   result1 = @expression1.evaluate(dir)
   result2 = @expression2.evaluate(dir)
   (result1 & result2)
 end
end
```

wip

Some things are performance sensitive.
Some things are better to be clear to coders.
Division of performance sensitive things and performance insensitive things is important.
