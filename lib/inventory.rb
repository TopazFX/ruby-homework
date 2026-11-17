require 'json'

module Inventory
  class Error < StandardError; end
  class ReadError < Error; end
  class DataError < Error; end

  def self.load(path)
    begin
      text = File.read(path)
    rescue Errno::ENOENT
      raise ReadError, "Файл не знайдено: #{path}"
    end

    begin
      data = JSON.parse(text)
    rescue JSON::ParserError
      raise DataError, 'Файл містить некоректний JSON'
    end

    unless data.is_a?(Array)
      raise DataError, 'Корінь має бути масивом'
    end

    data.each_with_index do |item, i|
      num = i + 1

      unless item.is_a?(Hash)
        raise DataError, "Запис #{num}: має бути об'єкт"
      end

      unless item['name'].is_a?(String) && !item['name'].strip.empty?
        raise DataError, "Запис #{num}: name має бути непорожнім рядком"
      end

      ['price_in_kopecks', 'quantity'].each do |key|
        value = item[key]
        unless value.is_a?(Integer) && value >= 0
          raise DataError, "Запис #{num}: #{key} має бути невід'ємним цілим числом"
        end
      end
    end

    data
  end

  def self.total(products)
    sum = 0
    products.each do |product|
      sum += product['price_in_kopecks'] * product['quantity']
    end
    sum
  end
end
