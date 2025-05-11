class WalletSerializer
    include FastJsonapi::ObjectSerializer
    attributes :balance, :owner_type, :owner_id
    attribute :owner_name do |wallet|
        wallet.owner.respond_to?(:name) ? wallet.owner.name : nil
      end
    belongs_to :wallet
end
