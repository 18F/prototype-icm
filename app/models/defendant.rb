class Defendant < ModernRecord
  has_many :sentences
  has_and_belongs_to_many :organizations
end
