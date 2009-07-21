class AttributeType::ChooseMany < Attribute
  
  def self.input_type
    "checkbox"
  end
  
  def input_type
    AttributeType::ChooseMany.input_type
  end
  
end