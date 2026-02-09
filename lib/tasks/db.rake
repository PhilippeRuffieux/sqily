namespace :db do
  desc "Download and restore latest production database"
  task :import do
    Rake::Task["db:download"].invoke
    Rake::Task["db:restore"].invoke
  end

  desc "Download latest production backup"
  task :download do
    dir = "/var/lib/pgsql/dumps"
    user = {"alexis" => "49273-2629", "antoine" => "49273-3228"}[ENV["USER"]]
    filename = `echo ls -lh #{dir} | ssh #{user}@gate.hidora.com -p 3022 | tail -1 | tr -s ' ' | cut -d ' ' -f 9`.strip
    `rsync --archive --verbose --progress --compress -e "ssh -p 3022" #{user}@gate.hidora.com:#{File.join(dir, filename)} tmp/production.dump`
  end

  desc "Restore latest downloaded backup"
  task restore: :environment do
    `pg_restore -d #{ENV["DATABASE_URL"]} --clean --format=c --no-owner --no-privileges --no-tablespaces tmp/production.dump`
    User.update_all(password_digest: "$2a$10$.nseyfaWpDztC4ciFu7IMOX5MSYt.5MrKdd98Gyq6Az2WBYsLtxmW")
  end
end
