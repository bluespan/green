def file_starts_with?(file, string)
  return false unless File.exist?(file)

  contents = ''
  File.open(file, 'r') do |f|
   contents = f.sysread(20)
  end
  
  contents.include?(string)
end

namespace :green do
  
  desc "Bootstrap your application for using green"
  task :bootstrap => [:"bootstrap:link:assets", :"bootstrap:sync", :"bootstrap:copy:configs", :"bootstrap:copy:initial_templates"] do
  end
  
  namespace :bootstrap do
    
    namespace :link do
      desc "Link green assets to the public assets"
      task :assets do
        print "** Linking assets... "
        ["javascripts", "stylesheets", "images"].each do |asset|
          asset_blue = "../../vendor/plugins/green/assets/#{asset}"
          asset_link = "public/#{asset}/green"
          unless File.exist?(asset_link)
            print "#{asset}... "
            File.symlink(asset_blue, asset_link) 
          end
        end
        
        puts "done."
      end
    end
    
    desc "Updates green files within your application"
    task :sync => [:"sync:migrations"]
    namespace :sync do 
      desc "Sync green migrations"
      task :migrations do 
        puts "** Syncing migrations..."
        system "rsync -ruv vendor/plugins/green/db/migrate db"
        puts "** Done syncing migrations."
      end
    end

    namespace :copy do
    
      desc "Copy configs"
      task :configs do
        print "** Copying configs... "
        FileList["vendor/plugins/blue/config/initializers/green.rb"].each do |source|
            target = source.gsub("vendor/plugins/green", "")
            unless file_starts_with?(RAILS_ROOT+target, "# modified by green")
              print "#{target}... "
              FileUtils.cp_r source, RAILS_ROOT+target
            end
        end
        puts "done."
      end
      
      desc "Initial Templates"
      task :initial_templates do
        print "** Copying initial templates... "
        mkdir_p("app/views/catalog")
        FileList[].each do |source|
            target = source.gsub("vendor/plugins/blue/", "")
            unless File.exist?(target)
              mkdir_p(target.gsub(/\/[^\/]+$/, ""))
              FileUtils.cp_r source, target
              print "#{target}... "
            end
        end
        puts "done."
      end
    end
  end
  
end