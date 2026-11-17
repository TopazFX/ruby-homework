require_relative '../lib/inventory'

path = ARGV[0] || File.join(__dir__, '..', 'data', 'badax.json')

begin
  products = Inventory.load(path)
rescue Inventory::ReadError => e
  warn "Помилка читання: #{e.message}"
  exit 3
rescue Inventory::DataError => e
  warn "Помилка даних: #{e.message}"
  exit 2
end

total = Inventory.total(products)
puts format('%d.%02d грн', total / 100, total % 100)
