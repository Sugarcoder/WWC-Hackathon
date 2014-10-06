json.array!(@instructions) do |instruction|
  json.extract! instruction, :id, :description
  json.url instruction_url(instruction, format: :json)
end
