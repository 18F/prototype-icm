class CreateDefendants < ActiveRecord::Migration[7.0]
  def change
    ActiveRecord::Base.transaction do
      create_table :defendants, force: :cascade do |t|
        t.string :first_name
        t.string :middle_name
        t.string :last_name
        t.string :title
        t.boolean :juvenile
        t.boolean :alias
        t.integer :alias_no

        t.timestamps
      end

      create_table :organizations, force: :cascade do |t|
        t.string :name
        t.string :defendant_affiliation_name

        t.timestamps
      end

      create_table :defendants_organizations, id: false, force: :cascade do |t|
        t.bigint :defendant_id
        t.bigint :organization_id
      end

      add_index :defendants_organizations, :defendant_id
      add_index :defendants_organizations, :organization_id

      reversible do |direction|
        direction.up do
          DataTransform::LoadDefendants.perform
        end
      end
    end # transaction
  end
end
