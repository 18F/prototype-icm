class LoadDefendants < ActiveRecord::Migration[7.0]
  def change
    reversible do |direction|
      direction.up do
        ModernRecord.transaction {
          DataTransform::LoadDefendants.test
        }
      end
    end
  end
end
