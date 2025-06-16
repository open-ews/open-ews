require "csv"

class ExportCSV < ApplicationWorkflow
  attr_reader :export

  def initialize(export)
    super()
    @export = export
  end

  def call
  end
end
