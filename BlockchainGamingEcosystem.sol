// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGamingEcosystemNFT {
    function mintNFT(address to) external;
    function burnNFT(uint256 tokenId) external;
    function transferNFT(uint256 tokenId, address from, address to) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract BlockchainGamingEcosystem {

    address private deployer;
    IGamingEcosystemNFT public nftContract;
    uint256 private tokenId;
    string[] private userNames;
    string[] private gameNames;

    struct Game {
        string name;
        uint256 gameID;
        uint256 assetPrice;
        uint256 assetCounter;
        uint256[] assetIds;
    }

    struct Player {
        string name;
        address addr;
        uint256 balance;
        uint256[] ownNFTs;
        uint256 nftnum;
    }

    struct Asset {
        uint256 tokenId;
        uint256 gameId;
        string gameName;
        uint256 price;
    }

    mapping(uint256 => Game) private games;
    mapping(address => Player) private players;
    mapping(uint256 => Asset) private assets;

    constructor(address _nftAddress) {
        deployer = msg.sender;
        tokenId = 0;
        nftContract = IGamingEcosystemNFT(_nftAddress);
    }

    // Function to register as a player
    function registerPlayer(string calldata userName) public {
        require(msg.sender != deployer,"Owner cannot access");
        require(bytes(userName).length > 2 ,"Length minimum 3");
        require(players[msg.sender].balance == 0, "Player already exists");
        require(!isUserNameTaken(userName), "Player name already exists");
        players[msg.sender] = Player(userName,msg.sender,1000,new uint256[](0),0);
        userNames.push(userName);
    }

    function isUserNameTaken(string calldata userName) private view returns (bool) {
        for (uint i = 0; i < userNames.length; i++) {
            if (keccak256(abi.encodePacked(userNames[i])) == keccak256(abi.encodePacked(userName))) {
                return true;
            }
        }
        return false;
    }

    // Function to create a new game
    function createGame(string calldata gameName, uint256 gameID) public {
        require(msg.sender == deployer, "Only by Owner");
        require(games[gameID].assetPrice == 0, "Game already exists");
        require(!isGameNameTaken(gameName), "Game name already exists");
        games[gameID] = Game(gameName,gameID,250,0,new uint256[](0));
        gameNames.push(gameName);
    }

    function isGameNameTaken(string calldata gameName) private view returns (bool) {
        for (uint i = 0; i < gameNames.length; i++) {
            if (keccak256(abi.encodePacked(gameNames[i])) == keccak256(abi.encodePacked(gameName))) {
                return true;
            }
        }
        return false;
    }
    
    // Function to remove a game from the ecosystem
    function removeGame(uint256 gameID) public {
        require(msg.sender == deployer, "Only by Owner");
        require(games[gameID].assetPrice != 0,"Game doesn't exist");
        Game storage gm = games[gameID];
        for(uint i = 0;i<gm.assetIds.length;i++){
            Player storage ownr = players[nftContract.ownerOf(gm.assetIds[i])];
            if(ownr.addr != address(0)){
               ownr.balance += assets[gm.assetIds[i]].price;
               ownr.nftnum -= 1;
               nftContract.burnNFT(gm.assetIds[i]);
            }  
        }
        delete games[gameID];
    }
    
    // Function to allow players to buy an NFT asset
    function buyAsset(uint256 gameID) public {
        require(deployer != msg.sender,"Deployer cannot buy");
        require(players[msg.sender].balance != 0,"Player doesn't exist");
        Game storage gm = games[gameID];
        require(gm.gameID != 0, "Game not found.");
        require(gm.assetPrice <= players[msg.sender].balance,"Insufficient balance");
        nftContract.mintNFT(msg.sender);
        players[msg.sender].balance -= gm.assetPrice;
        players[msg.sender].ownNFTs.push(tokenId);
        players[msg.sender].nftnum +=1;
        gm.assetIds.push(tokenId);
        assets[tokenId] = Asset(tokenId,gameID,gm.name,gm.assetPrice);
        tokenId += 1;
        gm.assetCounter += 1;
        gm.assetPrice += (gm.assetPrice/10);
    }

	// Function to allow players to sell owned assets
    function sellAsset(uint256 tokenID) public {
        require(deployer != msg.sender,"Deployer cannot buy");
        require(nftContract.ownerOf(tokenID) == msg.sender, "You don't own this asset.");
        Player storage plyr = players[nftContract.ownerOf(tokenID)];
        nftContract.burnNFT(tokenID);
        Game storage gm = games[assets[tokenID].gameId];
        plyr.balance += gm.assetPrice;
        for(uint i=0;i<gm.assetIds.length ;i++){
           if(gm.assetIds[i] == tokenID){
               uint256 temp = gm.assetIds[i];
               gm.assetIds[i]= gm.assetIds[gm.assetIds.length-1];
               gm.assetIds[gm.assetIds.length-1] = temp;
               gm.assetIds.pop();
           }
        }
        plyr.nftnum -= 1;
        for(uint i=0;i<plyr.ownNFTs.length ;i++){
           if(plyr.ownNFTs[i] == tokenID){
               delete plyr.ownNFTs[i];
           }
        }
        delete assets[tokenID];
    }


    // Function to transfer asset to a different player
    function transferAsset(uint256 tokenID, address to) public {
        require(deployer != msg.sender,"Deployer cannot buy");
        require(deployer != to,"Deployer cannot be sender");
        require(nftContract.ownerOf(tokenID) == msg.sender, "You don't own this asset.");
        require(players[to].balance != 0,"Player doesn't exist");
        nftContract.transferNFT(tokenID, msg.sender, to);
        Player storage plyr = players[msg.sender];
        for(uint i=0;i<plyr.ownNFTs.length ;i++){
           if(plyr.ownNFTs[i] == tokenID){
               delete plyr.ownNFTs[i];
           }
        }
        plyr.nftnum -= 1;
        players[to].nftnum += 1;
        players[to].ownNFTs.push(tokenID);
    }

    // Function to view a player's profile
    function viewProfile(address playerAddress) public view returns (string memory userName, uint256 balance, uint256 numberOfNFTs) {
        require(playerAddress != deployer,"Deployer profile cannot be viewed");
        if(msg.sender != deployer){
           require(keccak256(abi.encodePacked(players[msg.sender].name)) != keccak256(abi.encodePacked("")),"Player doesn't exist");
        }
        Player memory pler = players[playerAddress];
       return (pler.name,pler.balance,pler.nftnum);
    }

    // Function to view Asset owner and the associated game
    function viewAsset(uint256 tokenID) public view returns (address owner, string memory gameName, uint price) {
        if(msg.sender != deployer){
           require(keccak256(abi.encodePacked(players[msg.sender].name)) != keccak256(abi.encodePacked("")),"Player doesn't exist");
        }
        owner = nftContract.ownerOf(tokenID);
        Asset memory ast = assets[tokenID];
        return (owner,ast.gameName,ast.price);
    }

}