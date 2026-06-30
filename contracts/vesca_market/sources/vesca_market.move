/// Module: vesca_market
module vesca_market::vesca_market {
use sui::object_table::ObjectTable;
use sui::table::Table;
use sui::coin::Coin;
use sui::sui::SUI;
use sui::table;
use sui::object_table;

// as the certificate of orders
public struct Ordernft has key, store{
    id: UID,
}

// store vested token and the address of ordernft
public struct ListMarket<phantom VestedToken: key+store> has key, store {
    id: UID, // the address is the address of ordernft
    vested_tokens: ObjectTable<address, VestedToken>, // this is used to store vested tokens
    prices: Table<address, u64>, // this is used to store price
}
public struct OfferMarket has key, store{
    id: UID,
    coin_table: ObjectTable<address, Coin<SUI>>,
    offer_list: Table<address, address> // the key is the nft address of offermaker and value is the nft address of listed vested token.
}
// this is the admin cap
public struct MarketAdmin has key{
    id: UID, 
}

fun init(ctx: &mut TxContext) {
    let market_admin = MarketAdmin{id: object::new(ctx)};
    transfer::transfer(market_admin, ctx.sender());   
}
// create market
public entry fun create_market<VestedToken:key+store>(_:&MarketAdmin, ctx: &mut TxContext){
    let list_market = ListMarket<VestedToken>{id: object::new(ctx), vested_tokens: object_table::new(ctx), prices: table::new(ctx)};
    let offer_market = OfferMarket{id: object::new(ctx), coin_table: object_table::new(ctx), offer_list:table::new(ctx)};
    transfer::public_share_object(list_market);
    transfer::public_share_object(offer_market);
}
// delete ordernft when cancelling order and reedem returns
public(package) fun delete_ordernft(order_nft: Ordernft){
    let Ordernft{id} = order_nft;
    object::delete(id);
}
// create ordernft when placing the order
public(package) fun create_order_nft(ctx: &mut TxContext):Ordernft{
    Ordernft{id: object::new(ctx)}
}

// used when list and unlist VeSCA
public(package) fun change_price_in_listmarket<VestedToken:key+store>(listmarket: &mut ListMarket<VestedToken>, k: address, v: u64){
    let mut_value = table::borrow_mut(&mut listmarket.prices, k);
    *mut_value = v;
}
public(package) fun add_price_to_listmarket<VestedToken:key+store>(listmarket: &mut ListMarket<VestedToken>, k: address, v: u64){
    table::add(&mut listmarket.prices, k, v);
}
public(package) fun delete_price_in_listmarket<VestedToken:key+store>(listmarket: &mut ListMarket<VestedToken>, k: address){
    table::remove(&mut listmarket.prices, k);
}
public(package) fun get_price_in_listmarket<VestedToken:key+store>(listmarket: &ListMarket<VestedToken>, k: address):&u64{
    table::borrow(&listmarket.prices, k)
}

// change orders in orderbook
public(package) fun list_order_in_listmarket<VestedToken:key+store>(listmarket: &mut ListMarket<VestedToken>, k: address, v: VestedToken){
    object_table::add(&mut listmarket.vested_tokens, k, v);
}
public(package) fun unlist_order_in_listmarket<VestedToken:key+store>(listmarket: &mut ListMarket<VestedToken>, k: address): VestedToken{
    object_table::remove(&mut listmarket.vested_tokens, k) // return vested token
}

// change orders in offermarket
public(package) fun make_offer_in_offermarket(offermarket: &mut OfferMarket, k: address, v: Coin<SUI>, target_order: address){
    object_table::add(&mut offermarket.coin_table, k, v);
    table::add(&mut offermarket.offer_list, k, target_order);
}
public(package) fun cancel_offer_in_offermarket(offermarket: &mut OfferMarket, k: address):(Coin<SUI>,address){
    // return deposited sui, and remove the indexing
    (object_table::remove(&mut offermarket.coin_table, k), table::remove(&mut offermarket.offer_list, k))
    
}
}
