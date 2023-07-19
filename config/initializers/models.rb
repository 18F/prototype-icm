# Dynamically initialize all the models from the database
# See more in app/helpers/application_helper.rb
Rails.application.config.after_initialize do
  extend ApplicationHelper
  initialize_models
end
