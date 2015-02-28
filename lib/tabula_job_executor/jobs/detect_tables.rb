require 'tabula'

require_relative '../executor.rb'

class DetectTablesJob < Tabula::Background::Job
  include Observable

  def perform
    filepath = options[:filepath]
    output_dir = options[:output_dir]

    page_areas_by_page = []

    extractor = Tabula::Extraction::ObjectExtractor.new(filepath, :all)
    page_count = extractor.page_count

    extractor.extract.each do |page|
      page_index = page.page_number - 1

      at((page_count + page_index) / 2,
         page_count,
         "auto-detecting tables...") #starting at 50%...

      page_areas_by_page << page.spreadsheets.map { |rect|
        [ rect.x, rect.y, rect.width, rect.height ]
      }
    end

    File.open(output_dir + "/tables.json", 'w') do |f|
      f.puts page_areas_by_page.to_json
    end

    at(100, 100, "complete")
    return nil
  end
end
