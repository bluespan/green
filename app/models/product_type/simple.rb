class ProductType::Simple < Product
  unloadable
  
  configure_green_product do |product| 
    product.type_name = "Simple"
  end

end