module SamlConcern
  def saml_settings
    # this is just for testing purposes.
    # should retrieve SAML-settings based on subdomain, IP-address, NameID or similar
    saml_config = self.saml_configuration
    settings = OneLogin::RubySaml::Settings.new

    url_base ||= "https://#{Recognize::Application.config.host}/#{domain}" 

    # When disabled, saml validation errors will raise an exception.
    settings.soft = true

    #SP section
    settings.issuer                         = url_base + "/saml/metadata"
    settings.assertion_consumer_service_url = url_base + "/saml/acs"
    settings.assertion_consumer_logout_service_url = url_base + "/saml/logout"

    # IdP section
    settings.idp_entity_id              = saml_config.entity_id
    settings.idp_sso_target_url     = saml_config.sso_target_url
    settings.idp_slo_target_url      = saml_config.slo_target_url
    settings.idp_cert                      = saml_config.certificate

    # or settings.idp_cert_fingerprint           = "3B:05:BE:0A:EC:84:CC:D4:75:97:B3:A2:22:AC:56:21:44:EF:59:E6"
    #    settings.idp_cert_fingerprint_algorithm = XMLSecurity::Document::SHA1

    settings.name_identifier_format         = saml_config.name_identifier_format || "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

    # Security section
    settings.security[:authn_requests_signed] = saml_config.authn_requests_signed || false
    settings.security[:logout_requests_signed] = saml_config.logout_requests_signed || false
    settings.security[:logout_responses_signed] = saml_config.logout_responses_signed || false
    settings.security[:metadata_signed] = saml_config.metadata_signed || false
    settings.security[:digest_method] = saml_config.digest_method || XMLSecurity::Document::SHA1
    settings.security[:signature_method] = saml_config.signature_method || XMLSecurity::Document::RSA_SHA1

    settings
  end

  def saml_enabled?
    saml_configuration.present? && saml_configuration.is_enabled?
  end
end