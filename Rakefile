begin
  require 'jeweler'
  require 'uuidtools'
  require 'pathname'
  
  Jeweler::Tasks.new do |s|
    s.name = "watertower"
    s.executables = "watertower"
    s.summary = "Ruby and XUL based web application server framework."
    s.email = "contact@gironda.org"
    s.homepage = "http://github.com/gabrielg/watertower"
    s.description = "Ruby and XUL based web application server framework."
    s.authors = ["Gabriel Gironda"]
    # FIXME - weird hack around jeweler ignoring the submoduled in xpcomcore.
    s.files = (s.files + FileList["xulapp/chrome/content/vendor/**/*"]).uniq
  end
  Jeweler::GemcutterTasks.new
  
  application_ini_path = (Pathname(__FILE__).parent + "xulapp/application.ini").expand_path
  
  desc "Writes out a random UUID for the Build ID when we release to the XUL application's application.ini"
  task :write_xul_build_id do
    build_id = UUIDTools::UUID.random_create.to_s
    ini_contents = application_ini_path.read
    application_ini_path.open('w') do |f|
      f << ini_contents.sub(/^BuildID=.*$/, "BuildID=#{build_id}")
    end
  end
  
  desc "Writes out the gem version to the XUL application's application.ini"
  task :write_xul_version do
    version = (Pathname(__FILE__).parent + "VERSION").read.chomp
    ini_contents = application_ini_path.read
    application_ini_path.open('w') do |f|
      f << ini_contents.sub(/^Version=.*$/, "Version=#{version}")
    end
  end
  
  desc "Commits the application ini before a release"
  task :commit_application_ini do
    system("git", "add", application_ini_path.to_s)
    system("git", "commit", "-m", "Bumping application.ini", application_ini_path.to_s)
  end
  
  task :release => [:write_xul_build_id, :write_xul_version, :commit_application_ini]

  namespace :test do
    desc "Runs the tests for the XUL application component of WaterTower."
    task :xul do

    end

    desc "Runs the tests for the Ruby component of WaterTower."
    task :ruby do
    end
  end
  
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

