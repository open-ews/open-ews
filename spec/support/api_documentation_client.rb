class APIDocumentationClient < RspecApiDocumentation::RackTestClient
  private

  # https://github.com/zipmark/rspec_api_documentation/pull/543/files
  def read_request_body
    input = last_request.env["rack.input"] || StringIO.new
    input.rewind
    input.read
  end
end
