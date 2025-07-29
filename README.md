# SkillGambling DApp

## Project Title
**SkillGambling** - Decentralized Skill-Based Gambling Platform

## Project Vision
To revolutionize online gambling by creating a transparent, fair, and skill-based gaming ecosystem where players' abilities directly influence their chances of winning, moving away from pure chance-based gambling to a merit-driven competitive environment.

## Project Description
SkillGambling is a decentralized application (DApp) built on Ethereum that enables players to engage in skill-based gambling games. Unlike traditional gambling platforms that rely purely on chance, our platform incorporates players' skill ratings and game performance to determine outcomes, creating a more engaging and fair gaming experience.

The platform uses an ELO-like rating system to track player skills and adjusts game advantages based on skill differences. Players can create games, join existing matches, and compete against opponents of similar or different skill levels. All transactions are transparent and recorded on the blockchain, ensuring fairness and preventing manipulation.

## Key Features

### 🎮 **Skill-Based Gaming System**
- Players have skill ratings that affect game outcomes
- ELO-like rating system that updates based on wins/losses
- Skill advantages are calculated and applied to game scores
- Fair matchmaking based on skill levels

### 👤 **Player Registration & Profiles**
- Simple registration process with initial skill rating (1000)
- Comprehensive player statistics tracking
- Total games played, wins, earnings, and win rate
- Skill rating progression over time

### 🎯 **Game Creation & Management**
- Players can create games with customizable bet amounts (0.01 - 10 ETH)
- Join existing games by matching the bet amount
- Real-time game state tracking
- Automated prize distribution

### 💰 **Transparent Economics**
- 5% house fee (adjustable by owner)
- Secure withdrawal system for winnings
- No hidden fees or manipulation
- All transactions recorded on blockchain

### 🔐 **Security & Fairness**
- ReentrancyGuard protection against attacks
- Owner-controlled game result submission (can be upgraded to oracle-based)
- Secure fund management with pending withdrawals
- OpenZeppelin security standards

## Smart Contract Functions

### Core Functions:
1. **`registerPlayer()`** - Register new players in the system
2. **`createGame()`** - Create a new game with bet amount
3. **`joinGame(uint256 _gameId)`** - Join an existing game
4. **`submitGameResult()`** - Submit game results and determine winner
5. **`withdrawWinnings()`** - Withdraw accumulated prize money

### View Functions:
- **`getPlayerStats()`** - Get comprehensive player statistics
- **`getGameDetails()`** - Get detailed information about specific games

### Owner Functions:
- **`setHouseFeePercent()`** - Adjust house fee percentage
- **`withdrawHouseFunds()`** - Withdraw house earnings

## Technology Stack
- **Smart Contract**: Solidity ^0.8.19
- **Security**: OpenZeppelin Contracts (ReentrancyGuard, Ownable)
- **Blockchain**: Ethereum (deployable to any EVM-compatible chain)
- **Standards**: ERC standards compliance

## Future Scope

### 🚀 **Short-term Enhancements (3-6 months)**
- **Oracle Integration**: Replace owner-controlled result submission with decentralized oracles
- **Multiple Game Types**: Add different skill-based games (chess, puzzle solving, strategy games)
- **Mobile App**: Develop React Native mobile application
- **Tournaments**: Implement tournament brackets with multiple elimination rounds

### 🌟 **Medium-term Development (6-12 months)**
- **Cross-Chain Support**: Deploy on Polygon, Binance Smart Chain, and Layer 2 solutions
- **NFT Integration**: Skill certificates and achievement badges as NFTs
- **Social Features**: Friend systems, leaderboards, and social challenges
- **Advanced Analytics**: Detailed performance analytics and skill progression tracking

### 🔮 **Long-term Vision (1-2 years)**
- **AI-Powered Matchmaking**: Machine learning algorithms for optimal player matching
- **Decentralized Governance**: DAO structure for platform decisions and game additions
- **Professional Leagues**: Organized competitive leagues with sponsors and prizes
- **VR/AR Integration**: Immersive gaming experiences with virtual and augmented reality

### 🌐 **Ecosystem Expansion**
- **Developer SDK**: Tools for third-party developers to create games
- **Staking Mechanisms**: Token staking for enhanced features and rewards
- **Educational Platform**: Tutorials and training modules to improve player skills
- **Partnership Program**: Integration with gaming studios and esports organizations

## Getting Started

### Prerequisites
- Node.js and npm
- Hardhat or Truffle framework
- MetaMask wallet
- Test ETH for deployment

### Deployment Steps
1. Clone the repository
2. Install dependencies: `npm install`
3. Configure network settings in `hardhat.config.js`
4. Deploy to testnet: `npx hardhat run scripts/deploy.js --network sepolia`
5. Verify contract on Etherscan
6. Connect frontend and start gaming!

## Security Considerations
- All funds are secured in the smart contract
- ReentrancyGuard prevents common attack vectors
- Owner privileges are limited and transparent
- Regular security audits recommended for mainnet deployment

## Contributing
We welcome contributions from the community! Please read our contributing guidelines and submit pull requests for any improvements.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

---

**Join the future of skill-based gaming! 🎮🚀**

## Contract Details : 0x34B412e3Da494fcaaed087b752A607FbdA700995
<img width="1920" height="1080" alt="Screenshot 2025-07-29 143720" src="https://github.com/user-attachments/assets/48aa3f90-d126-46cc-b600-ab18b9b44d0c" />
