# frozen_string_literal: true

require 'date'
require_relative 'errors'

module ExpenseTracker
  # Одна витрата. Об'єкт створюється лише з коректних даних і незмінний.
  class Expense
    CATEGORIES = %w[food transport study entertainment other].freeze
    MAX_DESCRIPTION_LENGTH = 200
    DATE_PATTERN = /\A\d{4}-\d{2}-\d{2}\z/
    DIGITS_PATTERN = /\A\d+\z/
    BASE_KEYS = %w[date amount_in_kopecks category description].freeze

    attr_reader :id, :date, :amount_in_kopecks, :category, :description

    # ---------- Перевірки окремих полів ----------

    def self.parse_id(value)
      unless value.is_a?(Integer) && value.positive?
        raise ValidationError, 'id має бути додатним цілим числом.'
      end

      value
    end

    def self.parse_date(value)
      unless text?(value) && DATE_PATTERN.match?(value)
        raise ValidationError, 'date має бути у форматі YYYY-MM-DD (наприклад, 2026-11-16).'
      end

      year, month, day = value.split('-').map(&:to_i)
      unless year >= 1 && Date.valid_date?(year, month, day)
        raise ValidationError, "date: «#{value}» — неіснуюча календарна дата."
      end

      Date.new(year, month, day)
    end

    def self.parse_amount(value)
      unless value.is_a?(Integer) && value.positive?
        raise ValidationError, 'amount_in_kopecks має бути додатним цілим числом копійок.'
      end

      value
    end

    def self.parse_category(value)
      unless text?(value) && CATEGORIES.include?(value)
        raise ValidationError, "category має бути однією з: #{CATEGORIES.join(', ')}."
      end

      value
    end

    def self.parse_description(value)
      raise ValidationError, 'description має бути текстом.' unless text?(value)

      cleaned = value.strip
      raise ValidationError, 'description не може бути порожнім.' if cleaned.empty?

      if cleaned.length > MAX_DESCRIPTION_LENGTH
        raise ValidationError,
              "description не може бути довшим за #{MAX_DESCRIPTION_LENGTH} символів " \
              "(зараз #{cleaned.length})."
      end

      cleaned
    end

    # ---------- Розбір рядків, які вводить користувач ----------

    def self.id_from_text(text)
      unless DIGITS_PATTERN.match?(text)
        raise ValidationError, 'Ідентифікатор має бути додатним цілим числом.'
      end

      parse_id(text.to_i)
    end

    def self.amount_from_text(text)
      unless DIGITS_PATTERN.match?(text)
        raise ValidationError,
              'Сума має бути додатним цілим числом копійок (наприклад, 12550 для 125.50 грн).'
      end

      parse_amount(text.to_i)
    end

    def self.category_from_text(text)
      parse_category(text.downcase)
    end

    # ---------- Створення з JSON-об'єкта ----------

    # Якщо id передано явно (імпорт), поле "id" у JSON перевіряється, але ігнорується.
    def self.from_h(hash, id: nil)
      raise ValidationError, 'запис має бути JSON-об’єктом.' unless hash.is_a?(Hash)

      required = id.nil? ? ['id'] + BASE_KEYS : BASE_KEYS
      missing = required.reject { |key| hash.key?(key) }
      raise ValidationError, "відсутні поля: #{missing.join(', ')}." unless missing.empty?

      parse_id(hash['id']) if hash.key?('id') && !id.nil?

      new(id: id.nil? ? hash['id'] : id,
          date: hash['date'],
          amount_in_kopecks: hash['amount_in_kopecks'],
          category: hash['category'],
          description: hash['description'])
    end

    def self.text?(value)
      value.is_a?(String) && value.valid_encoding?
    end
    private_class_method :text?

    def initialize(id:, date:, amount_in_kopecks:, category:, description:)
      @id = self.class.parse_id(id)
      @date = date.is_a?(Date) ? date : self.class.parse_date(date)
      @amount_in_kopecks = self.class.parse_amount(amount_in_kopecks)
      @category = self.class.parse_category(category)
      @description = self.class.parse_description(description)
      freeze
    end

    def to_h
      {
        'id' => @id,
        'date' => @date.to_s,
        'amount_in_kopecks' => @amount_in_kopecks,
        'category' => @category,
        'description' => @description
      }
    end
  end
end
