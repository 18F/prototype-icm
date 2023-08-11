# Dynamically initialize all the models from the database
# See more in app/helpers/application_helper.rb
Rails.application.config.after_initialize do
  extend ApplicationHelper
  initialize_models

  class ::Crtdefendant
    UNKNOWN_NAME_VALUES = [nil, "FNU", "LNU", "UNK", "UNKNOWN"]
    SENTENCE_1_ATTRS = %w[comm_serv_hrs confine_unit confinement fine prison_sent prison_unit probation probation_unit restitution].freeze
    SENTENCE_2_ATTRS = %w[comm_serv_hrs2 confine_unit2 confinement2 fine2 prison_sent2 prison_unit2 probation2 probation_unit2 restitution2].freeze
    SENTENCE_ATTRS = (SENTENCE_1_ATTRS + SENTENCE_2_ATTRS).freeze

    self.primary_key = :def_id # Need this for ordering .find_each in DataTransform

    scope :first_named, -> { where.not(first_name: UNKNOWN_NAME_VALUES) }
    scope :last_named, -> { where.not(last_name: UNKNOWN_NAME_VALUES) }
    scope :named, -> { first_named.last_named }

    scope :sentenced, -> { where.not(sentence_date: nil) }
    scope :resentenced, -> { where.not(resentence_date: nil) }

    def sentence_attributes(num=nil)
      attributes.slice *case num
      when 1 then SENTENCE_1_ATTRS
      when 2 then SENTENCE_2_ATTRS
      when nil then SENTENCE_ATTRS
      end
    end
  end
end
