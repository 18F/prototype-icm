class Assignment < ModernRecord
  belongs_to :role
  belongs_to :matter, class_name: "Crdmain", primary_key: :matter_no
  belongs_to :defendant # eventually, this will be :person
end
