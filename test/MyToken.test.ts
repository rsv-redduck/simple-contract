import { anyValue } from '@nomicfoundation/hardhat-chai-matchers/withArgs';
import { time, loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';
import { ethers } from 'hardhat';

describe('MyToken', function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployMyTokenFixture() {
    // Contracts are deployed using the first signer/account by default
    const name = 'MyTonek';
    const symbol = 'MTNT';
    const decimals = 2;
    const initialSupply = 1000;
    const initialPrice = ethers.utils.parseEther('1');

    const MyToken = await ethers.getContractFactory('MyToken');
    const myToken = await MyToken.deploy(
      name,
      symbol,
      decimals,
      initialSupply,
      initialPrice,
    );

    return { myToken, initialSupply, initialPrice };
  }

  describe('Deployment', function () {
    it('Should set the right token amount', async function () {
      const { myToken, initialSupply } = await loadFixture(
        deployMyTokenFixture,
      );

      expect(await myToken.totalSupply()).to.equal(initialSupply);
    });
    it('Should set the right token price', async function () {
      const { myToken, initialPrice } = await loadFixture(deployMyTokenFixture);

      expect(await myToken.price()).to.equal(initialPrice);
    });
  });
});
