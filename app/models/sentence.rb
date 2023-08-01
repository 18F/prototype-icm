class Sentence < ApplicationRecord
  belongs_to :defendant
  # belongs_to :matter, class_name: "Crdmain", primary_key: :matter_no
  has_many :components, class_name: "SentenceComponent"

  # Order earliest -> latest by default
  default_scope { order(sentencing_date: :asc) }

  validates :sentencing_date, presence: true
end
