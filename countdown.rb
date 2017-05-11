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

class EquationGenerator
  def initialize(list, target)
    @list = list
    @target = target
    @min_delta = Float::INFINITY
    @solutions = []
    @step_map = {}
  end

  def generate_single_solution
    @stop_after_solution = true
    get_target([], @list)
    puts @solutions.first
  end

  def generate_all_solutions
    @stop_after_solution = false
    get_target([], @list)
    puts @solutions
  end

  private

  def record_steps(history)
    result = history.last[:result]
    history.each do |record|
      next if @step_map[record[:origin_list]]
      @step_map[record[:origin_list]] = result
    end
  end

  def generate_formula(history, result)
    result_map = {}
    history.each do |h|
      num1 = result_map[h[:num1]] || h[:num1]
      num2 = result_map[h[:num2]] || h[:num2]
      result_map[h[:result]] = "(#{num1} #{h[:operator]} #{num2})"
    end

    result_map[result]
  end

  def append_history(prev_history, history_hash)
    prev_history + [history_hash]
  end

  def remove_from_list(list, num)
    list - [num]
  end

  def call_operator_on(operation, num1, num2)
    # puts "#{num1} #{operation[:sym]} #{num2}"
    return 0 if operation[:sym] == '/' && num1 % num2 != 0
    operation[:function].call(num1, num2)
  end

  def solution_found_for_combo?(list)
    @step_map[list]
  end

  def check_solution(history, result)
    current_delta = (result - @target).abs
    if @min_delta.positive? && current_delta < @min_delta
      @min_delta = current_delta
      @solutions = [generate_formula(history, result)]
    elsif result == @target
      @solutions << generate_formula(history, result)
    end
    true if current_delta.zero?
  end

  def get_target(history, list)
    list.sort!
    return if solution_found_for_combo?(list)

    if list.length < 2 || @stop_after_solution && @min_delta.zero?
      record_steps(history)
      return
    end
    process_first_numbers(history, list)
  end

  def process_first_numbers(history, list)
    list.each do |num|
      new_list = remove_from_list(list, num)
      process_second_numbers(history, new_list, num, list)
    end
  end

  def process_second_numbers(history, list, first_num, original_list)
    list.each do |num|
      new_list = remove_from_list(list, num)
      apply_operators(history, first_num, num, new_list, original_list)
    end
  end

  def generate_history_hash(operator, num1, num2, result, list)
    {
      operator: operator,
      num1: num1,
      num2: num2,
      result: result,
      origin_list: list
    }
  end

  def end_of_calcs?(history, result)
    return false unless result.zero? || check_solution(history, result)
    record_steps(history)
    true
  end

  def apply_operators(history, num1, num2, list, original_list)
    OPERATORS.each do |_, op|
      result = call_operator_on(op, num1, num2)
      new_history = append_history(
        history,
        generate_history_hash(op[:sym], num1, num2, result, original_list)
      )

      break if end_of_calcs?(new_history, result)

      get_target(new_history, list + [result])
    end
  end
end

generator = EquationGenerator.new([25, 75, 50, 1, 9, 3], 386)

generator.generate_all_solutions
# generator.generate_single_solution
