pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;


contract AssetTracker {

    address public seller;
    string public sellerName;
    uint nonce;

    struct Product {
        string id;
        string name;
        string imgId;
        string desc;
        string features;
        string category;
    }

    struct Order {
        string id;
        mapping(string => uint) cart;
        string[] ordersList;
        uint amount;
        string shippingAddress;
        address owner;
        bool state;
    }

    struct Message {
        string id;
        string message;
        address owner;
    }

    mapping(string => Product) productsCatelog;
    mapping(address => mapping(string => uint)) ownership;
    mapping(string => Message) messageLog;
    mapping(string => string[]) categories;
    mapping(address => mapping(string => Order)) ordersLog; 

    event ProductAdded(string id, string name, string seller);
    event ProductTransferred(string id, address from, address to, uint quantity);
    event AddToCart(string order, string id, uint quantity);

    constructor(string name) {
        seller = msg.sender;
        sellerName = name;
    }

    function addProduct(string _id, string _name, string _category, uint _quantity) public {
        require(msg.sender == seller, "Only the seller can add new products");
        productsCatelog[_id].id = _id;
        productsCatelog[_id].name = _name;
        productsCatelog[_id].category = _category;
        categories[_category].push(_id);
        ownership[seller][_id] = _quantity;
        emit ProductAdded(_id, _name, sellerName);
    }

    function setImage(string _id, string ipfsHash) public {
        require(msg.sender == seller, "Only seller can update products");
        productsCatelog[_id].imgId = ipfsHash;
    }

    function setDesc(string _id, string _desc) public {
        require(msg.sender == seller);
        productsCatelog[_id].desc = _desc;
    }

    function setFeatures(string _id, string _features) public {
        require(msg.sender == seller);
        productsCatelog[_id].features = _features;
    }

    function getProduct(string _id) public view returns(string _name, string _category, string _desc, string _features){
        return (productsCatelog[_id].name, productsCatelog[_id].category, productsCatelog[_id].desc, productsCatelog[_id].features);
    }

    function getImage(string _id) public view returns(string ipfsHash) {
        return productsCatelog[_id].imgId;
    }

    function transferProduct(address to, string _id, uint _quantity) public {
        require(ownership[msg.sender][_id] >= _quantity, "Does not have the product in sufficient quantity or product out of stock");
        ownership[msg.sender][_id] -= _quantity;
        ownership[to][_id] += _quantity;
        emit ProductTransferred(_id, msg.sender, to, _quantity);
    }

    
}