require_relative './migration_helper.rb'

# Drops all tables with 4 or more digits in the table name.
# Usually, tables with years are for specific reports and/or produced from other tables.
class DropNumberedTables < ActiveRecord::Migration[7.0]
  def change
    ActiveRecord::Base.transaction do
      reversible do |direction|
        direction.up do
          extend ApplicationHelper
          models_to_drop = all_models.select do |klass|
            klass.name.split("::").last.match?(/\d{4,}/)
          end

          models_to_drop.map(&:table_name).each do |table_name|
            drop_table table_name, force: :cascade, if_exists: true
          end
        end

        direction.down do
          puts "This migration isn't reversible, since it dropped tables."
        end
      end
    end
  end
end
