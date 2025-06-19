# Dice Chess

A blockchain-based chess variant where players roll three dice to determine which pieces they can move.

## Architecture

- **Smart Contracts**: Built with Dojo on Starknet
- **Frontend**: Next.js with TypeScript
- **Real-time Sync**: Torii indexer subscriptions
- **Libraries**: Origami (randomness) & Alexandria (data structures)

## Quick Start

### Prerequisites

- Rust & Scarb (for Dojo)
- Node.js 18+ & npm
- Dojo CLI (`dojoup`)

### Development Setup

1. **Start Katana (local Starknet)**

   ```bash
   katana --disable-fee
   ```

2. Start Torii (in a new terminal)

   ```bash
   torii --world 0x0`
   ```

3. Deploy Contracts (in new terminal)

   ```bash
   cd contracts
   sozo build
   sozo migrate apply
   ```

4. Start Frontend (in a new terminal)

   ```bash
   cd client
   npm install
   npm run dev
   ```

5. Visit http://localhost:3000
