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

  class LoadDefendants < DataTransform::Base
    def perform
      Crtdefendant.primary_key = :def_id # Needs this for ordering find_each
      Crtdefendant.order(Crtdefendant.primary_key => :desc).limit(1000).each do |original|
        defendant = find_or_create_defendant(original)
        organization = find_or_create_organization(original)
        organization.defendants << defendant if organization
        print "."
      end
    end

    def test_cases
      assert_equal 3, ::Organization.count
      assert_equal 1, ::Defendant.where(first_name: "George", last_name: "Zimmerman").count
    end

    def find_or_create_defendant(original)
      candidate = ::Defendant.find_or_create_by(
        first_name: original.first_name,
        last_name: original.last_name,
      )
      assert_same_attr(:juvenile, candidate, original)
      assert_same_attr(:title, candidate, original)
      candidate.assign_attributes(
        middle_name: original.middle_in,
        title: original.title,
        juvenile: original.juvenile,
        alias: original.alias,
        alias_no: original.alias_no,
      )
      candidate.save!
      candidate
    end

    def find_or_create_organization(original)
      return unless original.affiliation.present?
      Organization.find_or_create_by(name: original.affiliation)
    end

    def assert_same_attr(attribute, candidate, incoming)
      existing_attr = candidate.send(attribute)
      incoming_attr = incoming.send(attribute)
      if existing_attr.present? && existing_attr != incoming_attr
        return unless incoming_attr.present?
        raise <<~MESSAGE
          CONFLICT
          I'm trying to assign #{attribute}=#{incoming_attr} to a record
          that already has #{attribute}=#{existing_attr}.

          Incoming:
            #{incoming.inspect}
          Candidate:
            #{candidate.inspect}
        MESSAGE
      end
    end

  end

end
