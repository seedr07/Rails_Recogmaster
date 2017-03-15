class SamlConfiguration < ActiveRecord::Base
  belongs_to :company

  validates :company_id, presence: true
end
