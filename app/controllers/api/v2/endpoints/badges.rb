class Api::V2::Endpoints::Badges < Api::V2::Base
  include Api::V2::Defaults

  class Entity < Api::V2::Entities::Base
    root 'badges', 'badge'
    expose :permalink, as: :image_url, documentation: { type: 'string', desc: 'Image url'}
    expose :short_name, as: :name, documentation: { type: 'string', desc: 'Badge name'}

    def badge
      self.object
    end

    def web_url
      return "" if badge.company_id.blank?
      company_badge_url(badge, web_url_opts.merge(network: badge.company.domain))
    end
  end

  mount Api::V2::Endpoints::Badges::Index
  mount Api::V2::Endpoints::Badges::Show

end