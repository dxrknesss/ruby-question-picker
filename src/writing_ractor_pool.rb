# frozen_string_literal: true

class WritingRactorPool
  def initialize(amount, file_names_sql)
    if amount.to_int < 1
      amount = 1
    else
      amount = amount.to_int
    end

    @themes = file_names_sql
    @ractor_pool = Array.new amount

    Dir.mkdir 'tmp'
    (0..amount).each do |index|
      @ractor_pool[index] = Ractor.new(@themes) do |themes|
        lines_written = 0

        file_name = "#{Ractor.current.object_id}"
        File.open("tmp/#{file_name}", "a") do |out_file|
          until (question = Ractor.receive).equal? :stop do
            out_file.write("('#{question.text}', #{themes[question.file_name]}),\n")
            lines_written += 1
          end
        end

        lines_written
      end
    end

    p "#{@ractor_pool.size} writing ractors were created"
  end

  def get_ractor
    @ractor_pool.sample
  end

  def stop_all
    @ractor_pool.each do |ractor|
      ractor << :stop
      written_lines = ractor.take
      puts "writing ractor #{ractor} has written #{written_lines} lines and stopped"
    end
  end


  # CODE FROM FILE BASED STRATEGY
  #
  # def parse_and_write_sql(out_file)
  #   Ractor.new(out_file, file_names_sql) do |out_file_name, in_file_names|
  #     File.open("db/#{out_file_name}", 'w') do |sql_file|
  #       sql_file.write <<~sql
  #         create table themes(name varchar);
  #         create table questions(text varchar, theme_id references themes(rowid));
  #       sql
  #
  #       sql_file.write "\n\ninsert into themes(name) values\n"
  #
  #       in_file_names.keys.each do |file_name|
  #         sql_file.write("('#{file_name.split('.')[0]}'),\n")
  #       end
  #
  #       sql_file.seek(-2, IO::SEEK_CUR)
  #       sql_file.putc ';'
  #
  #       sql_file.write "\n\ninsert into questions(text, theme_id) values\n"
  #     end
  #   end.take
  #
  #   ractor_amount = dir_files.length * 0.01
  #   writing_pool = WritingRactorPool.new(ractor_amount, file_names_sql)
  #
  #   writing_pool.stop_all
  #
  #   File.open("db/#{out_file}", 'r+') do |sql_file|
  #     sql_file.seek(0, IO::SEEK_END)
  #     Dir.each_child('tmp') do |tmp_file|
  #       sql_file << File.read("tmp/#{tmp_file}")
  #     end
  #
  #     sql_file.seek(-2, IO::SEEK_END)
  #     sql_file.putc ';'
  #   end
  #
  #   FileUtils.rm_r('tmp')
  # end
end
