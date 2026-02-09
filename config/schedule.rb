# Learn more: http://github.com/javan/whenever

every :hour do
  rake "sqily:hourly"
end

every :day, at: "08am" do
  rake "sqily:daily"
end
