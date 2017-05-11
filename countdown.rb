require 'benchmark'

OPERATORS = {
  ADD: {
    sym: '+',
    function: ->(a, b) { a + b }
  },
  SUBTRACT: {
    sym: '-',
    function: ->(a, b) { a - b }
  },
  MULTIPLY: {
    sym: '*',
    function: ->(a, b) { a * b }
  },
  DIVIDE: {
    sym: '/',
    function: ->(a, b) { a / b }
  }
}.freeze

# $stdout = File.new('console3.out', 'w')

# $stdout.sync = true

class EquationGenerator
  def initialize(list, target)
    @list = list
    @target = target
    @min_delta = Float::INFINITY
    @solutions = []
  end

  def generate_single_solution
    get_target(@list, [], true)
    puts @solutions
  end

  def generate_all_solutions
    get_target(@list, [], false)
    # puts @solutions
  end

  private

  def generate_formula(history, result)
    result_map = {}
    history.each do |h|
      num1 = result_map[h[:num1]] || h[:num1]
      num2 = result_map[h[:num2]] || h[:num2]
      result_map[h[:result]] = "(#{num1} #{h[:operator]} #{num2})"
    end

    result_map[result]
  end

  def append_history(prev_history, operation, num1, num2, result)
    prev_history + [{
      operator: operation[:sym],
      num1: num1,
      num2: num2,
      result: result
    }]
  end

  def remove_from_list(list, num)
    list - [num]
  end

  def call_operator_on(operation, num1, num2)
    return 0 if operation[:sym] == '/' && num1 % num2 != 0
    # puts "#{num1} #{operation[:sym]} #{num2}"
    operation[:function].call(num1, num2)
  end

  def check_solution(history, result)
    # puts "result: #{result}"
    current_delta = (result - @target).abs
    if @min_delta > 0 && current_delta < @min_delta
      @min_delta = current_delta
      @solutions = [generate_formula(history, result)]
    elsif result == @target
      @solutions << generate_formula(history, result)
    end
    true if current_delta.zero?
  end

  def get_target(list, history, stop_after_solution = true)
    # puts "Operating on list: #{list}"
    return if list.length < 2 || stop_after_solution && @min_delta.zero?
    list.each do |num1|
      new_list = remove_from_list(list, num1)
      new_list.each do |num2|
        new_list2 = remove_from_list(new_list, num2)
        OPERATORS.each do |_, op|
          result = call_operator_on(op, num1, num2)
          # Prevent end of the world
          break if result.zero?

          new_history = append_history(history, op, num1, num2, result)
          break if check_solution(new_history, result)
          get_target(new_list2 + [result], new_history, stop_after_solution)
        end
      end
    end
  end
end

LIST = [25, 75, 50, 1, 9, 3]

# LIST = [50, 2, 7]

generator = EquationGenerator.new(LIST, 386)

generator.generate_single_solution
# puts Benchmark.measure { generator.generate_all_solutions }

# Benchmark.bm do |x|
#   x.report { generator.generate_single_solution }
#   x.report { generator.generate_single_solution }
#   x.report { generator.generate_single_solution }
# end

# Benchmark.bmbm do |x|
#   x.report { generator.generate_all_solutions }
#   x.report { generator.generate_all_solutions }
#   x.report { generator.generate_all_solutions }
# end
