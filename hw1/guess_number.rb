# encoding: UTF-8

def play_game
  number = rand(1..100)
  attempts = 0

  puts "Я загадав число від 1 до 100."

  loop do
    print "Введіть число: "
    input = gets
    break if input.nil?

    input = input.strip
    unless input.match?(/\A[0-9]+\z/) && input.to_i.between?(1, 100)
      puts "Введіть ціле число від 1 до 100!"
      next
    end

    guess = input.to_i
    attempts += 1

    if guess < number
      puts "Більше!"
    elsif guess > number
      puts "Менше!"
    else
      puts "Вгадано!"
      puts "Кількість спроб: #{attempts}"
      break
    end
  end
end

play_game if __FILE__ == $PROGRAM_NAME
