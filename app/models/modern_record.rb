class ModernRecord < ApplicationRecord
  self.abstract_class = true
  connects_to database: { reading: :modern, writing: :modern }
end
