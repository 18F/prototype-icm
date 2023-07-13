module ApplicationHelper
  def db
    @db ||= ActiveRecord::Base.connection
  end

  def all_column_names(count=nil)
    num = count || db.tables.count
    db.tables.first(num).flat_map.with_index do |table, i|
      puts "processing table (#{i+1}/#{num}): #{table}"
      db.columns(table).map(&:name).map do |col|
        "#{table}.#{col}"
      end
    end
  end

end
