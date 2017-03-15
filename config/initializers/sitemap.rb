# require 'rubygems'
# require 'sitemap_generator'

# SitemapGenerator::Sitemap.default_host = 'https://recognizeapp.com'
# SitemapGenerator::Sitemap.create do
#   add '/', :changefreq => 'weekly', :priority => 0.9
#   ['/rewards', '/sales', '/pricing', 'employee-recognition-awards',
#    'office-365', 'yammer-integration', 'case-study', 'distributed-workforce-infographic',
#    '/sign-up', '/tour', '/customizations', '/analytics', '/contact', '/features', '/best-practices-handbook.pdf'].each do |page|
#     add page, :changefreq => 'weekly'
#   end
# end
# SitemapGenerator::Sitemap.ping_search_engines # Not needed if you use the rake tasks