import { useState } from 'react';
import { ethers } from 'ethers';
import WalletConnection from './components/WalletConnection';
import EthStaking from './components/EthStaking';
import TokenStaking from './components/TokenStaking';
import './styles.css';
import stakingABI from './Staking.jsx'; // Importe o ABI do contrato de staking

const App = () => {
    const [contract, setContract] = useState(null);
    const [signer, setSigner] = useState(null);

    const onConnect = async (provider) => {
        const signer = await provider.getSigner(); // Obtenha o signer
        setSigner(signer);

        const contractAddress = "...";
        const stakingContract = new ethers.Contract(contractAddress, stakingABI, signer);
        setContract(stakingContract);
    };

    return (
        <div>
            <h1>Staking Platform</h1>
            <WalletConnection onConnect={onConnect} />
            <EthStaking contract={contract} />
            <TokenStaking contract={contract} signer={signer} />
        </div>
    );
};

export default App;
