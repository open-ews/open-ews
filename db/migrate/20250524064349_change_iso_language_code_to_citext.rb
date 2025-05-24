class ChangeISOLanguageCodeToCitext < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        change_column(:beneficiaries, :iso_language_code, :citext)
      end

      dir.down do
        change_column(:beneficiaries, :iso_language_code, :string)
      end
    end
  end
end
