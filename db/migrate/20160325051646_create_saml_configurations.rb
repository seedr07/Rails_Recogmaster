class CreateSamlConfigurations < ActiveRecord::Migration
  def change
    create_table :saml_configurations do |t|
      t.integer :company_id
      t.boolean :is_enabled
      t.text :entity_id
      t.text :sso_target_url
      t.text :slo_target_url
      t.text :name_identifier_format
      t.text :certificate
      t.text :certificate_fingerprint
      t.text :certificate_fingerprint_algorithm
      t.boolean :authn_requests_signed
      t.boolean :logout_requests_signed
      t.boolean :logout_responses_signed
      t.boolean :metadata_signed
      t.string :digest_method
      t.string :signature_method

      t.timestamps
    end
  end
end
