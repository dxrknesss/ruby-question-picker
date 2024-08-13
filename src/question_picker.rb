# frozen_string_literal: true

require_relative 'question'

class QuestionPicker
  def initialize
    @question_fetch_strategies = []
    @available_questions = Hash.new(0)
    @question_bank = Hash.new(0)
    @strategy_methods = [:get_questions, :set_source, :action, :pretty_name]
  end

  def set_strategies(strategies)
    strategies.each do |strategy|
      @strategy_methods.each do |method|
        unless strategy.respond_to? method
          raise "Strategy doesn't respond to needed methods!"
        end
      end
    end

    @question_fetch_strategies = strategies
  end

  def get_strategies
    @question_fetch_strategies
  end

  def fill_question_bank
    if @question_fetch_strategies.empty?
      raise 'Choose question fetching strategy first!'
    else
      @question_fetch_strategies.each do |strategy|
        if (questions = strategy.get_questions)
          @question_bank.merge!(questions)
        end
      end
    end
  end

  def add_active_theme(theme_name)
    if @question_bank.empty?
      raise 'Question bank is empty! First add some questions to it!'
    else
      @available_questions [theme_name] = @question_bank[theme_name]
    end
  end

  def remove_active_theme(theme_name)
    if @question_bank.empty?
      raise 'Question bank is empty! First add some questions to it!'
    else
      @available_questions.delete(theme_name)
    end
  end

  def get_themes
    @question_bank.keys
  end

  def get_question
    if @available_questions.nil? || @available_questions.keys.empty?
      raise 'No questions available!'
    else
      random_theme = @available_questions.keys.sample
      @available_questions[random_theme].sample
    end
  end
end