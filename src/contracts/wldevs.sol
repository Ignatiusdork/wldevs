// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract WlDevs is ERC721Enumerable, Ownable {

    /**
      * @dev _baseTokenURI for computing {tokenURI}. If set, the resulting URI for each
      * token will be the concatenation of the `baseURI` and the `tokenId`.
    */

    string _baseTokenURI;

    //price is the price of one wldev NFT

    uint256 public _price = 0.01 ether;

    bool public _paused;

    uint256 public maxTokenIds = 10;

    uint256 public tokenIds;

    IWhitelist whitelist;

    bool public presaleStarted;

    uint256 public presaleEnded;

    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }

    /**
      * @dev ERC721 constructor takes in a `name` and a `symbol` to the token collection.
      * name in our case is `Crypto Devs` and symbol is `CD`.
      * Constructor for Crypto Devs takes in the baseURI to set _baseTokenURI for the collection.
      * It also initializes an instance of whitelist interface.
      */

    constructor (string memory baseURI, address whitelistContract) ERC721("Wl Devs", "WD") {
    
        _baseTokenURI = baseURI;

        whitelist = IWhitelist(whitelistContract);
    }

    function startPresale() public onlyOwner{
        presaleStarted = true;

        presaleEnded = block.timestamp + 5 minutes;
    }


    /**
      * @dev presaleMint allows a user to mint one NFT per transaction during the presale.
      */

     function presaleMint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
        require(tokenIds < maxTokenIds, "Exceeded maximum Wl Devs supply");
        require(msg.value >= _price, "Ether sent not correct");
        tokenIds += 1;
        //_safeMint is a safer version of the _mint function as it ensures that
        // if the address being minted to is a contract, then it knows how to deal with ERC721 tokens
        // If the address being minted to is not a contract, it works the same way as _mint
        _safeMint(msg.sender, tokenIds);
    }

    /**
    * @dev mint allows a user to mint 1 NFT per transaction after the presale has ended.
    */

   function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >= presaleEnded, "Presae still on going");
        require(tokenIds < maxTokenIds, "Exceed maximum WL Devs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
   }

       /**
    * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
    * returned an empty string for the baseURI
    */

   function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
   }

       /**
    * @dev setPaused makes the contract paused or unpaused
      */

    function setPaused(bool val) public onlyOwner{
        _paused = val;
    }

        /**
    * @dev withdraw sends all the ether in the contract
    * to the owner of the contract
      */

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send ether");
    }


    // Functions to receive Ether. msg.data be empty


    receive() external payable {}

    fallback() external payable{}

}