require 'test/unit/assertions'

module DataTransform

  class DataTransform::Base

    include Test::Unit::Assertions
    include ApplicationHelper

    def self.perform
      instance = new
      instance.perform
      instance.test_cases
    end

    def perform
      raise NotImplementedError, "Implement #perform to run the data migration"
    end

    def test_cases
      raise NotImplementedError, "Implement #test_cases with at least one test using test/unit assertions to check the migration"
    end
  end

  # Moves 100 victims' first names to a new `victims` table
  # This is just a sample of what we can do.
  class MoveVictimNamesToVictimsTable < DataTransform::Base
    def perform
      # The `victims` table didn't exist before we ran the structure part
      #   of this migration, so it wasn't initialized at app startup.
      #   Therefore, we have to initialize the model class manually if we
      #   want to use the ActiveRecord model class Victim.
      initialize_model("victims")

      Crtvictim.first(100).pluck(:victim_first_name).each do |first_name|
        ::Victim.create!(first_name: first_name)
      end
    end

    def test_cases
      assert_equal 100, ::Victim.count
    end
  end

end
