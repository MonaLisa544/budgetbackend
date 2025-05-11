class AddFamilyNameAndPasswordDigestToFamilies < ActiveRecord::Migration[7.0]
  def change
    add_column :families, :family_name, :string
    add_column :families, :password_digest, :string
  end
end
