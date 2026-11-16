# frozen_string_literal: true

module ExpenseTracker
  # Базовий клас усіх помилок програми
  class Error < StandardError; end

  # Некоректні дані запису або введення користувача
  class ValidationError < Error; end

  # Проблема з файлом даних під час запуску (файл не змінюється)
  class DataFileError < Error; end

  # Не вдалося записати зміни у файл
  class SaveError < Error; end

  # Проблема з файлом імпорту
  class ImportError < Error; end

  # Витрату з таким id не знайдено
  class NotFoundError < Error; end

  # Потік вводу закрито (Ctrl+D / Ctrl+Z). Навмисно не успадковує Error
  class InputClosed < StandardError; end
end
