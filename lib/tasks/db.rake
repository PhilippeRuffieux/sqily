namespace :db do
  desc "Restore latest downloaded backup"
  task restore: :environment do
    params = ActiveRecord::Base.connection.instance_variable_get(:@connection_parameters)
    success = system(
      "pg_restore",
      "--dbname", PG::Connection.parse_connect_args(params),
      "--clean",
      "--format=c",
      "--no-owner",
      "--no-privileges",
      "--no-tablespaces",
      "tmp/production.dump"
    )
    User.update_all(password_digest: "$2a$10$.nseyfaWpDztC4ciFu7IMOX5MSYt.5MrKdd98Gyq6Az2WBYsLtxmW")
  end
end
