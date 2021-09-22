pragma solidity ^0.4.2;

import "./ownable.sol";
import "./safemath.sol";
import "./erc721.sol";

contract plantgame is Ownable, ERC721, usingOraclize {

	address public owner;
	address public contractAddress;
	OwnedClone[] public OwnedClones;
	OwnedSeed[] public OwnedSeeds;
	mapping (uint => address) public seedsToOwner;
	mapping (address => uint) public ownerSeedCount;
	mapping (uint => address) public clonesToOwner;
	mapping (address => uint) public ownerCloneCount;
	mapping (uint => address) public seedApprovals;
	mapping (uint => address) public cloneApprovals;
	mapping (address => uint) public availableSpace;
	mapping (address => uint) public usedSpace;
	mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    mapping(address => uint) private newUser;
    string public name = "";
    string public symbol = "";
	uint256 constant MAX_UINT256 = 2**256 - 1;
	uint256 public totalSupply;
	uint8 public decimals = 0;
	uint defaultStatus;
	uint defaultBlock = 999999999999999;
	uint totalGenesisSeeds;
	uint harvestClonability;
    uint harvestBagSeed;
    
    event OwnershipTransferred(
		address indexed previousOwner, 
		address indexed newOwner
	);
	
    event newOwnedSeed(
		uint seedId, 
		string seedName, 
		uint seedStability, 
		uint seedYield, 
		uint seedPotency, 
		uint seedBagAppeal, 
		uint seedFlowerTime, 
		uint seedClonability, 
		uint seedBagSeed
	);
	
    event newOwnedClone(
		uint seedId, 
		string seedName, 
		uint seedStability, 
		uint seedYield, uint 
		seedPotency, 
		uint seedBagAppeal, 
		uint seedFlowerTime, 
		uint seedClonability, 
		uint seedBagSeed
	);
	
    event Transfer(
		address indexed _from, 
		address indexed _to, 
		uint256 _value
	); 
	
    event Approval(
		address indexed _owner, 
		address indexed _spender, 
		uint256 _value
	);
	
    event TransferSeed(
		address indexed _from, 
		address indexed _to, 
		uint256 _tokenId
	);
	
    event ApprovalSeed(
		address indexed _owner, 
		address indexed _approved, 
		uint256 _tokenId
	);
	
    event TransferClone(
		address indexed _from, 
		address indexed _to, 
		uint256 _tokenId
	);
	
    event ApprovalClone(
		address indexed _owner, 
		address indexed _approved, 
		uint256 _tokenId
	);

	struct OwnedSeed {
	    string seedName;
	    uint seedStability;
	    uint seedYield;
	    uint seedPotency;
	    uint seedBagAppeal;
	    uint seedFlowerTime;
	    uint seedClonability;
	    uint seedBagSeed;
	    uint seedStatus;
	    uint seedBlock;
	}
	
	struct OwnedClone {
	    string seedName;
	    uint seedStability;
	    uint seedYield;
	    uint seedPotency;
	    uint seedBagAppeal;
	    uint seedFlowerTime;
	    uint seedClonability;
	    uint seedBagSeed;
	    uint seedStatus;
	    uint seedBlock;
	}
	
	modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyOwnerOfSeed(uint _seedId) {
        require(msg.sender == seedsToOwner[_seedId]);
        _;
    }
    
    modifier onlyOwnerOfClone(uint _cloneId) {
        require(msg.sender == clonesToOwner[_cloneId]);
        _;
    }
	
	modifier polinatePlantConditions (uint _seedId, uint _cloneId) {
        require(
			seedsToOwner[_seedId] == msg.sender && 
			OwnedSeeds[_seedId].seedStatus == 1 && (
				OwnedSeeds[_seedId].seedBlock - 5
			) < block.number
		);
        require(
			clonesToOwner[_cloneId] == msg.sender && 
			OwnedClones[_cloneId].seedStatus == 1 && (
				OwnedClones[_cloneId].seedBlock - 10
			) < block.number
		);
        _;
    }
    
    modifier harvestSeedsConditions (uint _seedId) {
        require(
			seedsToOwner[_seedId] == msg.sender && 
			OwnedSeeds[_seedId].seedStatus == 2 && (
				OwnedSeeds[_seedId].seedBlock
			) <= block.number
		);
        require(
			block.number <= (
				OwnedSeeds[_seedId].seedBlock + 244
			)
		);
        _;
    }
	
	function getSeedsByOwner(address _owner) external view returns(uint[], uint) {
        uint[] memory result = new uint[](ownerSeedCount[_owner]);
        uint counter = 0;
        uint count = ownerSeedCount[_owner];
        for (uint i = 0; i < OwnedSeeds.length; i++) {
			if (seedsToOwner[i] == _owner) {
				result[counter] = i;
			counter++;
			}
        }
        return (result, count);
    }
    
    function getClonesByOwner(address _owner) external view returns(uint[], uint) {
        uint[] memory result = new uint[](ownerCloneCount[_owner]);
        uint counter = 0;
        uint count = ownerCloneCount[_owner];
        for (uint i = 0; i < OwnedClones.length; i++) {
			if (clonesToOwner[i] == _owner) {
				result[counter] = i;
            counter++;
			}
        }
        return (result, count);
    }
    
    function plantgame () public {
        owner = msg.sender;
        contractAddress = this;
        availableSpace[msg.sender] = 10;
    }
    
    function createGenesisSeed (
		string _name, 
		uint _stability, 
		uint _yield, 
		uint _potency, 
		uint _bagAppeal, 
		uint _flowerTime, 
		uint _clonability, 
		uint _bagSeed
		) external onlyOwner {
			require (
				totalGenesisSeeds < 100
			);
			uint id = OwnedSeeds.push(
				OwnedSeed(string(_name), 
				uint(_stability), 
				uint(_yield), 
				uint(_potency), 
				uint(_bagAppeal), 
				uint(_flowerTime), 
				uint(_clonability), 
				uint(_bagSeed), 
				uint(defaultStatus), 
				uint(defaultBlock)
				)
			);
			seedsToOwner[id] = msg.sender;
			ownerSeedCount[msg.sender] += 1;
			emit newOwnedSeed(
				id, 
				string(_name), 
				uint(_stability), 
				uint(_yield), 
				uint(_potency), 
				uint(_bagAppeal), 
				uint(_flowerTime), 
				uint(_clonability), 
				uint(_bagSeed)
			);
			totalGenesisSeeds++;
    }
    
    function plantSeed (uint _seedId) external {
        require (
			seedsToOwner[_seedId] == msg.sender && 
			OwnedSeeds[_seedId].seedStatus == 0 && 
			availableSpace[msg.sender] > usedSpace[msg.sender]
		);
        OwnedSeeds[_seedId].seedStatus = 1;
        OwnedSeeds[_seedId].seedBlock = (
			block.number + (2 + (OwnedSeeds[_seedId].seedFlowerTime * 1))
		);
        usedSpace[msg.sender]++;
    }
    
    function plantClone (uint _cloneId) external {
        require (
			clonesToOwner[_cloneId] == msg.sender && 
			OwnedClones[_cloneId].seedStatus == 0 && 
			availableSpace[msg.sender] > usedSpace[msg.sender]
		);
        require (
			OwnedClones[_cloneId].seedBlock > block.number
		);
        OwnedClones[_cloneId].seedStatus = 1;
        OwnedClones[_cloneId].seedBlock = (
			block.number + (2 + (OwnedClones[_cloneId].seedFlowerTime * 1))
		);
        usedSpace[msg.sender]++;
    }
    
    function harvestSeedPlant (uint _seedId) external {
        require (
			seedsToOwner[_seedId] == msg.sender && 
			OwnedSeeds[_seedId].seedStatus == 1 && (
				OwnedSeeds[_seedId].seedBlock - 5
			) < block.number
		);
        ownerSeedCount[msg.sender] -= 1;
        uint _bagSeed;
        uint i = 0;
        uint tokensIssued;
        if (
			block.number > OwnedSeeds[_seedId].seedBlock && 
			block.number < (OwnedSeeds[_seedId].seedBlock + 100)
		) {
            tokensIssued += (
				OwnedSeeds[_seedId].seedPotency + 
				OwnedSeeds[_seedId].seedBagAppeal * 
				OwnedSeeds[_seedId].seedYield
			);
        } 
		else {
            tokensIssued += ((
				OwnedSeeds[_seedId].seedPotency + 
				OwnedSeeds[_seedId].seedBagAppeal * 
				OwnedSeeds[_seedId].seedYield
			) / 2
			);
        }
        if (
			OwnedSeeds[_seedId].seedBagSeed >= 10 && 
			OwnedSeeds[_seedId].seedBagSeed <= 19
		) {
            _bagSeed = 1;
		}
        if (
			OwnedSeeds[_seedId].seedBagSeed == 20) {
				_bagSeed = 2;
        }
        for (i; i<_bagSeed; i++) {
	        uint id = OwnedSeeds.push(
				OwnedSeed(
					string (OwnedSeeds[_seedId].seedName), 
					uint (OwnedSeeds[_seedId].seedStability), 
					uint(OwnedSeeds[_seedId].seedYield), 
					uint(OwnedSeeds[_seedId].seedPotency), 
					uint(OwnedSeeds[_seedId].seedBagAppeal), 
					uint(OwnedSeeds[_seedId].seedFlowerTime), 
					uint(OwnedSeeds[_seedId].seedClonability), 
					uint(OwnedSeeds[_seedId].seedBagSeed), 
					uint(defaultStatus), 
					uint(defaultBlock)
				)
			);
			seedsToOwner[id] = msg.sender;
            ownerSeedCount[msg.sender] += 1;
            emit newOwnedSeed(
				id, 
				string(OwnedSeeds[_seedId].seedName), 
				uint (OwnedSeeds[_seedId].seedStability), 
				uint(OwnedSeeds[_seedId].seedYield), 
				uint(OwnedSeeds[_seedId].seedPotency), 
				uint(OwnedSeeds[_seedId].seedBagAppeal), 
				uint(OwnedSeeds[_seedId].seedFlowerTime), 
				uint(OwnedSeeds[_seedId].seedClonability), 
				uint(OwnedSeeds[_seedId].seedBagSeed)
			);
        }
        totalSupply += tokensIssued;
        balances[msg.sender] += tokensIssued; 
        Transfer(address(this), msg.sender, tokensIssued);
        seedsToOwner[_seedId] = contractAddress;
    }
    
    function harvestClonePlant (uint _cloneId) external {
        require (
			clonesToOwner[_cloneId] == msg.sender && 
			OwnedClones[_cloneId].seedStatus == 1 && (
					OwnedClones[_cloneId].seedBlock - 5
			) < block.number
		);
		ownerSeedCount[msg.sender] -= 1;
        uint _bagSeed;
        uint i = 0;
        uint tokensIssued;
        if (
			block.number > OwnedClones[_cloneId].seedBlock && 
			block.number < (OwnedClones[_cloneId].seedBlock + 100)
		) {
            tokensIssued += (
				OwnedClones[_cloneId].seedPotency + 
				OwnedClones[_cloneId].seedBagAppeal * 
				OwnedClones[_cloneId].seedYield
			);
        } 
		else {
            tokensIssued += ((
				OwnedClones[_cloneId].seedPotency + 
				OwnedClones[_cloneId].seedBagAppeal * 
				OwnedClones[_cloneId].seedYield
				) / 2
			);
        }
        if (
			OwnedClones[_cloneId].seedBagSeed >= 10 && 
			OwnedClones[_cloneId].seedBagSeed <= 19
		) {
            _bagSeed = 1;
        }
        if (
			OwnedClones[_cloneId].seedBagSeed == 20
		) {
            _bagSeed = 2;
        }
        for (i; i<_bagSeed; i++) {
	        uint id = OwnedSeeds.push(
				OwnedSeed(
					string (
						OwnedClones[_cloneId].seedName), 
						uint (OwnedClones[_cloneId].seedStability), 
						uint(OwnedClones[_cloneId].seedYield), 
						uint(OwnedClones[_cloneId].seedPotency), 
						uint(OwnedClones[_cloneId].seedBagAppeal), 
						uint(OwnedClones[_cloneId].seedFlowerTime), 
						uint(OwnedClones[_cloneId].seedClonability), 
						uint(OwnedClones[_cloneId].seedBagSeed), 
						uint(defaultStatus), uint(defaultBlock)
				)
			);
	        seedsToOwner[id] = msg.sender;
            ownerSeedCount[msg.sender] += 1;
            emit newOwnedSeed(
				id, 
				string(
					OwnedClones[_cloneId].seedName), 
					uint (OwnedClones[_cloneId].seedStability), 
					uint(OwnedClones[_cloneId].seedYield), 
					uint(OwnedClones[_cloneId].seedPotency), 
					uint(OwnedClones[_cloneId].seedBagAppeal), 
					uint(OwnedClones[_cloneId].seedFlowerTime), 
					uint(OwnedClones[_cloneId].seedClonability), 
					uint(OwnedClones[_cloneId].seedBagSeed)
			);
        }
        totalSupply += tokensIssued;
        balances[msg.sender] += tokensIssued; 
        Transfer(address(this), msg.sender, tokensIssued);
        clonesToOwner[_cloneId] = contractAddress;
    }
    
    function cloneSeedPlant (uint _seedId) external {
        require(
			seedsToOwner[_seedId] == msg.sender && 
			OwnedSeeds[_seedId].seedStatus == 1 && (
				OwnedSeeds[_seedId].seedBlock - 10
			) < block.number
		);
        ownerSeedCount[msg.sender] -= 1;
        uint _cloneCount;
        uint i = 0;
        if (
			OwnedSeeds[_seedId].seedClonability >= 1 && 
			OwnedSeeds[_seedId].seedClonability <= 10
		) {
            _cloneCount = 1;
        }
        if (
			OwnedSeeds[_seedId].seedClonability >= 11 && 
			OwnedSeeds[_seedId].seedClonability <= 20
		) {
            _cloneCount = 2;
        }
        if (
			OwnedSeeds[_seedId].seedClonability >= 21 && 
			OwnedSeeds[_seedId].seedClonability <= 30
		) {
            _cloneCount = 3;
        }
        if (
			OwnedSeeds[_seedId].seedClonability >= 31 && 
			OwnedSeeds[_seedId].seedClonability <= 39
		) {
            _cloneCount = 4;
        }
        if (
			OwnedSeeds[_seedId].seedClonability == 40
		) {
            _cloneCount = 5;
        }
        for (i; i<_cloneCount; i++) {
	            uint id = OwnedClones.push(
					OwnedClone(
						string (OwnedSeeds[_seedId].seedName), 
						uint (OwnedSeeds[_seedId].seedStability), 
						uint(OwnedSeeds[_seedId].seedYield), 
						uint(OwnedSeeds[_seedId].seedPotency), 
						uint(OwnedSeeds[_seedId].seedBagAppeal), 
						uint(OwnedSeeds[_seedId].seedFlowerTime), 
						uint(OwnedSeeds[_seedId].seedClonability), 
						uint(OwnedSeeds[_seedId].seedBagSeed), 
						uint(defaultStatus), 
						uint(block.number + 40000)
					)
				);
	            clonesToOwner[id] = msg.sender;
	            ownerCloneCount[msg.sender] += 1;
                emit newOwnedClone(
					id, 
					string(OwnedSeeds[_seedId].seedName), 
					uint (OwnedSeeds[_seedId].seedStability), 
					uint(OwnedSeeds[_seedId].seedYield), 
					uint(OwnedSeeds[_seedId].seedPotency), 
					uint(OwnedSeeds[_seedId].seedBagAppeal), 
					uint(OwnedSeeds[_seedId].seedFlowerTime), 
					uint(OwnedSeeds[_seedId].seedClonability), 
					uint(OwnedSeeds[_seedId].seedBagSeed)
				);
        }
        seedsToOwner[_seedId] = contractAddress;
    }
    
    function cloneClonePlant (uint _cloneId) external {
        require (
			clonesToOwner[_cloneId] == msg.sender && 
			OwnedClones[_cloneId].seedStatus == 1 && (
				OwnedClones[_cloneId].seedBlock - 10
			) < block.number
		);
        ownerSeedCount[msg.sender] -= 1;
        uint _cloneCount;
        uint i = 0;
        OwnedClones[_cloneId].seedStability--;
        OwnedClones[_cloneId].seedClonability--;
        uint _stability = (
			OwnedClones[_cloneId].seedStability - 1
		);
        uint _clonability = (
			OwnedClones[_cloneId].seedClonability - 1
		);
        if (
			OwnedClones[_cloneId].seedClonability >= 1 && 
			OwnedClones[_cloneId].seedClonability <= 10
		) {
            _cloneCount = 1;
        }
        if (
			OwnedClones[_cloneId].seedClonability >= 11 && 
			OwnedClones[_cloneId].seedClonability <= 20
		) {
            _cloneCount = 2;
        }
        if (
			OwnedClones[_cloneId].seedClonability >= 21 && 
			OwnedClones[_cloneId].seedClonability <= 30
		) {
            _cloneCount = 3;
        }
        for (i; i<_cloneCount; i++) {
	            uint id = OwnedClones.push(
					OwnedClone(
						string (
							OwnedSeeds[_cloneId].seedName
						), 
						_stability, 
						uint(OwnedSeeds[_cloneId].seedYield), 
						uint(OwnedSeeds[_cloneId].seedPotency), 
						uint(OwnedSeeds[_cloneId].seedBagAppeal), 
						uint(OwnedSeeds[_cloneId].seedFlowerTime), 
						_clonability, 
						uint(OwnedSeeds[_cloneId].seedBagSeed), 
						uint(defaultStatus), 
						uint(block.number + 40000)
					)
				);
	            clonesToOwner[id] = msg.sender;
	            ownerCloneCount[msg.sender] += 1;
                emit newOwnedClone(
					id, 
					string(OwnedSeeds[_cloneId].seedName), 
					_stability, 
					uint(OwnedSeeds[_cloneId].seedYield), 
					uint(OwnedSeeds[_cloneId].seedPotency), 
					uint(OwnedSeeds[_cloneId].seedBagAppeal), 
					uint(OwnedSeeds[_cloneId].seedFlowerTime), 
					_clonability, 
					uint(OwnedSeeds[_cloneId].seedBagSeed)
				);
        }
        clonesToOwner[_cloneId] = contractAddress;
    }
    
    function polinatePlant (uint _seedId, uint _cloneId) external polinatePlantConditions(_seedId, _cloneId) {
        OwnedSeeds[_seedId].seedStatus = 2;
        OwnedSeeds[_seedId].seedBlock = (block.number + 10);
        clonesToOwner[_cloneId] = contractAddress;
        
    }
    
    function harvestSeeds (uint _seedId, string _name) external harvestSeedsConditions(_seedId) {
        ownerSeedCount[msg.sender] -= 1;
        ownerCloneCount[msg.sender] -= 1;
        uint i = 0;
        uint _harvestStability;
        uint _harvestYield;
        uint _harvestPotency;
        uint _harvestBagAppeal;
        uint _harvestFlowerTime;
        for (i; i<3; i++) {
			_harvestStability = uint(
				block.blockhash(
					OwnedSeeds[_seedId].seedBlock - 1
				)
			) % 10 + 1;
        if (_harvestStability <= 5) {
            _harvestStability = OwnedSeeds[_seedId].seedStability--;
        }
        if (_harvestStability >= 6) {
            _harvestStability = OwnedSeeds[_seedId].seedStability++;
        }
        if (_harvestStability > 20) {
            _harvestStability = 20;
        }
        _harvestYield = uint(
			block.blockhash(
				OwnedSeeds[_seedId].seedBlock - 2
			)
		) % 10 + 1;
        if (_harvestYield <= 5) {
            _harvestYield = OwnedSeeds[_seedId].seedYield--;
        }
        if (_harvestYield >= 6) {
            _harvestYield = OwnedSeeds[_seedId].seedYield++;
        }
        if (_harvestYield > 10) {
            _harvestYield = 10;
        }
        _harvestPotency = uint(
			block.blockhash(
				OwnedSeeds[_seedId].seedBlock - 3
			)
		) % 10 + 1;
        if (_harvestPotency <= 5) {
            _harvestPotency = OwnedSeeds[_seedId].seedPotency--;
        }
        if (_harvestPotency >= 6) {
            _harvestPotency = OwnedSeeds[_seedId].seedPotency++;
        }
        if (_harvestPotency > 20) {
            _harvestPotency = 20;
        }
        _harvestBagAppeal = uint(
			block.blockhash(
				OwnedSeeds[_seedId].seedBlock - 4
			)
		) % 10 + 1;
        if (_harvestBagAppeal <= 5) {
            _harvestBagAppeal = OwnedSeeds[_seedId].seedBagAppeal--;
        }
        if (_harvestBagAppeal >= 6) {
            _harvestBagAppeal = OwnedSeeds[_seedId].seedBagAppeal++;
        }
        if (_harvestBagAppeal > 20) {
            _harvestBagAppeal = 20;
        }
        _harvestFlowerTime = uint(
			block.blockhash(
				OwnedSeeds[_seedId].seedBlock - 5
			)
		) % 10 + 1;
        if (_harvestFlowerTime <= 5) {
            _harvestFlowerTime = OwnedSeeds[_seedId].seedFlowerTime--;
        }
        if (_harvestFlowerTime >= 6) {
            _harvestFlowerTime = OwnedSeeds[_seedId].seedFlowerTime++;
        }
        if (_harvestFlowerTime > 25) {
            _harvestFlowerTime = 25;
        }
        harvestClonability = uint(
			block.blockhash(
				OwnedSeeds[_seedId].seedBlock - 6
			)
		) % 10 + 1;
        if (harvestClonability <= 5) {
            harvestClonability = OwnedSeeds[_seedId].seedClonability--;
        }
        if (harvestClonability >= 6) {
            harvestClonability = OwnedSeeds[_seedId].seedClonability++;
        }
        if (harvestClonability > 40) {
            harvestClonability = 40;
        }
        harvestBagSeed = uint(
			block.blockhash(
				OwnedSeeds[_seedId].seedBlock - 7
			)
		) % 10 + 1;
        if (harvestBagSeed <= 5) {
            harvestBagSeed = OwnedSeeds[_seedId].seedBagSeed--;
        }
        if (harvestBagSeed >= 6) {
            harvestBagSeed = OwnedSeeds[_seedId].seedBagSeed++;
        }
        if (harvestBagSeed > 20) {
            harvestBagSeed = 20;
        }
	            uint id = OwnedSeeds.push(
					OwnedSeed(
						_name, 
						_harvestStability, 
						_harvestYield, 
						_harvestPotency, 
						_harvestBagAppeal, 
						_harvestFlowerTime, 
						harvestClonability, 
						harvestBagSeed, 
						defaultStatus, 
						defaultBlock
					)
				);
	            seedsToOwner[id] = msg.sender;
	            ownerSeedCount[msg.sender] += 1;
                emit newOwnedSeed(
					id, 
					_name, 
					_harvestStability, 
					_harvestYield, 
					_harvestPotency, 
					_harvestBagAppeal, 
					_harvestFlowerTime, 
					harvestClonability, 
					harvestBagSeed
				);
        }
        seedsToOwner[_seedId] = contractAddress;
    }
    
    function ownerOfSeed(uint256 _seedId) public view returns (address _owner) {
        return seedsToOwner[_seedId];
    }
    
    function ownerOfClone(uint256 _cloneId) public view returns (address _owner) {
        return clonesToOwner[_cloneId];
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    function withdraw() external onlyOwner {
	    owner.transfer(this.balance);
	}
	
	function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }   
    
    function balanceOfSeeds(address _owner) public view returns (uint256) {
        return uint256(ownerSeedCount[_owner]);
    }
    
    function _transferSeed(address _from, address _to, uint256 _seedId) private {
        ownerSeedCount[_to] = ownerSeedCount[_to]++;
        ownerSeedCount[msg.sender] = ownerSeedCount[msg.sender]--;
        seedsToOwner[_seedId] = _to;
        emit TransferSeed(_from, _to, _seedId);
    }
    
    function transferSeed(address _to, uint256 _seedId) public onlyOwnerOfSeed(_seedId) {
        _transferSeed(msg.sender, _to, _seedId);
    }
    
    function approveSeed(address _to, uint256 _seedId) public onlyOwnerOfSeed(_seedId) {
        seedApprovals[_seedId] = _to;
        emit ApprovalSeed(msg.sender, _to, _seedId);
    }
    
    function takeSeedOwnership(uint256 _seedId) public {
        require(seedApprovals[_seedId] == msg.sender);
        address _owner = ownerOfSeed(_seedId);
        _transferSeed(_owner, msg.sender, _seedId);
    }
    
    function balanceOfClones(address _owner) public view returns (uint256) {
        return uint256(ownerCloneCount[_owner]);
    }
    
    function _transferClone(address _from, address _to, uint256 _cloneId) private {
        ownerCloneCount[_to] = ownerCloneCount[_to]++;
        ownerCloneCount[msg.sender] = ownerCloneCount[msg.sender]--;
        clonesToOwner[_cloneId] = _to;
        emit TransferClone(_from, _to, _cloneId);
    }
    
    function transferClone(address _to, uint256 _cloneId) public onlyOwnerOfClone(_cloneId) {
        _transferClone(msg.sender, _to, _cloneId);
    }
    
    function approveClone(address _to, uint256 _cloneId) public onlyOwnerOfClone(_cloneId) {
        cloneApprovals[_cloneId] = _to;
        emit ApprovalClone(msg.sender, _to, _cloneId);
    }
    
    function takeCloneOwnership(uint256 _cloneId) public {
        require(cloneApprovals[_cloneId] == msg.sender);
        address _owner = ownerOfClone(_cloneId);
        _transferClone(_owner, msg.sender, _cloneId);
    }
}