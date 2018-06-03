pragma solidity ^0.4.6;

contract Tree{
    
    mapping(bytes32=>bytes32) public leafAndRoot;
    bytes32 public empty;
    
    function getLeafAndRoot(bytes32 _leaf) constant public returns (bytes32 root) {
        return leafAndRoot[_leaf];
    }
    
    function setLeafAndRoot(bytes32 _leaf, bytes32 _data) public returns (bool success) {
        leafAndRoot[_leaf] = _data;
        return true;
    }
    
    function removeLeaf(bytes32 _leaf) public returns (bool success) {
        leafAndRoot[_leaf] = empty;
        return true;
    }
    
    function updateLeaf(bytes32 _leaf, bytes32 _data) public returns (bool success) {
        leafAndRoot[_leaf] = _data;
        return true;
    }
}

contract User{
    
    struct tree{
        bytes32 root;
        Tree tree;
        bool exists;
    }
    
    address private owner;
    
    mapping (address=>tree) public users;
    
    constructor() public {
        users[msg.sender].tree = new Tree();
    }
    
    function setRoot(bytes32 _data) public returns (bool){
        users[msg.sender].root = _data;
        return true;
    }
    
    function getRoot() constant public returns (bytes32){
        return users[msg.sender].root;
    }
    
    function getLeafAndRoot(bytes32 _leaf) constant public returns (bytes32 root){
        return users[msg.sender].tree.getLeafAndRoot(_leaf);
    }
    
    function setLeafAndRoot(bytes32 _leaf, bytes32 _data) public returns (bool success){
        return users[msg.sender].tree.setLeafAndRoot(_leaf,_data);
    }
    
    function removeLeaf(bytes32 _leaf) public returns (bool success){
        return users[msg.sender].tree.removeLeaf(_leaf);
    }
    
    function updateLeaf(bytes32 _leaf, bytes32 _data) public returns (bool success){
        return users[msg.sender].tree.updateLeaf(_leaf,_data);
    }

}

contract Data{
    
    mapping (bytes32=>string) public datas;
    
    function setData(bytes32 _id, string _data) public returns (bool) {
        datas[_id] = _data;
        return true;
    }

    function stringToBytes32(string memory source) pure public returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function getData(bytes32 _id) constant public returns (bytes32) {
        return stringToBytes32(datas[_id]);
    }
}

contract Merkle{

    address private owner;
    
    User private user;
    Data private data;
    bytes32 empty;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
        user = new User();
        data = new Data();
    }
    
    function reset() public returns (bool success) {
        resetData();
        resetUser();
        return true;
    }
    
    function resetData() private returns (bool success){
        data = new Data();
        return true;
    }
    
    function resetUser() private returns (bool success){
        user = new User();
        return true;
    }
    
    function addData(string _data) public onlyOwner returns (bool success) {   
        bytes32 leaf    = keccak256(abi.encodePacked(_data));   
        bytes32 oldRoot = getUserRoot();
        bytes32 newRoot = hashTheTwo(leaf, oldRoot);
        
        user.setLeafAndRoot(leaf,newRoot);
        user.setRoot(newRoot);
        data.setData(newRoot,_data);

        return true;
    }

    function bytes32ToStr(bytes32 _bytes32) private constant onlyOwner returns (string){
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
            }
        return string(bytesArray);  
    }
    
    function getData(bytes32 _id) constant public onlyOwner returns (string) {
        return bytes32ToStr(data.getData(_id));
    }
    
    function unsetData(bytes32 _id) public onlyOwner returns (bool success){
        data.setData(_id,"");
        return user.removeLeaf(_id);
    }
    
    function updateData(bytes32 _id, string _data) public onlyOwner returns (bool success){
        data.setData(_id,_data);
        return user.updateLeaf(keccak256(abi.encodePacked(_data)),_id);
    }
    
    function getUserRoot() constant public returns (bytes32 root) {      
        return user.getRoot();
    }

    function hashTheTwo(bytes32 _a, bytes32 _b) pure private returns (bytes32 hashed) {         
        return keccak256(abi.encodePacked(_a, _b));
    }
    
}
