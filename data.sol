pragma solidity ^0.4.6;

contract Tree{
    
    mapping(bytes32=>bytes32) public leafAndRoot;
    
    function getLeafAndRoot(bytes32 _leaf) returns (bytes32 root)
    {
        return leafAndRoot[_leaf];
    }
    
    function setLeafAndRoot(bytes32 _leaf, bytes32 _data)
    {
        leafAndRoot[_leaf] = _data;
    }
}

contract Data{
    
    struct tree{
        bytes32 root;
        Tree tree;
        uint length;
    }

    bytes32 public empty;                                                   
    
    mapping (address=>tree) public users;
    
    function resetData(address _user) public returns (bool success){
        
        users[_user].tree = new Tree();
        
        return true;
    }
    
    function addUser(address _user)
    {
        users[_user].tree = new Tree();
    }
    
    function addData(uint256 _data,address _user) public returns (bool success) {  
        
        bytes32 leaf    = keccak256(abi.encodePacked(_data));   
        bytes32 oldRoot = getUserRoot(_user);
        bytes32 newRoot = hashTheTwo(leaf, oldRoot);
        
        if(users[_user].length == 0) { users[_user].tree = new Tree(); }
        
        users[_user].tree.setLeafAndRoot(leaf,newRoot);
        users[_user].root = newRoot;
        users[_user].length += 1;

        return true;
    }
    
    function getRoot(uint256 _leafData,address _user) constant public returns (bytes32 root) { 
        
        bytes32 leaf = keccak256(abi.encodePacked(_leafData));                                            
        return users[_user].tree.getLeafAndRoot(leaf);
    }
    
    function getUserRoot(address _user) constant public returns (bytes32 root) {      
        return users[_user].root;
    }

    function hashTheTwo(bytes32 _a, bytes32 _b) pure private returns (bytes32 hashed) {         
        return keccak256(abi.encodePacked(_a, _b));
    }
    
    function checkDataIntegrity(uint256[] _data,address _user) constant public returns (bool complete) { 
         
        bytes32 oldRoot = empty;                                               
        for (uint i = 0; i < _data.length; i++) {         
            bytes32 data = keccak256(abi.encodePacked(_data[i]));          
            bytes32 root = hashTheTwo(data, oldRoot);
            
            if(root == getRoot(_data[i], _user)){         
                oldRoot = root;
                continue;
            }else{
                return false;
            }
        }        

        if (oldRoot == getUserRoot(_user)){
            return true;
        }else{
            return false;
        }
    }
}
