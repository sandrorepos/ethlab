// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {
    struct Stake {
        uint256 amount;
        uint256 startTime;
    }

    struct TokenInfo {
        bool whitelisted;
        uint256 rewardRate; // Taxa de recompensa personalizada para o token
    }

    mapping(address => Stake) private ethStakes; // Stakes de ETH por usuário
    mapping(address => mapping(address => Stake)) private tokenStakes; // Stakes de tokens por usuário e token
    mapping(address => TokenInfo) public whitelistedTokens; // Informações dos tokens whitelisted
    uint256 public ethRewardRate; // Taxa de recompensa para ETH (agora mutável)
    address public owner;

    event StakedETH(address indexed user, uint256 amount, uint256 startTime);
    event StakedToken(address indexed user, address indexed token, uint256 amount, uint256 startTime);
    event UnstakedETH(address indexed user, uint256 amount, uint256 reward);
    event UnstakedToken(address indexed user, address indexed token, uint256 amount, uint256 reward);
    event TokenWhitelisted(address indexed token, uint256 rewardRate);
    event TokenRemovedFromWhitelist(address indexed token);
    event RewardRateChanged(address indexed token, uint256 newRate);
    event EthRewardRateChanged(uint256 newRate);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(uint256 _ethRewardRate) {
        owner = msg.sender;
        ethRewardRate = _ethRewardRate; // Define a taxa de recompensa do ETH no construtor
    }

    // Função para atualizar a taxa de recompensa do ETH
    function setEthRewardRate(uint256 newRate) external onlyOwner {
        ethRewardRate = newRate;
        emit EthRewardRateChanged(newRate);
    }

    // Função para adicionar tokens à whitelist com uma taxa de recompensa personalizada
    function addWhitelistedToken(address token, uint256 rewardRate) external onlyOwner {
        require(!whitelistedTokens[token].whitelisted, "Token already whitelisted");
        whitelistedTokens[token] = TokenInfo({
            whitelisted: true,
            rewardRate: rewardRate
        });
        emit TokenWhitelisted(token, rewardRate);
    }

    // Função para remover tokens da whitelist
    function removeWhitelistedToken(address token) external onlyOwner {
        require(whitelistedTokens[token].whitelisted, "Token not whitelisted");
        whitelistedTokens[token].whitelisted = false;
        emit TokenRemovedFromWhitelist(token);
    }

    // Função para alterar a taxa de recompensa de um token whitelisted
    function setTokenRewardRate(address token, uint256 newRate) external onlyOwner {
        require(whitelistedTokens[token].whitelisted, "Token not whitelisted");
        whitelistedTokens[token].rewardRate = newRate;
        emit RewardRateChanged(token, newRate);
    }

    // Função para fazer stake de ETH
    function stakeETH() external payable {
        require(msg.value > 0, "Cannot stake 0 ETH");

        Stake storage userStake = ethStakes[msg.sender];

        // Se o usuário já tiver um stake, calcula a recompensa acumulada e adiciona ao valor existente
        if (userStake.amount > 0) {
            uint256 reward = calculateReward(userStake.amount, userStake.startTime, ethRewardRate);
            userStake.amount += reward;
        }

        // Atualiza o stake com o novo valor e reinicia o tempo de início
        userStake.amount += msg.value;
        userStake.startTime = block.timestamp;

        emit StakedETH(msg.sender, msg.value, block.timestamp);
    }

    // Função para retirar parcialmente o stake de ETH e as recompensas
    function unstakeETH(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");

        Stake storage userStake = ethStakes[msg.sender];
        require(userStake.amount >= amount, "Insufficient ETH stake");

        // Calcula a recompensa acumulada
        uint256 reward = calculateReward(userStake.amount, userStake.startTime, ethRewardRate);
        uint256 totalAmount = amount + (reward * amount) / userStake.amount;

        // Atualiza o stake do usuário
        userStake.amount -= amount;
        userStake.startTime = block.timestamp;

        // Envia o ETH de volta ao usuário
        payable(msg.sender).transfer(totalAmount);

        emit UnstakedETH(msg.sender, amount, reward);
    }

    // Função para fazer stake de tokens ERC-20
    function stakeToken(address token, uint256 amount) external {
        require(whitelistedTokens[token].whitelisted, "Token not whitelisted");
        require(amount > 0, "Cannot stake 0 tokens");

        Stake storage userStake = tokenStakes[msg.sender][token];

        // Se o usuário já tiver um stake, calcula a recompensa acumulada e adiciona ao valor existente
        if (userStake.amount > 0) {
            uint256 reward = calculateReward(userStake.amount, userStake.startTime, whitelistedTokens[token].rewardRate);
            userStake.amount += reward;
        }

        // Transfere os tokens do usuário para o contrato
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Atualiza o stake com o novo valor e reinicia o tempo de início
        userStake.amount += amount;
        userStake.startTime = block.timestamp;

        emit StakedToken(msg.sender, token, amount, block.timestamp);
    }

    // Função para retirar parcialmente o stake de tokens e as recompensas
    function unstakeToken(address token, uint256 amount) external {
        require(whitelistedTokens[token].whitelisted, "Token not whitelisted");
        require(amount > 0, "Amount must be greater than 0");

        Stake storage userStake = tokenStakes[msg.sender][token];
        require(userStake.amount >= amount, "Insufficient token stake");

        // Calcula a recompensa acumulada
        uint256 reward = calculateReward(userStake.amount, userStake.startTime, whitelistedTokens[token].rewardRate);
        uint256 totalAmount = amount + (reward * amount) / userStake.amount;

        // Atualiza o stake do usuário
        userStake.amount -= amount;
        userStake.startTime = block.timestamp;

        // Transfere os tokens de volta ao usuário
        require(IERC20(token).transfer(msg.sender, totalAmount), "Transfer failed");

        emit UnstakedToken(msg.sender, token, amount, reward);
    }

    // Função para retornar a recompensa acumulada de ETH em stake
    function getETHReward(address user) external view returns (uint256) {
        Stake memory userStake = ethStakes[user];
        require(userStake.amount > 0, "No ETH stake found");

        // Calcula a recompensa acumulada
        return calculateReward(userStake.amount, userStake.startTime, ethRewardRate);
    }

    // Função para retornar a recompensa acumulada de um token em stake
    function getTokenReward(address user, address token) external view returns (uint256) {
        require(whitelistedTokens[token].whitelisted, "Token not whitelisted");

        Stake memory userStake = tokenStakes[user][token];
        require(userStake.amount > 0, "No token stake found");

        // Calcula a recompensa acumulada
        return calculateReward(userStake.amount, userStake.startTime, whitelistedTokens[token].rewardRate);
    }

    // Função interna para calcular a recompensa acumulada
    function calculateReward(uint256 amount, uint256 startTime, uint256 rewardRate) internal view returns (uint256) {
        uint256 stakingDuration = block.timestamp - startTime;
        uint256 stakingDurationInYears = stakingDuration / 365 days; // Converte para anos

        // Recompensa = (valor do stake * taxa de recompensa * duração em anos) / 100
        return (amount * rewardRate * stakingDurationInYears) / 100;
    }

    // Função para retornar todos os tokens em stake de um usuário
    function getUserTokenStakes(address user) external view returns (address[] memory, uint256[] memory, uint256[] memory) {
        // Conta quantos tokens o usuário tem em stake
        uint256 count = 0;
        for (uint256 i = 0; i < whitelistedTokensList.length; i++) {
            if (tokenStakes[user][whitelistedTokensList[i]].amount > 0) {
                count++;
            }
        }

        // Cria arrays para armazenar os dados
        address[] memory tokens = new address[](count);
        uint256[] memory amounts = new uint256[](count);
        uint256[] memory startTimes = new uint256[](count);

        // Preenche os arrays com os dados
        uint256 index = 0;
        for (uint256 i = 0; i < whitelistedTokensList.length; i++) {
            address token = whitelistedTokensList[i];
            if (tokenStakes[user][token].amount > 0) {
                tokens[index] = token;
                amounts[index] = tokenStakes[user][token].amount;
                startTimes[index] = tokenStakes[user][token].startTime;
                index++;
            }
        }

        return (tokens, amounts, startTimes);
    }

    // Lista de tokens whitelisted (para facilitar a iteração)
    address[] public whitelistedTokensList;
}
