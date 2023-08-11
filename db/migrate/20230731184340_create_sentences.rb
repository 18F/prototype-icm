class CreateSentences < ActiveRecord::Migration[7.0]
  def change
    create_table :sentences, force: :cascade do |t|
      t.references :defendant, null: false, foreign_key: true
      t.bigint :matter_id, null: false # Not a foreign key because data is in the Oracle db
      t.datetime :sentencing_date
      t.timestamps
    end

    create_table :sentence_components, force: :cascade do |t|
      t.integer :amount
      t.text :comments
      t.references :sentence, null: false, foreign_key: true
      t.integer :type # enum
      t.integer :duration_unit # enum
      t.integer :duration_quantity
      t.bigint :duration
      t.boolean :life, null: true, default: nil
      t.boolean :time_served, null: true, default: nil

      t.timestamps
    end

    add_index :defendants, :first_name
    add_index :defendants, :last_name
  end
end
