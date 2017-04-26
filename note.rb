
# procs

hello = lambda do
  puts 'hello'
  puts 'inside a proc'
end

hello.call

proc = Proc.new do
  name = 'Mery'
end

hello = lambda {
  puts 'hello from inside a proc'
}

hello = lambda { puts 'something' }

multiply = lambda { |x, y| x * y }

n = multiply.call(20, 10)

def run_it
  puts 'before yield'
  yield
  puts 'after yield'
end

run_it do
  puts 'hello'
end

def run_it_with_params
  puts 'before yield'
  yield(24)
  puts 'after yield'
end

run_it_with_params do |x|
  puts "The value of x is #{x}"
end

def run_it_with_param(&block)
  block.call(24)
end

my_proc = lambda {|x| puts x}
run_it_with_param(&my_proc)


