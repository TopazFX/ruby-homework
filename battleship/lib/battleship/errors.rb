# frozen_string_literal: true

module Battleship
  # Базовий клас усіх власних помилок гри
  class GameError < StandardError; end

  # Некоректні координати (наприклад "Z99" або порожній рядок)
  class InvalidCoordinateError < GameError
    def initialize(input = nil)
      super("Некоректні координати#{input.nil? ? '' : " «#{input}»"}. Приклад: A1, e5, J10.")
    end
  end

  # Повторний постріл в уже обстріляну клітинку
  class AlreadyShotError < GameError
    def initialize(label = nil)
      super("У клітинку #{label} ви вже стріляли. Оберіть іншу.")
    end
  end

  # Не вдалося розмістити корабель
  class PlacementError < GameError; end
end
