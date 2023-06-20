ParameterType(
  name:        'number_array',
  regexp:      /\[.*?\]/,
  type:        Array,
  transformer: ->(s) { s.split(",").map(&:strip).map { |x| x.to_f } }
)
