module test_vesca::test_vesca {

public struct TestCoin has key, store{
    id: UID
}

fun init(ctx: &mut TxContext) {
    let test_coin = TestCoin{id: object::new(ctx)};
    transfer::transfer(test_coin, ctx.sender());
}

public entry fun get_test_coin(ctx: &mut TxContext){
    let test_coin = TestCoin{id: object::new(ctx)};
    transfer::transfer(test_coin, ctx.sender());
}

}
