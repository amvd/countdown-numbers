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

  def get_target(history, list)
    ### Find solution equation for given list and history
    ### of past pieces of the solution
    list.sort!
    return if solution_found_for_set?(list)

    if list.length < 2 || @stop_after_solution && @min_delta.zero?
      record_steps(history)
      return
    end
    process_first_numbers(history, list)
  end

  def process_first_numbers(history, list)
    ### Loop through list one time to get first number
    list.each do |num|
      new_list = remove_from_list(list, num)
      process_second_numbers(history, new_list, num, list)
    end
  end

  def process_second_numbers(history, list, first_num, original_list)
    ### Loop through list second time to get second number
    list.each do |num|
      new_list = remove_from_list(list, num)
      apply_operators(history, first_num, num, new_list, original_list)
    end
  end

  def apply_operators(history, num1, num2, list, original_list)
    ### Loop through operators and apply to first and second number
    OPERATORS.each do |_, op|
      result = call_operator_on(op, num1, num2)
      new_history = append_history(
        history,
        generate_record(op[:sym], num1, num2, result, original_list)
      )

      break if end_of_calcs?(new_history, result)

      get_target(new_history, list + [result])
    end
  end

  def call_operator_on(operation, num1, num2)
    ### Call operator on two numbers
    # puts "#{num1} #{operation[:sym]} #{num2}"
    return 0 if operation[:sym] == '/' && num1 % num2 != 0
    operation[:function].call(num1, num2)
  end

  def end_of_calcs?(history, result)
    ### Check if dead-end or solution is reached
    return false unless result.zero? || check_solution(history, result)
    record_steps(history)
    true
  end

  def record_steps(history)
    ### Memoize final solution for each step along the way
    ### for later lookup, to prevent following paths for which
    ### a solution has already been found.
    result = history.last[:result]
    history.each do |record|
      next if @step_map[record[:origin_list]]
      @step_map[record[:origin_list]] = result
    end
  end

  def generate_formula(history, result)
    ### Generate a formula string for the solution equation.
    result_map = {}
    history.each do |h|
      num1 = result_map[h[:num1]] || h[:num1]
      num2 = result_map[h[:num2]] || h[:num2]
      result_map[h[:result]] = "(#{num1} #{h[:operator]} #{num2})"
    end

    result_map[result]
  end

  def append_history(prev_history, history_hash)
    ### Return new history array with new record appended
    prev_history + [history_hash]
  end

  def remove_from_list(list, num)
    ### Return new list with number spliced out
    list - [num]
  end

  def solution_found_for_set?(list)
    ### Check if a solution or dead-end has already been found
    ### for this set of numbers
    @step_map[list]
  end

  def check_solution(history, result)
    ### Check if solution has been found
    current_delta = (result - @target).abs
    if @min_delta.positive? && current_delta < @min_delta
      ### If solution has not been found and this solution is
      ### closer than previous solutions, set as the first solution
      @min_delta = current_delta
      @solutions = [generate_formula(history, result)]
    elsif result == @target
      ### Else if an exact solution has been found and this is
      ### an additional solution, append to solution array
      @solutions << generate_formula(history, result)
    end
    ### Return true if exact solution was found
    current_delta.zero?
  end

  def generate_record(operator, num1, num2, result, list)
    ### Generate record hash for history array
    {
      operator: operator,
      num1: num1,
      num2: num2,
      result: result,
      origin_list: list
    }
  end
end

generator = EquationGenerator.new([25, 75, 50, 1, 9, 3], 386)

generator.generate_all_solutions
# generator.generate_single_solution
