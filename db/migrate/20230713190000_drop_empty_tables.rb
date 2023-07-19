require_relative './migration_helper.rb'

# Drops all tables with a record count of 0.
class DropEmptyTables < ActiveRecord::Migration[7.0]

  # SMELL: This should probably be in MigrationScript
  def zero_record_table_names
    extend ApplicationHelper
    all_models.select do |m|
      begin
        m.count.zero?
      rescue ActiveRecord::StatementInvalid => e
        # If we get a storage access error, skip the table
        # If there's a different error, re-raise
        e.message.match?("ORA-22812") ? false : raise(e)
      end
    end.map(&:table_name)
  end

  def up
    ActiveRecord::Base.transaction do
      zero_record_table_names.each do |table_name|
        drop_table table_name, force: :cascade, if_exists: true
      end
    end
  end

  def down
    puts "This migration isn't reversible, since it dropped tables."
  end

end
