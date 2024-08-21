module vesca_market::vesca_inf{
    use ve_sca::ve_sca::{VeScaTable, VeScaKey};
    use ve_sca::ve_sca::{locked_sca_amount, unlock_at};

    public entry fun get_vesca_info(vesca_key: &VeScaKey, vesca_table: &VeScaTable):(u64, u64){
        let id = object::id(vesca_key);
        let sca_amount = locked_sca_amount(id, vesca_table);
        let unlock_time = unlock_at(id, vesca_table);
        (sca_amount, unlock_time) // the unclock time is u64, an Unix Timestamp format , the scallop's decimal is 9
    }
}