# Судоку 4x4 (0 - порожня клітинка)
START = [
  [1, 0, 0, 4],
  [0, 4, 1, 0],
  [2, 0, 0, 3],
  [0, 3, 2, 0]
]

# Показати поле
def show(board)
  puts "\n   1 2   3 4"
  board.each_with_index do |row, i|
    puts "  -----------" if i == 2
    print "#{i + 1}  "
    row.each_with_index do |n, j|
      print "#{n == 0 ? '.' : n} "
      print "| " if j == 1
    end
    puts
  end
  puts
end

# Чи є число n у рядку, стовпці або блоці (саму клітинку r, c не враховуємо)
def valid_move?(board, r, c, n)
  4.times do |i|
    return false if i != c && board[r][i] == n
    return false if i != r && board[i][c] == n
  end
  br = r / 2 * 2
  bc = c / 2 * 2
  2.times do |i|
    2.times do |j|
      return false if (br + i != r || bc + j != c) && board[br + i][bc + j] == n
    end
  end
  true
end

# Перемога, якщо немає порожніх клітинок
def win?(board)
  board.flatten.none?(0)
end

def play
  board = START.map(&:dup)
  puts "Судоку 4x4. Введіть: рядок стовпець число (наприклад: 1 2 3)"
  puts "Число 0 стирає вашу клітинку. q - вийти."

  loop do
    show(board)
    print "Хід: "
    input = gets.to_s.strip
    break puts("Гру завершено.") if input.downcase == "q"

    parts = input.split
    unless parts.size == 3 && parts.all? { |p| p =~ /\A\d+\z/ }
      puts "Помилка: введіть три числа через пробіл."
      next
    end

    r, c, n = parts.map(&:to_i)
    unless (1..4).include?(r) && (1..4).include?(c) && (0..4).include?(n)
      puts "Помилка: рядок і стовпець від 1 до 4, число від 0 до 4."
      next
    end

    r -= 1
    c -= 1
    if START[r][c] != 0
      puts "Помилка: це початкове число, його змінювати не можна."
    elsif n != 0 && !valid_move?(board, r, c, n)
      puts "Помилка: число #{n} порушує правила (повтор у рядку, стовпці або блоці)."
    else
      board[r][c] = n
      if win?(board)
        show(board)
        puts "Перемога! Ви правильно заповнили все поле."
        break
      end
    end
  end
end

play
