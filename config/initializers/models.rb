# Dynamically initialize all the models from the database
# See more in app/helpers/application_helper.rb
Rails.application.config.after_initialize do
  extend ApplicationHelper
  puts "[Prep] Creating model classes from database..."
  initialize_models
  puts "[Prep] Done!"
end
