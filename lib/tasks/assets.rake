namespace :assets do
  desc 'Copy over assets to public dir as non-digested'
  task non_digested: :environment do
    assets = Dir.glob(File.join(Rails.root, 'public/assets/**/*'))
    manifest_file = File.read(Dir.glob(File.join(Rails.root, 'public/assets/manifest-*')).first) 
    manifest_json = JSON.parse(manifest_file)["assets"]

    regex = /(-{1}[a-z0-9]{32}*\.{1}){1}/
    manifest_json.each do |relative_asset_path, digest_asset_name|
      source = digest_asset_name.split('/')
      source.push(source.pop.gsub(regex, '.'))

      non_digested = File.join(Rails.root, "public", "assets", source)

      file = File.join(Rails.root, "public", "assets", digest_asset_name)
      Rails.logger.info "cp: #{file} to #{non_digested}"
      FileUtils.cp(file, non_digested) unless file == non_digested

    end

    # assets = Dir.glob(File.join(Rails.root, 'public/assets/**/*'))
    # regex = /(-{1}[a-z0-9]{32}*\.{1}){1}/
    # assets.each do |file|
    #   next if File.directory?(file) || file !~ regex

    #   source = file.split('/')
    #   source.push(source.pop.gsub(regex, '.'))

    #   non_digested = File.join(source)

    #   next if non_digested.end_with?("manifest.json")      

    #   FileUtils.cp(file, non_digested)
    # end
  end
end