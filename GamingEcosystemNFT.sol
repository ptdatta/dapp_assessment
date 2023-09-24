// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GamingEcosystemNFT is ERC721, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("GamingNFT", "BGE") {}

    function mintNFT(address to) external  {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _approve(msg.sender, tokenId);
    }

    function burnNFT(uint256 tokenId) external  {
        burn(tokenId);
    }

    function transferNFT(uint256 tokenId, address from, address to) external {
        safeTransferFrom(from, to, tokenId);
        _approve(msg.sender, tokenId);
    }
}