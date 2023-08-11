module DataTransform

  # @time A few minutes
  class LoadSentences < DataTransform::Base
    DEATH_PENALTY_CODES = %w[P X]
    LIFE_SENTENCE = "L"
    TIME_SERVED = "T"
    UNITS = {
      "H" => "hours",
      "D" => "days",
      "W" => "weeks",
      "M" => "months",
      "Y" => "years"
    }

    def perform
      Crtdefendant.sentenced.find_each do |original|
        defendant = Defendant.find_by!(first_name: original.first_name, last_name: original.last_name)
        build_sentence_1(defendant, original)
        print "1"
      rescue ActiveRecord::RecordNotFound => e
        warn e.message
      end

      Crtdefendant.resentenced.find_each do |original|
        defendant = Defendant.find_by!(first_name: original.first_name, last_name: original.last_name)
        build_sentence_2(defendant, original)
        print "2"
      rescue ActiveRecord::RecordNotFound => e
        warn e.message
      end
    end

    KEYS = SentenceComponent.types.keys.freeze

    def build_sentence_1(defendant, crt_record)
      return nil unless crt_record.sentence_date.present?
      return nil unless crt_record.matter_no.present?
      build_sentence(defendant, crt_record)
    end

    def build_sentence_2(defendant, crt_record)
      return nil unless crt_record.resentence_date.present?
      return nil unless crt_record.matter_no.present?
      build_sentence(defendant, shift_resentencing(crt_record))
    end

    def shift_resentencing(crt_record)
      # Take all the resentencing attributes, which are all attributes with keys ending in 2 (except address and race)
      #   Then, remove the 2 from the end, and build a new ICM defendant record to use for building SentenceComponents
      new_attrs = crt_record.attributes.
        select { |k, v| k.match?(/2$/) && !k.match?(/^address|race/) }.
        transform_keys { |k| k.gsub(/2$/, '') }
      new_attrs.merge!({
        sentence_date: crt_record.resentence_date,
        matter_no: crt_record.matter_no,
      })
      Crtdefendant.new(new_attrs)
    end

    def build_sentence(defendant, crt_record)
      # TODO: Add parental relationship
      # TODO: Add spelling fix
      # Potential optimization: Associate sentences with involvements
      ActiveRecord::Base.transaction do
        sentence = defendant.sentences.create!(sentencing_date: crt_record.sentence_date, matter_id: crt_record.matter_no)
        components = KEYS.map { |type_name| send("build_#{type_name}", crt_record) }.compact
        if components.count.zero? && crt_record.sentence_attributes.values.all?(&:blank?)
          warn "CRT Defendant #{crt_record.def_id} has no sentence values, so will have a blank sentence"
        end
        components.each do |data|
          sentence.components.build(data).validate!
        rescue ActiveRecord::RecordInvalid, ActiveModel::RangeError => e
          puts data
          raise e
        end
        sentence.components.create!(components)
      end
    end

    def build_alternative(record)
      nil # There's no implementation of this yet
      # {type: :alternative}
    end

    def build_community_service(record)
      return nil unless all_present?(record, :comm_serv_hrs)
      {type: :community_service, duration_quantity: record.comm_serv_hrs, duration_unit: :hours}
    end

    def build_confinement(record)
      return nil unless all_present?(record, :confinement, :confine_unit)
      {type: :confinement, duration_quantity: record.confinement.to_i, duration_unit: UNITS.fetch(record.confine_unit)}
    end

    def build_death_penalty(record)
      return nil unless DEATH_PENALTY_CODES.include?(record.prison_unit)
      {type: :death_penalty}
    end

    def build_fine(record)
      return nil unless all_present?(record, :fine)
      {type: :fine, amount: record.fine}
    end

    def build_prison(record)
      return nil unless all_present?(record, :prison_unit)
      return nil if DEATH_PENALTY_CODES.include?(record.prison_unit)
      case record.prison_unit
      when *%w[Y M W D H]
        return nil if missing_prison?(record)
        {
          type: :prison,
          duration_quantity: record.prison_sent.to_i,
          duration_unit: UNITS.fetch(record.prison_unit)
        }
      when LIFE_SENTENCE
        {type: :prison, life: true}
      when TIME_SERVED
        {type: :prison, time_served: true}
      else
        raise "No match for prison_unit=#{record.prison_unit}"
      end
    end

    def build_probation(record)
      return nil unless all_present?(record, :probation_unit)
      case record.probation_unit
      when *%w[Y M W D H]
        return nil if missing_probation?(record)
        {type: :probation, duration_quantity: record.probation, duration_unit: UNITS.fetch(record.probation_unit)}
      when LIFE_SENTENCE
        {type: :probation, life: true}
      else
        raise "No match for probation_unit=#{record.probation_unit}"
      end
    end

    def build_restitution(record)
      return nil unless all_present?(record, :restitution)
      {type: :restitution, amount: record.restitution}
    end

    def all_present?(record, *attributes)
      attributes.all? { |attribute| record.send(attribute).present? }
    end

    def missing_probation?(record)
      @probation_ids ||= File.read("db/migrate/support/crtdefendants_defid_missing_probation").lines.map(&:strip)
      @probation_ids.include?(record.def_id) || (record.probation.nil? && record.probation_unit.present?)
    end

    def missing_prison?(record)
      @prison_ids ||= File.read("db/migrate/support/crtdefendants_defid_missing_prison").lines.map(&:strip)
      @prison_ids.include?(record.def_id) || (record.prison_sent.nil? && record.prison_unit.present?)
    end

    def test_cases
      assert_equal 5387, Sentence.count
      assert_equal 10513, SentenceComponent.count
      # TO COME BACK AND FIX
      # assert_equal 19, Sentence.find_each.select { |s| s.components.count.zero? }.flat_map { |x| x.defendant.originals }.select { |x| x.sentence_attributes.values.any?(&:present?) }.count
    end
  end
end
