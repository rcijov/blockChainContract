pragma solidity ^0.4.6;

contract Tree{
    
    mapping(bytes32=>bytes32) public leafAndRoot;
    
    function getLeafAndRoot(bytes32 _leaf) constant public returns (bytes32 root)
    {
        return leafAndRoot[_leaf];
    }
    
    function setLeafAndRoot(bytes32 _leaf, bytes32 _data) public returns (bool success)
    {
        leafAndRoot[_leaf] = _data;
        
        return true;
    }
}

contract Data{
    
    struct tree{
        bytes32 root;
        Tree tree;
        uint length;
        bool exists;
    }

    bytes32 public empty;                                                   
    
    mapping (address=>tree) public users;
    
    function resetData() public returns (bool success){
        
        addUser();
        
        return true;
    }
    
    function addUser() public returns (bool success){
        
        users[msg.sender].tree = new Tree();
        users[msg.sender].root = empty;
        users[msg.sender].length = 0;
        
        return true;
    }
    
    function addData(uint256 _data) public returns (bool success) {  
        
        bytes32 leaf    = keccak256(abi.encodePacked(_data));   
        bytes32 oldRoot = getUserRoot();
        bytes32 newRoot = hashTheTwo(leaf, oldRoot);
        
        if(!users[msg.sender].exists){ addUser(); }
        
        users[msg.sender].tree.setLeafAndRoot(leaf,newRoot);
        users[msg.sender].root = newRoot;
        users[msg.sender].length += 1;

        return true;
    }
    
    function getRoot(uint256 _leafData) constant public returns (bytes32 root) { 
        
        bytes32 leaf = keccak256(abi.encodePacked(_leafData));                                            
        return users[msg.sender].tree.getLeafAndRoot(leaf);
    }
    
    function getUserRoot() constant public returns (bytes32 root) {      
        return users[msg.sender].root;
    }

    function hashTheTwo(bytes32 _a, bytes32 _b) pure private returns (bytes32 hashed) {         
        return keccak256(abi.encodePacked(_a, _b));
    }
    
    function checkDataIntegrity(uint256[] _data) constant public returns (bool complete) { 
         
        bytes32 oldRoot = empty;                                               
        for (uint i = 0; i < _data.length; i++) {         
            bytes32 data = keccak256(abi.encodePacked(_data[i]));          
            bytes32 root = hashTheTwo(data, oldRoot);
            
            if(root == getRoot(_data[i])){         
                oldRoot = root;
                continue;
            }else{
                return false;
            }
        }        

        if (oldRoot == getUserRoot()){
            return true;
        }else{
            return false;
        }
    }
}
