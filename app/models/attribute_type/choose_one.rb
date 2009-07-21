class AttributeType::ChooseOne < Attribute
  
  def self.input_type
    "radio"
  end
  
  def input_type
    AttributeType::ChooseOne.input_type
  end
  
end