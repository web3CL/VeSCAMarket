# VeSCA Market Addresses

This project keeps the deployed object IDs in source control so the frontend, scripts, and contracts can be understood together.

## Demo

- Live demo: <https://vesca-market.vercel.app/>
- Frontend snapshot source: <https://github.com/CarryWang/vesca_market_frontend>
- Contract source before monorepo restructure: <https://github.com/cl-fi/VeSCAMarket>

## Testnet

| Name | Value |
| --- | --- |
| Package | `0x61335d7165330594736810e045e84d7fd22621d6cbb868779bbb145ae1e23322` |
| Reserve | `0x35400daaf67801c2b6f92ed4c9fa9527ccea035f3190d78066cfaf9cc1d1f217` |
| OfferMarket | `0x6b838f318bc250ce5ab9c95cce520c923abf0012c925bdb4f07e0beb42f137d1` |
| ListMarket | `0x2ddd4a2207c69e6ac5298ffd6a00d792b3699adef6fc36a19d09b3f745ef2531` |
| PricesTable | `0x6b9a2766d65b6fd24b2372b79c1eb340d046112bdde76057da365a7686b20787` |
| VestedTokensTable | `0xfb1f4a011deddf41d7acbeae944588d8c7d19bffcab5de1662b0f5187638ddd1` |
| CoinReserveTable | `0xffbd8df033ebf2aafa3d0c71cf4b3b2e48efdb24eb40249c811a26a552107606` |
| VeTokenReserveTable | `0x5c5fa81cb46109d6bc4c4d1f4fac9db641f22ebc48f17a63265792fec1e11b9b` |
| Mock coin type argument | `0x784370cb40d01b563095e3e3889acf4d1dd2dca66d5d5d05d21c3785e8b4edb8::test_vesca::TestCoin` |
| Order NFT type | `0x61335d7165330594736810e045e84d7fd22621d6cbb868779bbb145ae1e23322::vesca_market::Ordernft` |

## Mainnet

| Name | Value |
| --- | --- |
| Package | `0x4fa5c4166d472223e0033126da35caa8a37951a33c6f29fc25c95afe67a4bc22` |
| MarketAdmin | `0x6c0b35279a9adb8433c38d00a50e1dc226707062816f9db62336aab59d41860c` |
| ReserveAdmin | `0xf70d597214c43cb5d4c43bcd064e5a89039a6c8050591943dfcee7d95cd76932` |
| Reserve | `0x04553d78ca176d6a6701584f683b89ad22c096ab498cc45211346ac199616868` |
| OfferMarket | `0x1975fbda1fddd14f41fdf1f2e807ecb1589f8fedecbd4f1f8a5e6fd762d798ae` |
| ListMarket | `0xa28d404f919f30c58efe0a2f3ea47b8965aa9dedca140873ba86ca0dce92bb35` |
| SCA type argument | `0xcfe2d87aa5712b67cad2732edb6a2201bfdf592377e5c0968b7cb02099bd8e21::ve_sca::VeScaKey` |

## Notes

- The imported frontend snapshot is wired to the testnet deployment.
- The JS scripts in `scripts/sui` are small chain-inspection helpers for dynamic fields and vested token state.
