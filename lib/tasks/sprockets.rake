# Merge the requirejs manifest file into the main manifest file
# so that asset helpers know where to find the compiled js files
Rake::Task['assets:precompile'].enhance do
  manifest_path = Dir[File.join("#{Rails.root}/public/assets", "manifest*.json")].max { |a,b| test(?M, a) <=> test(?M, b) }
  rjs_path = Dir[File.join("#{Rails.root}/public/assets", "rjs-manifest*.json")].max { |a,b| test(?M, a) <=> test(?M, b) }

  manifest = ActiveSupport::JSON.decode(File.new(manifest_path)) rescue {}
  rjs_manifest = ActiveSupport::JSON.decode(File.new(rjs_path)) rescue {}

  manifest.deep_merge! rjs_manifest

  File.open(manifest_path, 'w') do |f|
    f.write manifest.to_json
  end
end
