  
module Admin::PagesHelper
  def category_set_options
    class_or_item = Category.categories_only.roots
    items = Array(class_or_item)
    result = []
    items.each do |root|
      result += root.self_and_descendants.categories_only.map do |i|
        [yield(i), i.id]
      end.compact
    end
    result
  end
end
