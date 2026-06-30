# VeSCA Market

VeSCA Market is a Sui dApp for trading vested SCA positions through marketplace orders. The project started as a hackathon collaboration and is now organized as a full-stack monorepo so the Move contracts, Next.js frontend, deployment addresses, and chain-inspection scripts can be reviewed together.

Live demo: [vesca-market.vercel.app](https://vesca-market.vercel.app/)

## Architecture

```text
.
├── apps/web                 # Next.js 14 frontend using Sui dApp Kit
├── contracts/vesca_market   # Main Sui Move marketplace package
├── contracts/test_vesca     # Testnet mock coin package
├── docs/addresses.md        # Testnet and mainnet deployment references
└── scripts/sui              # Sui object and dynamic-field inspection scripts
```

The contracts manage marketplace state for listed vested-token positions. The web app connects to Sui wallets, reads marketplace dynamic fields, and builds transactions against the deployed testnet package. The scripts are small operational helpers for checking list prices, listed vested tokens, and vested token unlock details.

## Tech Stack

- Sui Move 2024.beta
- Next.js 14 and React 18
- TypeScript
- `@mysten/dapp-kit`
- `@mysten/sui`
- Tailwind CSS and Radix UI primitives

## Getting Started

Install dependencies from the monorepo root:

```bash
npm install
```

Run the web app:

```bash
npm run dev:web
```

Build and lint the frontend:

```bash
npm run lint:web
npm run build:web
```

Build and test the Move packages if the Sui CLI is installed:

```bash
npm run move:build
npm run move:test
```

The imported frontend snapshot is wired to the testnet deployment. Copy `apps/web/.env.example` only if you want to make the expected network explicit in your local environment.

## Deployment References

Contract and object IDs are documented in [docs/addresses.md](docs/addresses.md).

The current frontend uses the testnet package:

```text
0x61335d7165330594736810e045e84d7fd22621d6cbb868779bbb145ae1e23322
```

## Attribution

This was originally built as a collaborative hackathon project. The frontend was imported as a clean snapshot from [CarryWang/vesca_market_frontend](https://github.com/CarryWang/vesca_market_frontend) at commit [`bb4b652`](https://github.com/CarryWang/vesca_market_frontend/commit/bb4b652aba5c47a3ea334f9a5095f5200c26b2e1). The contract repository base came from [cl-fi/VeSCAMarket](https://github.com/cl-fi/VeSCAMarket).
