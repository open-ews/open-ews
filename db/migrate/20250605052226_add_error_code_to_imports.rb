class AddErrorCodeToImports < ActiveRecord::Migration[8.0]
  def change
    add_column(:imports, :error_code, :string)
  end
end
