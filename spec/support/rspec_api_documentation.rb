require "rspec_api_documentation/dsl"

RspecApiDocumentation.configure do |config|
  config.api_name = "OpenEWS API Documentation"
  config.api_explanation = <<~HEREDOC
    This is the API Documentation for OpenEWS.
  HEREDOC
  config.format = :slate
  config.curl_headers_to_filter = [ "Host", "Cookie", "Content-Type" ]

  config.request_headers_to_include = []
  config.response_headers_to_include = [ "Location", "Per-Page", "Total" ]
  config.request_body_formatter = proc do |params|
    JSON.pretty_generate(params) if params.present?
  end
  config.keep_source_order = true
  config.disable_dsl_status!

  # https://github.com/zipmark/rspec_api_documentation/pull/458
  config.response_body_formatter = proc do |content_type, response_body|
    if content_type =~ %r{application/.*json}
      JSON.pretty_generate(JSON.parse(response_body))
    else
      response_body
    end
  end
end
