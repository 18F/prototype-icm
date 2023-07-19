require_relative './migration_helper.rb'

class MoveVictimNamesToVictimsTable < ActiveRecord::Migration[7.0]
  def change
    ActiveRecord::Base.transaction do
      create_table :victims, force: :cascade do |t|
        t.string :first_name
      end

      reversible do |direction|
        direction.up do
          MigrationScript::MoveVictimNamesToVictimsTable.perform
        end
      end
    end
  end
end
