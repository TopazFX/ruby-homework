# encoding: UTF-8

def play_game
  choices = ["Камінь", "Ножиці", "Папір"]
  user_wins = 0
  computer_wins = 0
  draws = 0
  rounds = 0

  loop do
    puts "\nОберіть:"
    puts "1 - Камінь"
    puts "2 - Ножиці"
    puts "3 - Папір"
    puts "0 - Вихід"
    print "> "

    input = gets
    break if input.nil?

    input = input.strip
    break if input == "0"

    unless ["1", "2", "3"].include?(input)
      puts "Неправильний вибір! Введіть 1, 2, 3 або 0."
      next
    end

    user = input.to_i - 1
    computer = rand(0..2)

    puts "Ваш вибір: #{choices[user]}"
    puts "Вибір комп'ютера: #{choices[computer]}"
    rounds += 1

    if user == computer
      puts "Нічия!"
      draws += 1
    elsif (user == 0 && computer == 1) ||
          (user == 1 && computer == 2) ||
          (user == 2 && computer == 0)
      puts "Ви перемогли!"
      user_wins += 1
    else
      puts "Комп'ютер переміг!"
      computer_wins += 1
    end

    puts "\nСтатистика:"
    puts "Ваші перемоги: #{user_wins}"
    puts "Перемоги комп'ютера: #{computer_wins}"
    puts "Нічиї: #{draws}"
    puts "Всього раундів: #{rounds}"
  end
end

play_game if __FILE__ == $PROGRAM_NAME
