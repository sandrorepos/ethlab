import React, { useState } from 'react';
import { ethers } from 'ethers'; // Importe ethers

const EthStaking = ({ contract }) => {
    const [ethAmount, setEthAmount] = useState('');
    const [unstakeEthAmount, setUnstakeEthAmount] = useState('');

    const stakeEth = async () => {
        try {
            const tx = await contract.stakeETH({ value: ethers.parseEther(ethAmount) });
            await tx.wait();
            alert('ETH staked successfully!');
        } catch (error) {
            console.error(error);
            alert('Error staking ETH');
        }
    };

    const unstakeEth = async () => {
        try {
            const tx = await contract.unstakeETH(ethers.parseEther(unstakeEthAmount));
            await tx.wait();
            alert('ETH unstaked successfully!');
        } catch (error) {
            console.error(error);
            alert('Error unstaking ETH');
        }
    };

    return (
        <div className="section">
            <h2>ETH Staking</h2>
            <input
                type="number"
                value={ethAmount}
                onChange={(e) => setEthAmount(e.target.value)}
                placeholder="ETH amount"
                step="0.001"
            />
            <button onClick={stakeEth} disabled={!contract}>Stake ETH</button>
            <br />
            <input
                type="number"
                value={unstakeEthAmount}
                onChange={(e) => setUnstakeEthAmount(e.target.value)}
                placeholder="ETH amount to unstake"
                step="0.001"
            />
            <button onClick={unstakeEth} disabled={!contract}>Unstake ETH</button>
        </div>
    );
};

export default EthStaking;
