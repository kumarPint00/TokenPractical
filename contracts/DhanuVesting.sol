//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Dhanu is Ownable {
    string public name;
    string public symbol;
    uint256 public decimals;
    bool mintAllowed = true;
    uint256 public totalSupply;
    uint256 decimalfactor;
    uint256 public Max_Dhanu;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    constructor() {
        symbol = "DHANU";
        name = "Dhanu";
        decimals = 18;
        decimalfactor = 10**uint256(decimals);
        Max_Dhanu = 500_000_000 * decimalfactor;

        // mint(
        //     0xFde0C3CBA0426EA642Cb9552893A5ceC33Ee7948,
        //     23_000_000 * decimalfactor
        // ); //IO
        // mint(
        //     0xd060bc66A9636851C930320D6DE32Bb1e2022dca,
        //     36_000_000 * decimalfactor
        // ); //future IO
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        require(_to != address(0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "Allowance error");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    function mint(address _to, uint256 _value) public returns (bool success) {
        require(Max_Dhanu >= (totalSupply + _value));
        require(mintAllowed, "Max supply reached");
        if (Max_Dhanu == (totalSupply + _value)) {
            mintAllowed = false;
        }
        require(msg.sender == owner, "Only Owner Can Mint");
        balanceOf[_to] += _value;
        totalSupply += _value;
        require(balanceOf[_to] >= _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }
}

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(
            _initializing || _isConstructor() || !_initialized,
            "Initializable: contract is already initialized"
        );

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}


contract DhanuVesting is Dhanu, Initializable {
    struct VestType {
        uint256 indexId;
        uint256 lockPeriod;
        uint256 vestingDuration;
        uint256 tgePercent;
        uint256 monthlyPercent;
        uint256 totalTokenAllocation;
    }

    struct VestAllocation {
        uint256 vestIndexID;
        uint256 totalTokensAllocated;
        uint256 totalTGETokens;
        uint256 monthlyTokens;
        uint256 vestingDuration;
        uint256 lockPeriod;
        uint256 totalVestTokensClaimed;
        bool isVesting;
        bool isTgeTokensClaimed;
        uint256 startTime;
    }

    // Dhanu Distribution
    uint256 public TeamPercent = 154;
    uint256 public PublicCommunityPercent = 297;
    uint256 public EcosystemPercent = 100;
    uint256 public LiquidityPercent = 82;
    uint256 public InvestorPercent = 136;
    uint256 public InfrastructurePercent = 46;
    uint256 public AirDropPercent = 21;
    uint256 public ReservedPercent = 46;
    uint256 public PrivateICOPercent = 118;

    // Dhanu reserve funds
    address public Team;
    address public PrivateICO;
    address public PublicCommunity;
    address public Ecosystem;
    address public Liquidity;
    address public Investor;
    address public Infrastructure;
    address public AirDrop;
    address public Reserved;

    //

    // Dhanu time lock
    uint256 public TeamTimeLock = 86400 * 365; // 1 year
    uint256 public PrivateICOTimeLock = 86400 * 90; // 3 month
    uint256 public PublicCommunityTimeLock;
    uint256 public EcosystemTimeLock;
    uint256 public LiquidityTimeLock = 86400 * 90; // 3 months
    uint256 public InvestorTimeLock;
    uint256 public InfrastructureTimeLock;
    uint256 public AirDropTimeLock;
    uint256 public ReservedTimeLock;

    //VestingCreated

    uint256 public TeamVesting = 86400 * 1460; // 4 year
    uint256 public PrivateICOVesting = 86400 * 365; // 1 year
    uint256 public PublicCommunityVesting = 86400 * 510; // 17 months
    uint256 public EcosystemVesting = 86400 * 180; // 6 months
    uint256 public LiquidityVesting = 86400 * 365; // 12 months
    uint256 public InvestorVesting = 86400; //  1 day
    uint256 public InfrastructureVesting = 86400 * 1460; // 4 year
    uint256 public AirDropVesting = 86400 * 365; // 1 year
    uint256 public ReservedVesting = 86400 * 1460; // 4 year
    mapping(address => mapping(uint256 => VestAllocation))
        public walletToVestAllocations;

    mapping(uint256 => VestType) public vestTypes;

    modifier onlyValidVestingBenifciary(
        address _userAddresses,
        uint256 _vestingIndex
    ) {
        require(
            _vestingIndex >= 0 && _vestingIndex <= 8,
            "Invalid Vesting Index"
        );
        require(_userAddresses != address(0), "Invalid Address");
        require(
            !walletToVestAllocations[_userAddresses][_vestingIndex].isVesting,
            "User Vesting Details Already Added to this Category"
        );
        _;
    }

    modifier checkVestingStatus(address _userAddresses, uint256 _vestingIndex) {
        require(
            walletToVestAllocations[_userAddresses][_vestingIndex].isVesting,
            "User NOT added to any Vesting Category"
        );
        _;
    }

    modifier onlyAfterTGE() {
        require(
            getCurrentTime() > getTgeTIME(),
            "Token Generation Event Not Started Yet"
        );
        _;
    }

    function getCurrentTime() public view returns (uint256) {
        return block.timestamp;
    }

    function daysInSeconds() internal pure returns (uint256) {
        return 86400;
    }

    function monthInSeconds() internal pure returns (uint256) {
        return 2592000;
    }

    function getTgeTIME() public pure returns (uint256) {
        return 1646479800; // Saturday, March 5, 2022 5:00:00 PM GMT+05:30
    }

    function Percentage(uint256 _totalAmount, uint256 _rate)
        public
        pure
        returns (uint256)
    {
        return (_totalAmount * (_rate)) / (100);
    }


    function initialize() public initializer {
        vestTypes[0] = VestType(
            0,
            TeamTimeLock,
            TeamVesting,
            154,
            0,
            (totalSupply * 154) / 1000
        );

        vestTypes[1] = VestType(
            1,
            PrivateICOTimeLock,
            PrivateICOVesting,
            118,
            0,
            (totalSupply * 118) / 1000
        );

        vestTypes[2] = VestType(
            2,
            PublicCommunityTimeLock,
            PublicCommunityVesting,
            297,
            0,
            (totalSupply * 297) / 1000
        );

        vestTypes[3] = VestType(
            3,
            EcosystemTimeLock,
            EcosystemVesting,
            100,
            10,
            (totalSupply * 100) / 1000
        );

        vestTypes[4] = VestType(
            4,
            LiquidityTimeLock,
            LiquidityVesting,
            82,
            0,
            (totalSupply * 82) / 1000
        );

        vestTypes[5] = VestType(
            5,
            InvestorTimeLock,
            InvestorVesting,
            136,
            0,
            (totalSupply * 136) / 1000
        );

        vestTypes[6] = VestType(
            6,
            InfrastructureTimeLock,
            InfrastructureVesting,
            136,
            0,
            (totalSupply * 136) / 1000
        );

        vestTypes[6] = VestType(
            6,
            AirDropTimeLock,
            AirDropVesting,
            21,
            0,
            (totalSupply * 21) / 1000
        );

        vestTypes[7] = VestType(
            7,
            ReservedTimeLock,
            ReservedVesting,
            46,
            0,
            (totalSupply * 46) / 1000
        );
    }

    function addVestingDetails(
        address[] calldata _userAddresses,
        uint256[] calldata _vestingAmounts,
        uint256 _vestnigType
    ) external onlyOwner returns (bool) {
        require(
            _userAddresses.length == _vestingAmounts.length,
            "Unequal arrays passed"
        );

        VestType memory vestData = vestTypes[_vestnigType];
        uint256 arrayLength = _userAddresses.length;

        for (uint256 i = 0; i < arrayLength; i++) {
            uint256 vestIndexID = _vestnigType;
            address userAddress = _userAddresses[i];
            uint256 totalAllocation = _vestingAmounts[i];
            uint256 lockPeriod = vestData.lockPeriod;
            uint256 vestingDuration = vestData.vestingDuration;
            uint256 tgeAmount = Percentage(
                totalAllocation,
                vestData.tgePercent
            );
            uint256 monthlyAmount = Percentage(
                totalAllocation,
                vestData.monthlyPercent
            );

            addUserVestingDetails(
                userAddress,
                vestIndexID,
                totalAllocation,
                lockPeriod,
                vestingDuration,
                tgeAmount,
                monthlyAmount
            );
        }
        return true;
    }

    function addUserVestingDetails(
        address _userAddresses,
        uint256 _vestingIndex,
        uint256 _totalAllocation,
        uint256 _lockPeriod,
        uint256 _vestingDuration,
        uint256 _tgeAmount,
        uint256 _monthlyAmount
    ) public onlyValidVestingBenifciary(_userAddresses, _vestingIndex) {
        VestAllocation memory userVestingData = VestAllocation(
            _vestingIndex,
            _totalAllocation,
            _tgeAmount,
            _monthlyAmount,
            _vestingDuration,
            _lockPeriod,
            0,
            true,
            false,
            block.timestamp
        );
        walletToVestAllocations[_userAddresses][
            _vestingIndex
        ] = userVestingData;
    }

    function totalTokensClaimed(address _userAddresses, uint8 _vestingIndex)
        public
        view
        returns (uint256)
    {
        // Get Vesting Details
        uint256 totalClaimedTokens;
        VestAllocation memory vestData = walletToVestAllocations[
            _userAddresses
        ][_vestingIndex];

        totalClaimedTokens =
            totalClaimedTokens +
            (vestData.totalVestTokensClaimed);

        if (vestData.isTgeTokensClaimed) {
            totalClaimedTokens = totalClaimedTokens + (vestData.totalTGETokens);
        }

        return totalClaimedTokens;
    }

    function calculateClaimableTokens(
        address _userAddresses,
        uint8 _vestingIndex
    )
        public
        view
        checkVestingStatus(_userAddresses, _vestingIndex)
        returns (uint256)
    {
        // Get Vesting Details
        VestAllocation memory vestData = walletToVestAllocations[
            _userAddresses
        ][_vestingIndex];

        // Get Time Details
        uint256 actualClaimableAmount;
        uint256 tokensAfterElapsedMonths;
        uint256 vestStartTime = vestData.startTime;
        uint256 currentTime = getCurrentTime();
        uint256 timeElapsed = currentTime - (vestStartTime);

        uint256 totalMonthsElapsed = timeElapsed / (monthInSeconds());
        uint256 totalDaysElapsed = timeElapsed / (daysInSeconds());
        uint256 partialDaysElapsed = totalDaysElapsed % (30);

        if (partialDaysElapsed > 0 && totalMonthsElapsed > 0) {
            totalMonthsElapsed += 1;
        }
        require(
            totalMonthsElapsed > vestData.lockPeriod,
            "Vesting Cliff Not Crossed Yet"
        );

        if (totalMonthsElapsed > vestData.vestingDuration) {
            uint256 _totalTokensClaimed = totalTokensClaimed(
                _userAddresses,
                _vestingIndex
            );
            actualClaimableAmount =
                vestData.totalTokensAllocated -
                (_totalTokensClaimed);
        } else {
            uint256 actualMonthElapsed = totalMonthsElapsed -
                (vestData.lockPeriod);
            require(actualMonthElapsed > 0, "Number of months elapsed is ZERO");
            // Calculate the Total Tokens on the basis of Vesting Index and Month elapsed
            if (vestData.vestIndexID == 9) {
                uint256[4] memory monthsToRates;
                monthsToRates[1] = 20;
                monthsToRates[2] = 50;
                monthsToRates[3] = 80;
                tokensAfterElapsedMonths = Percentage(
                    vestData.totalTokensAllocated,
                    monthsToRates[actualMonthElapsed]
                );
            } else {
                tokensAfterElapsedMonths =
                    vestData.monthlyTokens *
                    (actualMonthElapsed);
            }
            require(
                tokensAfterElapsedMonths > vestData.totalVestTokensClaimed,
                "No Claimable Tokens at this Time"
            );
            // Get the actual Claimable Tokens
            actualClaimableAmount =
                tokensAfterElapsedMonths -
                (vestData.totalVestTokensClaimed);
        }
        return actualClaimableAmount;
    }

    function _sendTokens(address _beneficiary, uint256 _amountOfTokens)
        private
        returns (bool)
    {
        _transfer(address(this), _beneficiary, _amountOfTokens);
        return true;
    }

    function _claimTGETokens(address _userAddresses, uint8 _vestingIndex)
        internal
        onlyAfterTGE
        checkVestingStatus(_userAddresses, _vestingIndex)
        
    {
        VestAllocation memory vestData = walletToVestAllocations[
            _userAddresses
        ][_vestingIndex];

        require(
            vestData.vestIndexID >= 7 && vestData.vestIndexID <= 9,
            "Vesting Category doesn't belong to SALE VEsting"
        );
        require(
            vestData.isTgeTokensClaimed == false,
            "TGE Tokens Have already been claimed for Given Address"
        );

        uint256 tokensToTransfer = vestData.totalTGETokens;

        // Updating Contract State
        vestData.isTgeTokensClaimed = true;
        walletToVestAllocations[_userAddresses][_vestingIndex] = vestData;
        _sendTokens(_userAddresses, tokensToTransfer);
    }


     function _claimVestTokens(address _userAddresses, uint8 _vestingIndex,uint256 _tokenAmount)
    public
    checkVestingStatus(_userAddresses, _vestingIndex)
    
  {
    // Get Vesting Details
    VestAllocation memory vestData =
      walletToVestAllocations[_userAddresses][_vestingIndex];

    // Get total amount of tokens claimed till date
    uint256 _totalTokensClaimed =
      totalTokensClaimed(_userAddresses, _vestingIndex);
    // Get the total claimable token amount at the time of calling this function
    uint256 tokensToTransfer =
      calculateClaimableTokens(_userAddresses, _vestingIndex);

    require(tokensToTransfer > 0, "No tokens to transfer at this point of time");
    require (_tokenAmount <= tokensToTransfer,"Cannot Claim more than Monthly Vest Amount");
    uint256 contractTokenBalance = balanceOf[address(this)];
    require(
      contractTokenBalance > _tokenAmount,
      "Not Enough Token Balance in Contract"
    );
    require(
      _totalTokensClaimed+(_tokenAmount) <=
        vestData.totalTokensAllocated,
      "Cannot Claim more than Allocated"
    );

    vestData.totalVestTokensClaimed += _tokenAmount;
    if (
      _totalTokensClaimed+(_tokenAmount) == vestData.totalTokensAllocated
    ) {
      vestData.isVesting = false;
    }
    walletToVestAllocations[_userAddresses][_vestingIndex] = vestData;
    _sendTokens(_userAddresses, _tokenAmount);
  }
  function withdrawContractTokens() external onlyOwner  {
    uint256 remainingTokens = balanceOf[address(this)];
    _sendTokens(msg.sender, remainingTokens);
  }
}


