# frozen_string_literal: true

require 'json'

module Battleship
  # Статистика перемог і поразок (зберігається у stats.json)
  class Statistics
    attr_reader :wins, :losses

    def initialize(path)
      @path = path
      @wins = 0
      @losses = 0
      load_from_file
    end

    def record_win
      @wins += 1
      save
    end

    def record_loss
      @losses += 1
      save
    end

    def to_s
      total = @wins + @losses
      rate = total.zero? ? 0 : (@wins * 100.0 / total).round(1)
      "Перемоги: #{@wins} | Поразки: #{@losses} | Ігор: #{total} | Відсоток перемог: #{rate}%"
    end

    private

    def load_from_file
      return unless File.exist?(@path)

      data = JSON.parse(File.read(@path))
      @wins = Integer(data['wins'])
      @losses = Integer(data['losses'])
    rescue JSON::ParserError, SystemCallError, ArgumentError, TypeError
      @wins = 0
      @losses = 0
    end

    def save
      File.write(@path, JSON.generate('wins' => @wins, 'losses' => @losses))
    rescue SystemCallError
      puts 'Попередження: не вдалося зберегти статистику у файл.'
    end
  end
end
