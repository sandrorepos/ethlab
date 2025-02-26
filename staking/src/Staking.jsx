const stakingABI = [
    {
        "inputs": [
            {"internalType":"uint256","name":"_ethRewardRate","type":"uint256"}
        ],
        "stateMutability":"nonpayable",
        "type":"constructor"
    },
    {
        "anonymous":false,
        "inputs": [
            {"indexed":true,"internalType":"address","name":"user","type":"address"},
            {"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"},
            {"indexed":false,"internalType":"uint256","name":"startTime","type":"uint256"}
        ],
        "name":"StakedETH",
        "type":"event"
    },
    {
        "anonymous":false,
        "inputs": [
            {"indexed":true,"internalType":"address","name":"user","type":"address"},
            {"indexed":true,"internalType":"address","name":"token","type":"address"},
            {"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"},
            {"indexed":false,"internalType":"uint256","name":"startTime","type":"uint256"}
        ],
        "name":"StakedToken",
        "type":"event"
    },
    {
        "inputs": [],
        "name":"stakeETH",
        "outputs": [],
        "stateMutability":"payable",
        "type":"function"
    },
    {
        "inputs": [
            {"internalType":"address","name":"token","type":"address"},
            {"internalType":"uint256","name":"amount","type":"uint256"}
        ],
        "name":"stakeToken",
        "outputs": [],
        "stateMutability":"nonpayable",
        "type":"function"
    },
    {
        "inputs": [
            {"internalType":"uint256","name":"amount","type":"uint256"}
        ],
        "name":"unstakeETH",
        "outputs": [],
        "stateMutability":"nonpayable",
        "type":"function"
    },
    {
        "inputs": [
            {"internalType":"address","name":"token","type":"address"},
            {"internalType":"uint256","name":"amount","type":"uint256"}
        ],
        "name":"unstakeToken",
        "outputs": [],
        "stateMutability":"nonpayable",
        "type":"function"
    },
    {
        "inputs": [],
        "name":"ethRewardRate",
        "outputs": [{"internalType":"uint256","name":"","type":"uint256"}],
        "stateMutability":"view",
        "type":"function"
    },
    {
        "inputs": [{"internalType":"address","name":"","type":"address"}],
        "name":"ethStakes",
        "outputs": [
            {"internalType":"uint256","name":"amount","type":"uint256"},
            {"internalType":"uint256","name":"startTime","type":"uint256"}
        ],
        "stateMutability":"view",
        "type":"function"
    }
];

export default stakingABI;
