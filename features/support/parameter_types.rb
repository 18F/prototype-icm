ParameterType(
  name:        'number_array',
  regexp:      /\[.*?\]/,
  type:        Array,
  transformer: ->(s) { s.split(",").map(&:strip).map { |x| x.to_f } }
)

# These next three help us create matchers like:
#   'expect {article} {value_word} {lead_in} {int}'
# Example matches:
#   expect the sum to be {int}
#   expect a count of {int}
#   expect the value is {int}

ParameterType(
  name:        'article',
  regexp:      /a|an|the/,
  type:        String,
  transformer: ->(string) { string }
)

ParameterType(
  name:        'value_word',
  regexp:      /count|sum|total|value/,
  type:        String,
  transformer: ->(string) { string }
)

ParameterType(
  name:        'lead_in',
  regexp:      /is|of|to be|will be/,
  type:        String,
  transformer: ->(string) { string }
)
