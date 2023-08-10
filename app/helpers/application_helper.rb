module ApplicationHelper
  def oracle_db
    @oracle_db ||= LegacyRecord.connection
  end

  def legacy_tables
    @legacy_tables ||= oracle_db.tables
  end

  def keep_tables
    File.read("db/data/tables.keep").each_line.map(&:strip)
  end

  # Gets every tables' column names.
  # Use with #grep to search
  def all_column_names(count = nil)
    num = count || legacy_tables.count
    legacy_tables.first(num).flat_map.with_index do |table, i|
      puts "processing table (#{i + 1}/#{num}): #{table}"
      oracle_db.columns(table).map(&:name).map do |col|
        "#{table}.#{col}"
      end
    end
  end

  # Get all the models that exist
  def legacy_models
    LegacyRecord.descendants
  end

  # Dynamically create a models from a table name, explicitly
  #   setting the table name because the auto-linker doesn't
  #   play well with CRT's naming convention.
  def initialize_model(table_name)
    klass_name = table_name.classify.gsub(/([#|$])/, "")
    begin
      klass_name.constantize
    rescue NameError
      Object.const_set(
        klass_name,
        Class.new(ApplicationRecord) do
          self.table_name = table_name
          self.inheritance_column = false # Prevents issues with columns named `type`
        end
      )
    end
  end

  # Dynamically create all the models
  def initialize_models
    erroneous_models = []
    legacy_tables.each do |table_name|
      initialize_model(table_name)
    rescue NameError => e
      erroneous_models.push([table_name, e])
    end
    handle_erroneous_models(erroneous_models)
  end

  def handle_erroneous_models(model_names)
    unless model_names.any?
      puts "[initialize models] no errors"
      return true
    end
    puts "\nThe following tables produced errors, so there are no models for them:\n"
    model_names.each do |table_name, error|
      puts "#{table_name}\t\t#{error.original_message}"
    end
    puts "\n\n"
    false # suppress printing of table names
  end

  def tally_by(attribute_key, first: nil)
    limit = first || Crtdefendant.count
    maybe_cached_value = try_cache(attribute_key, limit)
    return maybe_cached_value if maybe_cached_value
    puts "Calculating..."
    result = Crtdefendant.pluck(attribute_key)
      .tally
      .sort_by { |_, v| v }
      .reverse
      .first(limit)
    @cache[cache_key(attribute_key, first)] = result
    result
  end

  def case_names_for_top(attribute_key, first: nil)
    tally_by(attribute_key, first: first)
      .map do |k, v|
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
    physical = oracle_db.exec_query("select sum(bytes)/1024/1024 size_in_mb from dba_data_files").rows.first.first
    allocated = oracle_db.exec_query("select sum(bytes)/1024/1024 size_in_mb from dba_segments").rows.first.first
    puts <<~MSG

      Allocated space: #{(allocated / 1024).round(2)} GB (max: 12 GB)
      Physical space: #{(physical / 1024).round(2)} GB

    MSG
  end
end
