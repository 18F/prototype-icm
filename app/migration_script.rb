require 'test/unit/assertions'

module MigrationScript

  class MigrationScript::Base

    include Test::Unit::Assertions

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

  class MoveVictimNamesToVictimsTable < MigrationScript::Base
    def perform
      Crtvictim.first(100).pluck(:victim_first_name).each do |first_name|
        Victim.create!(first_name: first_name)
      end
    end

    def test_cases
      assert_equal 100, Victim.count
    end
  end

end
