namespace :spec do
 
  if defined?(RSpec)
    desc 'Run all specs in spec directory (exluding request/integration specs)'
    RSpec::Core::RakeTask.new(:nofeatures) do |task|
      file_list = FileList['spec/**/*_spec.rb']
   
      %w(featuresfeature).each do |exclude|
        file_list = file_list.exclude("spec/#{exclude}/**/*_spec.rb")
      end
   
      task.pattern = file_list
    end
  end
end