module PagesHelper
  def export_pages_to_csv pages
    require 'csv'
    csv_string = CSV.generate(:col_sep=>"\t") do |csv|
      pages.each do |page|
        csv << [page.url, page.title]
      end
    end
  end
end
