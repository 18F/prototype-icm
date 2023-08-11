class Involvement < ModernRecord
  enum :role, %i[defendant] # eventually, this will be a model association
  belongs_to :matter
  belongs_to :defendant # eventually, this will be :person
end
