// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";

contract CustodialWallet is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable ethiq;
    IERC20 public immutable usdc;

    mapping(bytes32 => uint256) private usdcBalance;
    mapping(bytes32 => uint256) private ethiqBalance;
    mapping(bytes32 => address) private userAddresses;

    modifier onlyUser(bytes32 userId) {
        address user = userAddresses[userId];
        require(user == msg.sender, "Unauthorized");
        _;
    }

    // =============== Events ===============

    event DepositUsdc(bytes32 userId, uint256 amount);
    event DepositEthiq(bytes32 userId, uint256 amount);
    event PayUsdc(bytes32 userId, address to, uint256 amount);
    event PayEthiq(bytes32 userId, address to, uint256 amount);
    event TransferUsdc(bytes32 from, bytes32 to, uint256 amount);
    event TransferEthiq(bytes32 from, bytes32 to, uint256 amount);
    event WithdrawUsdc(bytes32 userId, address to, uint256 amount);
    event WithdrawEthiq(bytes32 userId, address to, uint256 amount);

    constructor(address _usdc, address _ethiq) Ownable() {
        require(_usdc != address(0), "usdc token invalid");
        require(_ethiq != address(0), "ethiq token invalid");

        usdc = IERC20(_usdc);
        ethiq = IERC20(_ethiq);
    }

    // =============== Helpers ===============

    function getUserId(address user) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(user));
    }

    // =============== Deposit Functions ===============

    function depositEthiq(
        bytes32 userId,
        uint256 amount
    ) external nonReentrant {
        require(amount > 0, "amount must be > 0");
        ethiq.safeTransferFrom(msg.sender, address(this), amount);
        ethiqBalance[userId] += amount;
        userAddresses[userId] = msg.sender;

        emit DepositEthiq(userId, amount);
    }

    function depositUSDC(bytes32 userId, uint256 amount) external nonReentrant {
        require(amount > 0, "amount must be > 0");
        usdc.safeTransferFrom(msg.sender, address(this), amount);

        usdcBalance[userId] += amount;
        userAddresses[userId] = msg.sender;

        emit DepositUsdc(userId, amount);
    }

    // =============== Internal Transfer Functions ===============

    function transferEthiq(
        bytes32 from,
        bytes32 to,
        uint256 amount
    ) external onlyOwner {
        require(amount > 0, "amount must be > 0");
        require(ethiqBalance[from] >= amount, "Not enough ETHIQ balance");
        ethiqBalance[from] -= amount;
        ethiqBalance[to] += amount;

        emit TransferEthiq(from, to, amount);
    }

    function transferUsdc(
        bytes32 from,
        bytes32 to,
        uint256 amount
    ) external onlyOwner {
        require(amount > 0, "amount must be > 0");
        require(usdcBalance[from] > amount, "Not enough USDC balance");
        usdcBalance[from] -= amount;
        usdcBalance[to] += amount;

        emit TransferUsdc(from, to, amount);
    }

    // =============== View Functions ===============

    function getEthiqBalance(bytes32 userId) external view returns (uint256) {
        return ethiqBalance[userId];
    }

    function getUsdcBalance(bytes32 userId) external view returns (uint256) {
        return usdcBalance[userId];
    }

    // =============== Withdraw Functions ===============

    function withdrawEthiq(
        bytes32 userId,
        address to,
        uint256 amount
    ) external onlyUser(userId) nonReentrant {
        require(to != address(0), "Invalid Address");
        require(amount > 0, "amout must be > 0");
        require(ethiqBalance[userId] > amount, "Not enough ETHIQ balance");

        ethiqBalance[userId] -= amount;
        ethiq.safeTransfer(to, amount);
        emit WithdrawEthiq(userId, to, amount);
    }

    function withdrawUsdc(
        bytes32 userId,
        address to,
        uint256 amount
    ) external onlyUser(userId) nonReentrant {
        require(to != address(0), "Invalid Address");
        require(amount > 0, "amout must be > 0");
        require(usdcBalance[userId] > amount, "Not enough ETHIQ balance");

        usdcBalance[userId] -= amount;
        usdc.safeTransfer(to, amount);

        emit WithdrawUsdc(userId, to, amount);
    }

    // =============== Pay Functions ===============

    function payEthiq(
        bytes32 userId,
        address to,
        uint256 amount
    ) external onlyUser(userId) nonReentrant {
        require(to != address(0), "address invalid");
        require(amount > 0, "amount must be > 0");
        require(ethiqBalance[userId] > amount, "Not enough ETHIQ balance");

        bytes32 toUserId = getUserId(to);

        ethiqBalance[userId] -= amount;
        ethiqBalance[toUserId] += amount;

        if (userAddresses[toUserId] == address(0)) {
            userAddresses[toUserId] = to;
        }

        emit PayEthiq(userId, to, amount);
    }

    function payUsdc(
        bytes32 userId,
        address to,
        uint256 amount
    ) external onlyUser(userId) nonReentrant {
        require(to != address(0), "address invalid");
        require(amount > 0, "amount must be > 0");
        require(usdcBalance[userId] > amount, "Not enough USDC balance");

        bytes32 toUserId = getUserId(to);

        address feeAddress1 = 0xdBF12B221ef3676Edd9f860a6ca377032dDF786E; // 5%
        address feeAddress2 = 0xa8ed9b14658Bb9ea3e9CC1e32BA08fcbe6888927; // 10%

        uint256 fee5 = (amount * 5) / 100;
        uint256 fee10 = (amount * 10) / 100;
        uint256 receiverAmount = amount - fee5 - fee10; // 85%

        usdcBalance[userId] -= amount;
        usdcBalance[toUserId] += receiverAmount;

        usdc.safeTransfer(feeAddress1, fee5);
        usdc.safeTransfer(feeAddress2, fee10);

        if (userAddresses[toUserId] == address(0)) {
            userAddresses[toUserId] = to;
        }

        emit PayUsdc(userId, to, receiverAmount);
    }
}
