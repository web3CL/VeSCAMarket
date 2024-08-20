module vesca_market::user{
    use vesca_market::vesca_market::{ListMarket, OfferMarket, Ordernft};
    use vesca_market::reserve::{Reserve};
    use vesca_market::vesca_market;
    use vesca_market::reserve;
    use sui::sui::SUI;
    use sui::coin::Coin;
    use sui::coin;

    const ENOTENOUGHSUI:u64 = 1; 
    const EWRONGTARGET:u64 = 2;

    public entry fun list_vetoken<VestedToken:key+store>(listmarket: &mut ListMarket<VestedToken>,
                                                         vested_token: VestedToken,
                                                         price: u64, // this is the amount of sui u wanna sell
                                                         ctx: &mut TxContext){
        // create order nft for each listed order 
        let order_nft = vesca_market::create_order_nft(ctx);
        // the address of the nft will be the key of table
        let nft_address = object::id_to_address(&object::id(&order_nft));
        // set price in price table
        vesca_market::add_price_to_listmarket(listmarket, nft_address, price);
        // send vested token to orderbook
        vesca_market::list_order_in_listmarket(listmarket, nft_address, vested_token);
        // transfer nft to user
        transfer::public_transfer(order_nft, ctx.sender());
    }

    public entry fun unlist_vetoken<VestedToken:key+store>(listmarket: &mut ListMarket<VestedToken>,
                                                           reserve: &Reserve<VestedToken>,
                                                           order_nft: Ordernft,
                                                           ctx: &mut TxContext){
        // get the address of ordernft
        let nft_address = object::id_to_address(&object::id(&order_nft));
        // check whether the order has been taken
        reserve::assert_order_exist(reserve, nft_address);


        // delete price in price table
        vesca_market::delete_price_in_listmarket(listmarket, nft_address);
        // send vested token to user
        let vested_token = vesca_market::unlist_order_in_listmarket(listmarket,nft_address);
        transfer::public_transfer(vested_token, ctx.sender());
        // delete ordernft
        vesca_market::delete_ordernft(order_nft);
    }

    public entry fun change_vetoken_price<VestedToken:key+store>(listmarket: &mut ListMarket<VestedToken>,
                                                                 reserve: &Reserve<VestedToken>,
                                                                 order_nft: &Ordernft,
                                                                 new_price: u64){
        // get the address of ordernft
        let nft_address = object::id_to_address(&object::id(order_nft));
        // check whether the order has been taken
        reserve::assert_order_exist(reserve, nft_address);

        // change price in price table
        vesca_market::change_price_in_listmarket(listmarket, nft_address, new_price);
    }

    public entry fun make_offer_by_amount<VestedToken:key+store>(offermarket: &mut OfferMarket,
                                                       reserve: &Reserve<VestedToken>,
                                                       mut total_coin: Coin<SUI>,
                                                       amount: u64,
                                                       target_order: address, // the address of listed token
                                                       ctx: &mut TxContext){
        // check whether the order has been taken
        reserve::assert_order_exist(reserve, target_order);

        //split pay coin and send back residual coin
        let pay_coin = coin::split(&mut total_coin, amount, ctx);
        transfer::public_transfer(total_coin, ctx.sender());

        let order_nft = vesca_market::create_order_nft(ctx);
        let nft_address = object::id_to_address(&object::id(&order_nft));
        vesca_market::make_offer_in_offermarket(offermarket, nft_address, pay_coin, target_order);
        transfer::public_transfer(order_nft, ctx.sender());
    }


    public entry fun make_offer_by_coin<VestedToken:key+store>(offermarket: &mut OfferMarket,
                                                       reserve: &Reserve<VestedToken>,
                                                       pay_coin: Coin<SUI>,
                                                       target_order: address, // the address of listed token
                                                       ctx: &mut TxContext){
        // check whether the order has been taken
        reserve::assert_order_exist(reserve, target_order);

        let order_nft = vesca_market::create_order_nft(ctx);
        let nft_address = object::id_to_address(&object::id(&order_nft));
        
        vesca_market::make_offer_in_offermarket(offermarket, nft_address, pay_coin, target_order);
        transfer::public_transfer(order_nft, ctx.sender());
    }


    public entry fun cancel_offer<VestedToken:key+store>(offermarket: &mut OfferMarket,
                                                         reserve: &Reserve<VestedToken>,
                                                         order_nft: Ordernft,
                                                         ctx: &mut TxContext){
        let nft_address = object::id_to_address(&object::id(&order_nft));
        // check whether the order has been taken
        reserve::assert_order_exist(reserve, nft_address); // advancement in future: change it to save more gas! look up only one table at once.
        // send sui to order maker and delete indexing
        let (order_coin,_) = vesca_market::cancel_offer_in_offermarket(offermarket, nft_address);
        transfer::public_transfer(order_coin, ctx.sender());
        // delete ordernft
        vesca_market::delete_ordernft(order_nft);
    }
    // check whether has been taken, check coin's amount, delete
    public entry fun take_list<VestedToken:key+store>(listmarket: &mut ListMarket<VestedToken>,
                                                      reserve: &mut Reserve<VestedToken>,
                                                      nft_address: address,
                                                      mut pay_coin: Coin<SUI>,
                                                      ctx: &mut TxContext){
        
        // check whether the order has been taken
        reserve::assert_order_exist(reserve, nft_address);
        
        // check whether the coin is engough to pay
        let pay_amount = coin::value(&pay_coin);
        let list_price = *vesca_market::get_price_in_listmarket(listmarket, nft_address);
        assert!(pay_amount > list_price, ENOTENOUGHSUI);

        //delete price indexing in listmarket and get vested token:
        vesca_market::delete_price_in_listmarket(listmarket, nft_address);
        let vested_token = vesca_market::unlist_order_in_listmarket(listmarket,nft_address);
        
        // transfer vested token to buyer
        transfer::public_transfer(vested_token, ctx.sender());

        // split the amount of coin and send it to reserve
        let reserve_coin = coin::split(&mut pay_coin, list_price, ctx);
        // add coin to reserve
        reserve::add_coin_to_reserve(reserve, nft_address, reserve_coin);
        // send residual coin back to tx sender |  add it in the last, compiler will change the sequence of code
        transfer::public_transfer(pay_coin, ctx.sender());
    }

    // send odernft, check whether has been taken, check pairs, delete price index, send vetsted token to reserve, pay fee, get sui coin.
    public entry fun take_offer<VestedToken:key+store>(listmarket: &mut ListMarket<VestedToken>,
                                                       offermarket: &mut OfferMarket,
                                                       reserve: &mut Reserve<VestedToken>,
                                                       taker_order_nft: Ordernft,
                                                       maker_offer_address: address,
                                                       ctx: &mut TxContext){
        // get the address of listed vested token
        let tarker_order_address = object::id_to_address(&object::id(&taker_order_nft));
        // check whether the order has been taken
        reserve::assert_order_exist(reserve, tarker_order_address);
        
        // get the sui coin and the offer's target
        let(receive_coin_before_fee, offer_target_address) = vesca_market::cancel_offer_in_offermarket(offermarket, maker_offer_address);
        // check whether it is same as the targe.
        assert!(tarker_order_address==offer_target_address, EWRONGTARGET);

        // get vested token from the listmarket and delete price index
        // delete price in price table
        vesca_market::delete_price_in_listmarket(listmarket, tarker_order_address);
        // get vested token
        let vested_token = vesca_market::unlist_order_in_listmarket(listmarket,tarker_order_address);
        // add vested token to reserve and pay fee
        let receive_coin_after_fee = reserve::add_vested_token_to_reserve_and_pay_fee(reserve, maker_offer_address, vested_token, receive_coin_before_fee, ctx);
        
        // delete ordernft
        vesca_market::delete_ordernft(taker_order_nft);
        // get sui coin
        transfer::public_transfer(receive_coin_after_fee, ctx.sender());
    }

    public entry fun redeem_vested_token<VestedToken:key+store>(reserve: &mut Reserve<VestedToken>, order_nft:Ordernft, ctx:&mut TxContext){
        // get the address of ordernft
        let nft_address = object::id_to_address(&object::id(&order_nft));

        let vested_token = reserve::get_vested_token_from_reserve(reserve, nft_address);
        transfer::public_transfer(vested_token, ctx.sender());
        // delete ordernft
        vesca_market::delete_ordernft(order_nft);
    }

    public entry fun redeem_coins<VestedToken:key+store>(reserve: &mut Reserve<VestedToken>, order_nft:Ordernft, ctx:&mut TxContext){
    // get the address of ordernft
    let nft_address = object::id_to_address(&object::id(&order_nft));
    // get token
    let receive_coin_after_fee = reserve::get_coin_from_reserve_and_pay_fee(reserve, nft_address, ctx);

    transfer::public_transfer(receive_coin_after_fee, ctx.sender());
    // delete ordernft
    vesca_market::delete_ordernft(order_nft);
    }
}