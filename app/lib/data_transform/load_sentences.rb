module DataTransform
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
      Crtdefendant.where.not(prison_sent: nil).limit(10000).each do |original|
        next if skip_defendant(original)
        defendant = ::Defendant.find_by(first_name: original.first_name, last_name: original.last_name)
        next if defendant.nil?
        # TODO: Build sentence 2
        build_sentence_1(defendant, original)
        print "."
      end
    end

    def build_sentence_1(defendant, crt_record)
      return nil unless crt_record.sentence_date.present?
      return nil unless crt_record.matter_no.present?
      # TODO: Add matter_no into below line
      # TODO: Add parental relationship
      # TODO: Add spelling fix
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
      { type: :community_service, duration_quantity: record.comm_serv_hrs, duration_unit: :hours }
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
      # TODO: Undo this, and actually check something
      assert true
    end
  end
end
