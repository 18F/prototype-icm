class CreateSentences < ActiveRecord::Migration[7.0]
  def change
    create_table :sentences, force: :cascade do |t|
      t.references :defendant, null: false, foreign_key: true
      # t.bigint :matter_id, null: false
      t.datetime :sentencing_date
      t.timestamps
    end

    # add_foreign_key :sentences, :crdmain, column: :matter_id, primary_key: :matter_no

    create_table :sentence_components, force: :cascade do |t|
      t.integer :amount
      t.text :comments
      t.references :sentence, null: false, foreign_key: true
      t.integer :type # enum
      t.integer :duration_unit # enum
      t.integer :duration_quantity
      t.integer :duration
      t.boolean :life_in_prison, null: true, default: nil
      t.boolean :time_served, null: true, default: nil

      t.timestamps
    end
  end
end
