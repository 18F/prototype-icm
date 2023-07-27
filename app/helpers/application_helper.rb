module ApplicationHelper

  RAILS_TABLES = %w(
    schema_migrations
    defendants
    organizations
    defendants_organizations
  )

  def db
    @db ||= ActiveRecord::Base.connection
  end

  def all_tables
    db.tables - RAILS_TABLES
  end

  # Gets every tables' column names.
  # Use with #grep to search
  def all_column_names(count=nil)
    num = count || all_tables.count
    all_tables.first(num).flat_map.with_index do |table, i|
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
        self.inheritance_column = false # Prevents issues with columns named `type`
      end
    )
  end

  # Dynamically create all the models
  def initialize_models
    erroneous_models = []
    all_tables.each do |table_name|
      begin
        raise NameError if RAILS_TABLES.include?(table_name)
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

  def tally_by(attribute_key, first: nil)
    limit = first || Crtdefendant.count
    maybe_cached_value = try_cache(attribute_key, limit)
    return maybe_cached_value if maybe_cached_value
    puts "Calculating..."
    result = Crtdefendant.pluck(attribute_key).
      tally.
      sort_by {|_,v| v}.
      reverse.
      first(limit)
    @cache[cache_key(attribute_key, first)] = result
    result
  end

  def case_names_for_top(attribute_key, first: nil)
    tally_by(attribute_key, first: first).
      map do |k, v|
        Crdmain.find_by(matter_no: k)&.case_name || "Missing case with #{v} defendants"
      end
  end


  @cache = {}

  def try_cache(key, first)
    @cache.fetch(cache_key(key, first)) { false }
  end

  def cache_key(*args)
    args.join("-")
  end

  # Thanks to https://asktom.oracle.com/pls/apex/asktom.search?tag=how-to-calculate-current-db-size
  def db_size
    physical = db.exec_query "select sum(bytes)/1024/1024 size_in_mb from dba_data_files"
    allocated = db.exec_query "select sum(bytes)/1024/1024 size_in_mb from dba_segments"
    puts <<~MSG

      Allocated space: #{allocated.rows.first.first / 1024} GB (max: 12 GB)
      Physical space: #{physical.rows.first.first / 1024} GB

    MSG
  end


end
