// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract my_nft is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private tokenIdCounter;

    // NFT 元数据 URI 存储
    mapping(uint256 => string) private tokenURIs;

    // NFT 信息
    string public baseURI;

    // 事件
    event NFTMinted(
        address indexed to,
        uint256 indexed tokenId,
        string metadataURI
    );

    //编写中遇到的问题总结
    //如果父合约有构造函数且包含参数，子合约必须在自己的构造函数中显式调用父合约的构造函数来初始化父合约的状态变量。
    constructor(
        string memory name,
        string memory symbol,
        string memory _baseURI
    )
        ERC721(name, symbol)  // 传入 ERC721 的参数
        Ownable(msg.sender)   // 传入 Ownable 的参数（部署者为所有者）
    {
        baseURI = _baseURI;
    }

    // 铸造 NFT 函数
    function mintNFT(
        address recipient,
        string memory metadataURI
    ) public onlyOwner returns (uint256) {
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();

        _safeMint(recipient, tokenId);
        tokenURIs[tokenId] = metadataURI;

        emit NFTMinted(recipient, tokenId, metadataURI);
        return tokenId;
    }

    // 获取 tokenURI
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "Token does not exist");
        // require(_owners(tokenId), "Token does not exist");
        return tokenURIs[tokenId];
    }

    // 查询 NFT 总数
    function getTotalSupply() public view returns (uint256) {
        return tokenIdCounter.current();
    }

}
