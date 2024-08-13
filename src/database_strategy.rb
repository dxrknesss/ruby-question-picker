# frozen_string_literal: true

require 'sqlite3'

class DatabaseStrategy
  def set_source(db_path)
    unless db_path.end_with? '.db'
      raise 'Invalid db file!'
    end

    @db = SQLite3::Database.new db_path
  end

  def source_open
    :file
  end

  def pretty_name
    'Questions from database (SQLite3)'
  end

  def action
    'Open database file'
  end

  def get_questions
    if @db.nil?
      return nil
    end

    @questions = {}

    select_questions = <<~sql
      select q.text, q.theme_id, t.name from questions as q
      join themes as t on q.theme_id = t.rowid
    sql

    @db.query(select_questions) { |result_set|
      result_set.each_hash do |row|
        if @questions[row['name']].nil?
          @questions[row['name']] = []
        end
        @questions[row['name']] << Question.new(row['text'], row['name'])
      end
    }

    @questions
  end
end
