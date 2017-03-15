class SamlConfigurationsController < ApplicationController

  def update
    @configuration = current_user.company.saml_configuration || current_user.company.build_saml_configuration
    @configuration.assign_attributes saml_params
    @configuration.save
    respond_with @configuration
  end

  private
  def saml_params
    params.require(:saml_configuration).permit(:is_enabled, :entity_id, 
      :sso_target_url, :slo_target_url, :name_identifier_format, :certificate, :certificate_fingerprint, :certificate_fingerprint_algorithm, 
      :authn_requests_signed, :logout_requests_signed, :logout_responses_signed, :metadata_signed, :digest_method, :signature_method)
  end
end