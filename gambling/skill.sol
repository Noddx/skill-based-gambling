// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SkillBasedGambling is ReentrancyGuard, Ownable {
    
    struct Player {
        uint256 totalGames;
        uint256 totalWins;
        uint256 skillRating;
        uint256 totalEarnings;
        bool isRegistered;
    }
    
    struct Game {
        address player1;
        address player2;
        uint256 betAmount;
        uint256 gameId;
        uint256 startTime;
        address winner;
        bool isCompleted;
        uint256 player1Score;
        uint256 player2Score;
    }
    
    mapping(address => Player) public players;
    mapping(uint256 => Game) public games;
    mapping(address => uint256) public pendingWithdrawals;
    
    uint256 public gameCounter;
    uint256 public houseFeePercent = 5; // 5% house fee
    uint256 public constant INITIAL_SKILL_RATING = 1000;
    uint256 public constant MIN_BET = 0.01 ether;
    uint256 public constant MAX_BET = 10 ether;
    
    event PlayerRegistered(address indexed player, uint256 skillRating);
    event GameCreated(uint256 indexed gameId, address indexed player1, uint256 betAmount);
    event GameJoined(uint256 indexed gameId, address indexed player2);
    event GameCompleted(uint256 indexed gameId, address indexed winner, uint256 prize);
    event SkillRatingUpdated(address indexed player, uint256 newRating);
    
    constructor() Ownable(msg.sender) {}
    
    /**
     * @dev Register a new player in the system
     */
    function registerPlayer() external {
        require(!players[msg.sender].isRegistered, "Player already registered");
        
        players[msg.sender] = Player({
            totalGames: 0,
            totalWins: 0,
            skillRating: INITIAL_SKILL_RATING,
            totalEarnings: 0,
            isRegistered: true
        });
        
        emit PlayerRegistered(msg.sender, INITIAL_SKILL_RATING);
    }
    
    /**
     * @dev Create a new game and wait for opponent
     */
    function createGame() external payable nonReentrant {
        require(players[msg.sender].isRegistered, "Player not registered");
        require(msg.value >= MIN_BET && msg.value <= MAX_BET, "Invalid bet amount");
        
        uint256 gameId = ++gameCounter;
        
        games[gameId] = Game({
            player1: msg.sender,
            player2: address(0),
            betAmount: msg.value,
            gameId: gameId,
            startTime: 0,
            winner: address(0),
            isCompleted: false,
            player1Score: 0,
            player2Score: 0
        });
        
        emit GameCreated(gameId, msg.sender, msg.value);
    }
    
    /**
     * @dev Join an existing game
     */
    function joinGame(uint256 _gameId) external payable nonReentrant {
        require(players[msg.sender].isRegistered, "Player not registered");
        require(games[_gameId].player1 != address(0), "Game does not exist");
        require(games[_gameId].player2 == address(0), "Game already has two players");
        require(games[_gameId].player1 != msg.sender, "Cannot play against yourself");
        require(msg.value == games[_gameId].betAmount, "Must match the bet amount");
        
        games[_gameId].player2 = msg.sender;
        games[_gameId].startTime = block.timestamp;
        
        emit GameJoined(_gameId, msg.sender);
    }
    
    /**
     * @dev Submit game results and determine winner based on skill
     */
    function submitGameResult(uint256 _gameId, uint256 _player1Score, uint256 _player2Score) external onlyOwner {
        Game storage game = games[_gameId];
        require(game.player1 != address(0) && game.player2 != address(0), "Game not ready");
        require(!game.isCompleted, "Game already completed");
        require(game.startTime > 0, "Game not started");
        
        game.player1Score = _player1Score;
        game.player2Score = _player2Score;
        game.isCompleted = true;
        
        address winner;
        address loser;
        
        // Determine winner based on score and skill rating
        uint256 player1Advantage = calculateSkillAdvantage(game.player1, game.player2);
        uint256 adjustedPlayer1Score = _player1Score + player1Advantage;
        
        if (adjustedPlayer1Score > _player2Score) {
            winner = game.player1;
            loser = game.player2;
        } else if (_player2Score > adjustedPlayer1Score) {
            winner = game.player2;
            loser = game.player1;
        } else {
            // In case of tie, higher skill rating wins
            winner = players[game.player1].skillRating >= players[game.player2].skillRating ? 
                     game.player1 : game.player2;
            loser = winner == game.player1 ? game.player2 : game.player1;
        }
        
        game.winner = winner;
        
        // Calculate prize after house fee
        uint256 totalPot = game.betAmount * 2;
        uint256 houseFee = (totalPot * houseFeePercent) / 100;
        uint256 prize = totalPot - houseFee;
        
        // Update player stats
        updatePlayerStats(winner, loser, prize);
        
        // Add prize to winner's pending withdrawals
        pendingWithdrawals[winner] += prize;
        
        emit GameCompleted(_gameId, winner, prize);
    }
    
    /**
     * @dev Withdraw accumulated winnings
     */
    function withdrawWinnings() external nonReentrant {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No winnings to withdraw");
        
        pendingWithdrawals[msg.sender] = 0;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");
    }
    
    /**
     * @dev Calculate skill advantage for player1 over player2
     */
    function calculateSkillAdvantage(address _player1, address _player2) internal view returns (uint256) {
        uint256 rating1 = players[_player1].skillRating;
        uint256 rating2 = players[_player2].skillRating;
        
        if (rating1 > rating2) {
            uint256 difference = rating1 - rating2;
            // Cap advantage at 50 points maximum
            return difference > 500 ? 50 : difference / 10;
        }
        return 0;
    }
    
    /**
     * @dev Update player statistics and skill ratings
     */
    function updatePlayerStats(address _winner, address _loser, uint256 _prize) internal {
        // Update winner stats
        players[_winner].totalGames++;
        players[_winner].totalWins++;
        players[_winner].totalEarnings += _prize;
        
        // Update loser stats
        players[_loser].totalGames++;
        
        // Update skill ratings using ELO-like system
        updateSkillRatings(_winner, _loser);
    }
    
    /**
     * @dev Update skill ratings using simplified ELO system
     */
    function updateSkillRatings(address _winner, address _loser) internal {
        uint256 winnerRating = players[_winner].skillRating;
        uint256 loserRating = players[_loser].skillRating;
        
        uint256 kFactor = 32; // Standard ELO K-factor
        
        // Calculate expected scores
        uint256 expectedWinner = calculateExpectedScore(winnerRating, loserRating);
        uint256 expectedLoser = 100 - expectedWinner; // Since winner gets 100, loser gets 0
        
        // Update ratings
        uint256 newWinnerRating = winnerRating + (kFactor * (100 - expectedWinner)) / 100;
        uint256 newLoserRating = loserRating > (kFactor * expectedLoser / 100) ? 
                                 loserRating - (kFactor * expectedLoser / 100) : 500; // Minimum rating
        
        players[_winner].skillRating = newWinnerRating;
        players[_loser].skillRating = newLoserRating;
        
        emit SkillRatingUpdated(_winner, newWinnerRating);
        emit SkillRatingUpdated(_loser, newLoserRating);
    }
    
    /**
     * @dev Calculate expected score for ELO rating system
     */
    function calculateExpectedScore(uint256 _rating1, uint256 _rating2) internal pure returns (uint256) {
        if (_rating1 >= _rating2) {
            uint256 diff = _rating1 - _rating2;
            return 50 + (diff / 20); // Simplified calculation, max 50 + 25 = 75
        } else {
            uint256 diff = _rating2 - _rating1;
            return diff >= 500 ? 25 : 50 - (diff / 20); // Min 25, normal 50 - calculated
        }
    }
    
    // View functions
    function getPlayerStats(address _player) external view returns (
        uint256 totalGames,
        uint256 totalWins,
        uint256 skillRating,
        uint256 totalEarnings,
        uint256 winRate
    ) {
        Player memory player = players[_player];
        uint256 rate = player.totalGames > 0 ? (player.totalWins * 100) / player.totalGames : 0;
        
        return (
            player.totalGames,
            player.totalWins,
            player.skillRating,
            player.totalEarnings,
            rate
        );
    }
    
    function getGameDetails(uint256 _gameId) external view returns (
        address player1,
        address player2,
        uint256 betAmount,
        bool isCompleted,
        address winner,
        uint256 player1Score,
        uint256 player2Score
    ) {
        Game memory game = games[_gameId];
        return (
            game.player1,
            game.player2,
            game.betAmount,
            game.isCompleted,
            game.winner,
            game.player1Score,
            game.player2Score
        );
    }
    
    // Owner functions
    function setHouseFeePercent(uint256 _feePercent) external onlyOwner {
        require(_feePercent <= 10, "Fee cannot exceed 10%");
        houseFeePercent = _feePercent;
    }
    
    function withdrawHouseFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        uint256 totalPendingWithdrawals = 0;
        
        // Calculate total pending withdrawals (simplified - in production use separate accounting)
        require(balance > totalPendingWithdrawals, "Insufficient house funds");
        
        (bool success, ) = payable(owner()).call{value: balance - totalPendingWithdrawals}("");
        require(success, "House withdrawal failed");
    }
}
