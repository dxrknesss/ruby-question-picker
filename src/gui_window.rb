# frozen_string_literal: true

require 'glimmer-dsl-libui'
require_relative 'question_picker'
require_relative 'database_strategy'
require_relative 'file_based_strategy'

class GlimmerApp
  include Glimmer::LibUI::CustomWindow

  before_body do
    @picker = QuestionPicker.new

    strategies = [DatabaseStrategy.new, FileBasedStrategy.new]
    @picker.set_strategies(strategies)
    @strategies_cell_values = strategies.map do |strategy|
      [strategy.pretty_name, 'No path selected!', strategy.action, strategy.source_open, strategy]
    end
  end

  body do
    window('Question Picker', 1000, 800) {
      vertical_box {
        table {
          text_column('Questions source')

          text_column('Path')

          button_column('Action') {
            on_clicked do |row|
              possible_source = ''
              if @strategies_cell_values[row][3].equal? :dir
                possible_source = open_folder
              elsif @strategies_cell_values[row][3].equal? :file
                possible_source = open_file
              end

              begin
                raise ArgumentError.new('No source') if possible_source.nil?

                @strategies_cell_values[row][4].set_source possible_source
                @strategies_cell_values[row][1] = possible_source

                @picker.fill_question_bank
                @themes_table.cell_rows = @picker.get_themes.map { |theme| [theme, false] }
              rescue RuntimeError
                @strategies_cell_values[row][1] = 'Invalid source selected!'
              rescue ArgumentError
              end
            end
          }

          cell_rows @strategies_cell_values
        }

        horizontal_separator {
          stretchy false
        }

        @themes_table = table {
          self.sortable = false

          text_column('Theme')
          checkbox_column('Include') {
            editable true
          }

          cell_rows @themes

          on_edited do |row, row_data|
            p "row #{row} was changed to #{row_data}"
            if row_data[1]
              @picker.add_active_theme(row_data[0])
            else
              @picker.remove_active_theme(row_data[0])
            end
          end
        }

        area {
          text {
            align :center
            default_font family: 'Cantarell', size: 20, weight: :regular
            @string_proxy = string {
              color r: 1, g: 1, b: 1
            }
          }
        }

        button('Pick random question') {
          on_clicked do
            begin
              @string_proxy.set_color [255, 255, 255]
              @string_proxy.string = @picker.get_question.text
            rescue RuntimeError
              @string_proxy.set_color [255, 0, 0]
              @string_proxy.string = 'No themes selected! Try again!'
            end
          end
        }
      }
    }.show
  end
end

GlimmerApp.launch
