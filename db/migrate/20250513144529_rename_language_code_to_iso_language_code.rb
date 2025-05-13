class RenameLanguageCodeToISOLanguageCode < ActiveRecord::Migration[8.0]
  def change
    rename_column :beneficiaries, :language_code, :iso_language_code
  end
end
