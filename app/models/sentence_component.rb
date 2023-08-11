class SentenceComponent < ModernRecord
  self.inheritance_column = false

  belongs_to :sentence

  enum :type, %i[
    alternative
    community_service
    confinement
    death_penalty
    fine
    prison
    probation
    restitution
  ]

  # If a sentence is 2 years:
  #   the duration quantity is 2
  #   the duration unit is "years"
  enum :duration_unit, %i[years months weeks days hours minutes]

  # Before running validations, turn the duration into an integer
  #   so we can compare and sort by duration amounts.
  # Example: a 2-year sentence would call `2.years` => 63113904
  before_validation :calculate_duration, if: :type_has_duration?, unless: :conditions_override_duration?

  validates :amount, presence: true, if: :fine?
  validates :comments, presence: true, if: :alternative?
  with_options if: :type_has_duration?, unless: :conditions_override_duration? do |component|
    component.validates :duration_quantity, presence: true
    component.validates :duration_unit, presence: true
    component.validates :duration, presence: true
  end

  def type_has_duration?
    confinement? || prison? || probation? || community_service?
  end

  def conditions_override_duration?
    life? || time_served?
  end

  def calculate_duration
    self.duration = duration_quantity.send(duration_unit).to_i
  end

  def duration
    ActiveSupport::Duration.build(read_attribute(:duration))
  end

  def humanize_duration(life_default: 255.years, time_served_default: 0)
    case type
    when "community_service"
      {hours: duration_quantity}
    else
      life_default if life?
      time_served_default if time_served?
      duration.parts
    end
  end
end
