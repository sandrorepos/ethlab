import { useState } from 'react';
import { ethers } from 'ethers';

const WalletConnection = ({ onConnect }) => {
    const [walletAddress, setWalletAddress] = useState('');

    const connectWallet = async () => {
        if (window.ethereum) {
            try {
                await window.ethereum.request({ method: 'eth_requestAccounts' });
                const provider = new ethers.BrowserProvider(window.ethereum); // Usar BrowserProvider (ethers@6)
                const signer = await provider.getSigner(); // getSigner é assíncrono
                const address = await signer.getAddress();
                setWalletAddress(`Connected: ${address.slice(0, 6)}...${address.slice(-4)}`);
                onConnect(provider); // Passe o provider para o App.jsx
            } catch (error) {
                console.error(error);
                alert('Error connecting wallet');
            }
        } else {
            alert('Please install MetaMask!');
        }
    };

    return (
        <div className="section">
            <button onClick={connectWallet}>Connect Wallet</button>
            <div>{walletAddress}</div>
        </div>
    );
};

export default WalletConnection;
