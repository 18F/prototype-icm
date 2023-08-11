class Defendant < ModernRecord
  has_many :sentences
  has_and_belongs_to_many :organizations

  has_many :involvements
  has_many :matters, through: :involvements, disable_joins: true

  def originals
    Crtdefendant.where(first_name: first_name, last_name: last_name)
  end
end
