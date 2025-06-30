class RenameLocaleToLanguageOnUsers < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :locale, :language
  end
end
