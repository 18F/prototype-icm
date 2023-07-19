module ApplicationHelper

  def db
    @db ||= ActiveRecord::Base.connection
  end

  # Gets every tables' column names.
  # Use with #grep to search
  def all_column_names(count=nil)
    num = count || db.tables.count
    db.tables.first(num).flat_map.with_index do |table, i|
      puts "processing table (#{i+1}/#{num}): #{table}"
      db.columns(table).map(&:name).map do |col|
        "#{table}.#{col}"
      end
    end
  end

  # Get all the models that exist
  def all_models
    ApplicationRecord.descendants
  end

  # Dynamically create a models from a table name, explicitly
  #   setting the table name because the auto-linker doesn't
  #   play well with CRT's naming convention.
  def initialize_model(table_name)
    Object.const_set(
      table_name.classify.gsub(/([#|$])/, ''),
      Class.new(ApplicationRecord) do
        self.table_name = table_name
      end
    )
  end

  # Dynamically create all the models
  def initialize_models
    erroneous_models = []
    db.tables.each do |table_name|
      begin
        initialize_model(table_name)
      rescue NameError => e
        erroneous_models.push([table_name, e])
      end
    end
    handle_erroneous_models(erroneous_models)
  end

  def handle_erroneous_models(model_names)
    return false unless model_names.any?
    puts "\nThe following tables produced errors, so there are no models for them:\n"
    model_names.each do |table_name, error|
      puts "#{table_name}\t\t#{error.original_message}"
    end
    puts "\n\n"
    true # suppress printing of table names
  end
end
