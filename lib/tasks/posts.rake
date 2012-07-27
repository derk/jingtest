namespace :posts do
  
  desc "remove posts"
  task :remove => :environment do
    puts "remove posts start..."

    remove_sql=<<-SQL
      delete from posts where posts.id in (33,37,31,24,11)
    SQL
    
    Post.find_by_sql(remove_sql)

    puts "remove posts done."
  end
end
