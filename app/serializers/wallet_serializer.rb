class WalletSerializer
    include FastJsonapi::ObjectSerializer
    attributes :balance, :owner_type, :owner_id
end
