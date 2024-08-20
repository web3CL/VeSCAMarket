module vesca_market::reserve{
    use sui::balance::Balance;
    use sui::object_table::ObjectTable;
    use sui::object_table;
    use sui::sui::SUI;
    use sui::coin::Coin;
    use sui::balance;
    use sui::coin;

    const EORDERTAKEN:u64 = 0;

    public struct ReserveAdmin has key,store{
        id: UID,
    }
    
    // used to store traded vested token and sui and fee
    public struct Reserve<phantom VestedToken:key+store> has key, store{
        id: UID,
        coin_reserve: ObjectTable<address, Coin<SUI>>, // address is the same as the address of ordernft
        vested_token_reserve: ObjectTable<address, VestedToken>,
        fee: Balance<SUI>,
        fee_rate: u64 // fee_rate/1000
    }

    fun init(ctx: &mut TxContext) {
        let reserve_admin = ReserveAdmin{id: object::new(ctx)};
        transfer::transfer(reserve_admin, ctx.sender());
    }
    
    // used to buy vested token
    public(package) fun add_coin_to_reserve<VestedToken: key+store>(reserve: &mut Reserve<VestedToken>, nft_address:address, pay_coin: Coin<SUI>){
        object_table::add(&mut reserve.coin_reserve, nft_address, pay_coin); // here is the target_address
    }
    // used to redeem coin from reserve(Remember to delete nft in market module!!)
    public(package) fun get_coin_from_reserve_and_pay_fee<VestedToken: key+store>(reserve: &mut Reserve<VestedToken>, nft_address:address, ctx: &mut TxContext):Coin<SUI>{
        let mut receive_coin = object_table::remove(&mut reserve.coin_reserve, nft_address);
        // add fee logic here
        let fee_amount = coin::value(&receive_coin) * reserve.fee_rate / 1000;
        let fee_coin = coin::split(&mut receive_coin, fee_amount, ctx);
        balance::join(&mut reserve.fee, coin::into_balance(fee_coin));
        receive_coin        
    }
    // used to sell vested token
    public(package) fun add_vested_token_to_reserve_and_pay_fee<VestedToken: key+store>(reserve: &mut Reserve<VestedToken>, nft_address:address, vested_token: VestedToken, mut receive_coin: Coin<SUI>, ctx: &mut TxContext):Coin<SUI>{
        object_table::add(&mut reserve.vested_token_reserve, nft_address, vested_token);
        // pay fees
        let fee_amount = coin::value(&receive_coin) * reserve.fee_rate / 1000;
        let fee_coin = coin::split(&mut receive_coin, fee_amount, ctx);
        balance::join(&mut reserve.fee, coin::into_balance(fee_coin));
        receive_coin
    }

    // used to redeem vested coin from reserve(Remember to delete nft in market module!!)
    public(package) fun get_vested_token_from_reserve<VestedToken: key+store>(reserve: &mut Reserve<VestedToken>, nft_address:address):VestedToken{
        let vested_token = object_table::remove(&mut reserve.vested_token_reserve, nft_address);
        vested_token
    }

    public entry fun create_reserve<VestedToken: key+store>(_: &ReserveAdmin, fee_rate: u64, ctx: &mut TxContext){
        let new_reserve = Reserve<VestedToken>{id: object::new(ctx), coin_reserve: object_table::new(ctx), vested_token_reserve: object_table::new(ctx),fee: balance::zero(), fee_rate:fee_rate};
        transfer::public_share_object(new_reserve);
    }

    public entry fun collect_fee<VestedToken:key+store>(_: &ReserveAdmin, reserve: &mut Reserve<VestedToken>, amount: u64, ctx: &mut TxContext){  
        let fee_coin = coin::take(&mut reserve.fee, amount, ctx);
        transfer::public_transfer(fee_coin, ctx.sender());
    }

    public fun assert_order_exist<VestedToken:key+store>(reserve: &Reserve<VestedToken>, nft_address:address){
        assert!((!object_table::contains(&reserve.coin_reserve, nft_address)) && 
                (!object_table::contains(&reserve.vested_token_reserve, nft_address)), EORDERTAKEN);
    }

    
}