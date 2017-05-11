OPERATORS = {
  ADD: {
    sym: '+',
    function: lambda { |a, b| a + b }
  },
  SUBTRACT: {
    sym: '-',
    function: lambda { |a, b| a - b }
  },
  MULTIPLY: {
    sym: '*',
    function: lambda { |a, b| a * b }
  },
  DIVIDE: {
    sym: '/',
    function: lambda { |a, b| a / b }
  }
}.freeze

$stdout = File.new('console.out', 'w')

$stdout.sync = true

def print_answer(history, result)
  result_map = {}
  history.each do |h|
    num1 = result_map[h[:num1]] || h[:num1]
    num2 = result_map[h[:num2]] || h[:num2]
    result_map[h[:result]] = "(#{num1} #{h[:operator]} #{num2})"
  end
  puts "SOLUTION: #{result_map[result]}"
end

def get_target(list, target, history)
  return if list.length < 2
  list.each do |num1|
    new_list = list - [num1]
    new_list.each do |num2|
      new_list2 = new_list - [num2]
      OPERATORS.each do |op_name, op|
        result = op[:function].call(num1, num2)

        # Prevent end of the world
        break if result.zero? || (op_name == :DIVIDE && num1 % num2 != 0)

        new_history = history + [{
          operator: op[:sym],
          num1: num1,
          num2: num2,
          result: result
        }]
        if result === target
          puts "GOT IT: #{result}"
          print_answer(new_history, result)
          break
        end
        get_target(new_list2 + [result], target, new_history)
      end
    end
  end
end


LIST = [25, 75, 50, 1, 9, 3]

# LIST = [50, 2, 7]

get_target(LIST, 386, [])
