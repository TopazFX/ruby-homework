# encoding: UTF-8

def word_stats(text)
  words = text.split

  {
    count: words.length,
    longest: words.max_by { |word| word.length },
    unique_count: words.map { |word| word.downcase }.uniq.length
  }
end

if __FILE__ == $PROGRAM_NAME
  puts "Введіть текст:"
  text = gets

  if text
    stats = word_stats(text)
    puts "Кількість слів: #{stats[:count]}"
    puts "Найдовше слово: #{stats[:longest] || 'немає'}"
    puts "Унікальних слів: #{stats[:unique_count]}"
  end
end
