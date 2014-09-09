module EventsCategoriesHelper

  def extract_array_params(array)
    array = array.map(&:to_i)
    array.pop
    array
  end
  
  def create_event_categories_params(category_pounds, category_ids, event_id)
    category_pounds_and_ids = category_pounds.zip(category_ids).delete_if{ |array| array[0] == 0 || array[1] == 0 }
    category_pounds_and_ids.map{ |array| { pound: array[0], category_id: array[1], event_id: event_id } }
  end

  def record_pounds_for_each_category(category_pounds, category_ids, event)
    category_pounds = extract_array_params(category_pounds)
    category_ids = extract_array_params(category_ids)
    event_category_params = create_event_categories_params(category_pounds, category_ids, event.id)
    EventsCategories.create(event_category_params)
  end

end