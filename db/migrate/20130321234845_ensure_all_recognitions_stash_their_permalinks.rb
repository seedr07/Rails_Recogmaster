class EnsureAllRecognitionsStashTheirPermalinks < ActiveRecord::Migration
  def up
#    Recognition.with_deleted.all.each do |r|
#      r.send(:generate_slug) if r.slug.blank?
#    end
  end
end
