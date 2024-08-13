# frozen_string_literal: true

class Question
  attr_accessor :text
  attr_accessor :file_name

  def initialize(text, file_name)
    @text = text
    @file_name = file_name
  end
end
