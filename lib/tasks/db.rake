Rake::Task["db:test:load"].clear
Rake::Task["db:test:prepare"].clear
Rake::Task["db:test:purge"].clear
Rake::Task["db:schema:dump"].clear
Rake::Task["db:schema:load"].clear


namespace :db do
  namespace :test do
    task :load do |t|
      log_warning(t)
    end
    task :prepare do |t|
      log_warning(t)
    end
    task :purge do |t|
      log_warning(t)
    end
  end
  namespace :schema do
    task :dump do |t|
      log_warning(t)
    end
    task :load do |t|
      log_warning(t)
    end
  end
end


def log_warning(task_name)
  warn <<~MESSAGE
    Something tried to run #{task_name}, but we've
    overridden it so that it won't do anything.
  MESSAGE
end
