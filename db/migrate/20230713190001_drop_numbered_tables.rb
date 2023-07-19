require_relative './migration_helper.rb'

# Drops all tables with 3 or more digits in the table name.
# Usually, tables with years are for specific reports and/or produced from other tables.
class DropNumberedTables < ActiveRecord::Migration[7.0]
  def up
    extend ApplicationHelper
    ActiveRecord::Base.transaction do
      all_models.
        map(&:table_name).
        select { |table_name| table_name.match?(/\d{3,}/) }
        .each { |table_name| drop_table table_name, force: :cascade, if_exists: true }
    end
  end

  def down
    puts "This migration isn't reversible, since it dropped tables."
  end
end
