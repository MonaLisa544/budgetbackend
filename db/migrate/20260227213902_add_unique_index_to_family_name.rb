class AddUniqueIndexToFamilyName < ActiveRecord::Migration[7.0]
  def change
    add_index :families, :family_name, unique: true
  end
end
