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
    # FIXME: Limit of 1000 due to database size limits
    def perform
      Crtdefendant.order(Crtdefendant.primary_key => :desc).limit(1000).each do |original|
        defendant = find_or_create_defendant(original)
        find_or_create_organization(original, defendant)
        print "."
      end
    end

    def test_cases
      assert_equal 3, ::Organization.count
      # assert_equal 1, ::Defendant.where(first_name: "George", last_name: "Zimmerman").count
    end

    def find_or_create_defendant(original)
      candidate = ::Defendant.find_or_create_by!(
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

    def find_or_create_organization(original, defendant)
      return unless original.affiliation.present?
      organization = ::Organization.find_or_create_by!(
        name: canonical_org_name(original.affiliation),
        defendant_affiliation_name: original.affiliation
      )
      organization.defendants << defendant
    end

    OrgName = ActiveSheet.use('db/migrate/support/organizations.csv')

    def canonical_org_name(original_name)
      new_name = OrgName.find_by("Original" => original_name).fetch("Reassigned") { nil }
      if new_name
        info "Using canonical name #{new_name} instead of #{original_name}"
        new_name
      else
        original_name
      end
      # TODO LATER: Add parental relationship
      # TODO LATER: Add spelling fix
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

  class LoadSentences < DataTransform::Base

    DEATH_PENALTY_CODES = %w( P X )
    LIFE_SENTENCE = "L"
    TIME_SERVED = "T"
    UNITS = {
      "H" => "hours",
      "D" => "days",
      "W" => "weeks",
      "M" => "months",
      "Y" => "years",
    }

    def perform
      Crtdefendant.order(Crtdefendant.primary_key => :desc).limit(1000).each do |original|
        defendant = ::Defendant.find_by!(first_name: original.first_name, last_name: original.last_name)
        # TODO NEXT UP:
        #   Add the second sentence
        #   Add Matter, maybe to the previous migration
        build_sentence_1(defendant, original)
        print "."
      end
    end

    def build_sentence_1(defendant, crt_record)
      return nil unless crt_record.sentence_date.present?
      return nil unless crt_record.matter_no.present?
      # TODO: Add matter_no into below line
      ActiveRecord::Base.transaction do
        sentence = defendant.sentences.create!(sentencing_date: crt_record.sentence_date)
        components = SentenceComponent.types.keys.map do |type_name|
          send("build_#{type_name}", crt_record)
        end.compact
        components.each do |data|
          sentence.components.build(data).validate!
        rescue ActiveRecord::RecordInvalid => e
          puts data
          raise e
        end
        sentence.components.create!(components)
      end
    end

    def build_alternative(record)
      return nil # There's no implementation of this yet
      { type: :alternative }
    end

    def build_community_service(record)
      return nil unless all_present?(record, :comm_serv_hrs)
      { type: :service, duration_quantity: record.comm_serv_hrs, duration_unit: :hours }
    end

    def build_confinement(record)
      return nil unless all_present?(record, :confinement, :confine_unit)
      { type: :confinement, duration_quantity: record.confinement.to_i, duration_unit: UNITS.fetch(record.confine_unit) }
    end

    def build_death_penalty(record)
      return nil unless DEATH_PENALTY_CODES.include?(record.prison_unit)
      { type: :death_penalty }
    end

    def build_fine(record)
      return nil unless all_present?(record, :fine)
      { type: :fine, amount: record.fine }
    end

    def build_prison(record)
      return nil unless all_present?(record, :prison_sent, :prison_unit)
      return nil if DEATH_PENALTY_CODES.include?(record.prison_unit)
      case record.prison_unit
      when %w( Y M W D H )
        {
          type: :prison,
          duration_quantity: record.prison_sent.to_i,
          duration_unit: UNITS.fetch(record.prison_unit)
        }
      when LIFE_SENTENCE
        { type: :prison, life_in_prison: true }
      when TIME_SERVED
        { type: :prison, time_served: true }
      end
    end

    def build_probation(record)
      return nil unless all_present?(record, :probation, :probation_unit)
      { type: :probation, duration_quantity: record.probation, duration_unit: UNITS.fetch(record.probation_unit) }
    end

    def build_restitution(record)
      return nil unless all_present?(record, :restitution)
      { type: :restitution, amount: record.restitution }
    end

    def all_present?(record, *attributes)
      attributes.all? { |attribute| record.send(attribute).present? }
    end

    def test_cases
      assert false # Automatically fail and rollback
    end
  end

end
