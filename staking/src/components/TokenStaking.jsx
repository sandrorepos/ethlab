import React, { useState } from 'react';
import { ethers } from 'ethers';
import ERC20_ABI from '../ERC20ABI'; // Importe o ERC20_ABI

const TokenStaking = ({ contract, signer }) => {
    const [tokenAddress, setTokenAddress] = useState('');
    const [tokenAmount, setTokenAmount] = useState('');
    const [unstakeTokenAddress, setUnstakeTokenAddress] = useState('');
    const [unstakeTokenAmount, setUnstakeTokenAmount] = useState('');

    const stakeToken = async () => {
        try {
            // Verifique se o valor de tokenAmount é válido
            if (!tokenAmount || isNaN(tokenAmount)) {
                alert('Por favor, insira uma quantidade válida de tokens.');
                return;
            }

            // Crie uma instância do contrato ERC-20 com o signer
            const tokenContract = new ethers.Contract(tokenAddress, ERC20_ABI, signer);

            // Aprove o gasto de tokens
            const approveTx = await tokenContract.approve(
                contract.target, // Endereço do contrato de staking
                ethers.parseUnits(tokenAmount, 18) // Quantidade de tokens a aprovar
            );
            await approveTx.wait();

            // Stake os tokens
            const tx = await contract.stakeToken(
                tokenAddress,
                ethers.parseUnits(tokenAmount, 18) // Quantidade de tokens a stakear
            );
            await tx.wait();
            alert('Tokens staked successfully!');
        } catch (error) {
            console.error(error);
            alert('Error staking tokens');
        }
    };

    const unstakeToken = async () => {
        try {
            // Verifique se o valor de unstakeTokenAmount é válido
            if (!unstakeTokenAmount || isNaN(unstakeTokenAmount)) {
                alert('Por favor, insira uma quantidade válida de tokens para unstake.');
                return;
            }

            const tx = await contract.unstakeToken(
                unstakeTokenAddress,
                ethers.parseUnits(unstakeTokenAmount, 18) // Quantidade de tokens a unstakear
            );
            await tx.wait();
            alert('Tokens unstaked successfully!');
        } catch (error) {
            console.error(error);
            alert('Error unstaking tokens');
        }
    };

    return (
        <div className="section">
            <h2>Token Staking</h2>
            <input
                type="text"
                value={tokenAddress}
                onChange={(e) => setTokenAddress(e.target.value)}
                placeholder="Token address"
            />
            <input
                type="number"
                value={tokenAmount}
                onChange={(e) => setTokenAmount(e.target.value)}
                placeholder="Token amount"
            />
            <button onClick={stakeToken} disabled={!contract}>Stake Tokens</button>
            <br />
            <input
                type="text"
                value={unstakeTokenAddress}
                onChange={(e) => setUnstakeTokenAddress(e.target.value)}
                placeholder="Token address"
            />
            <input
                type="number"
                value={unstakeTokenAmount}
                onChange={(e) => setUnstakeTokenAmount(e.target.value)}
                placeholder="Token amount to unstake"
            />
            <button onClick={unstakeToken} disabled={!contract}>Unstake Tokens</button>
        </div>
    );
};

export default TokenStaking;
