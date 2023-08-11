class CreateInvolvements < ActiveRecord::Migration[7.0]
  def change
    create_table :involvements do |t|
      t.bigint :defendant_id, null: false
      t.bigint :matter_id, null: false
      t.integer :role

      t.timestamps
    end
  end
end
