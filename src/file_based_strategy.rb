# frozen_string_literal: true

require_relative 'question'
require 'fileutils'

class FileBasedStrategy
  def set_source(dir)
    @directory_name = dir
    @dir_files = Dir.children(dir)

    raise 'Directory is empty!' if @dir_files.empty?
    @dir_files.each do |file_name|
      unless file_name.end_with? '.txt'
        raise 'Invalid file extension!'
      end
    end
  end

  def source_open
    :dir
  end

  def pretty_name
    'Questions from files (directory must ONLY contain text files!)'
  end

  def action
    'Open questions directory'
  end

  def parse_questions
    @questions = {}

    file_names_sql = Hash.new(0)
    @dir_files.each_index do |index|
      file_names_sql[@dir_files[index]] = index + 1
    end

    p "#{@dir_files.length} reading ractors are going to be created"
    readers = @dir_files.each.map do |question_file_name|
      file_name_with_dir = "#{@directory_name}/#{question_file_name}"
      raise 'File is empty!' if File.size(file_name_with_dir) == 0

      Ractor.new(file_name_with_dir) do |absolute_file_name|
        questions = {}
        relative_file_name = absolute_file_name.split("/")[-1]
        theme_name = relative_file_name.split('.')[0]
        questions[theme_name] = []

        File.foreach(absolute_file_name, chomp: true) do |line|
          question_text = line.split("'").join("\'")
          questions[theme_name] << Question.new(question_text, relative_file_name)
        end

        questions
      end
    end

    readers.each { |ractor| @questions.merge! ractor.take; }
  end

  def get_questions
    if @dir_files.nil?
      return nil
    end

    parse_questions
    @questions
  end
end
