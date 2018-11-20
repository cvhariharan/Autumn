pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;


contract AssetTracker {

    address public seller;
    string public sellerName;
    uint nonce;
    uint public orderNonce;
    uint public productNonce;

    struct Product {
        string id;
        string name;
        string imgId;
        bytes32[] entities;
        string desc;
        string features;
        string category;
        uint last;
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

    struct Token {
        bytes32 tokenId;
        string productId;
        Product product;
    }

    struct Message {
        string id;
        string message;
        address owner;
    }

    mapping(string => Product) productsCatelog;

    mapping(address => bytes32[]) tokensOwner;

    //Mapping from each user to the product_id and its quantity
    mapping(address => mapping(string => uint)) ownership;

    mapping(string => Message) messageLog;
    mapping(string => string[]) categories;
    mapping(address => mapping(string => Order)) ordersLog; 

    mapping(uint => Order) ordersList;

    event ProductAdded(string id, string name, string seller);
    event ProductTransferred(string id, address from, address to, uint quantity);
    event AddToCart(uint order, string id, uint quantity);
    event OrderTransferred(string orderId, address from, address to);
    event OrderPlaced(uint orderId, address by);

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
        mintProductTokens(_id, _quantity, msg.sender);
        emit ProductAdded(_id, _name, sellerName);
    }

    function mintProductTokens(string _id, uint quantity, address owner) internal {
        uint256 m;
        for(uint256 i = 0; i < quantity; i++) {
            bytes32 tokenId = keccak256(i, seller, _id);
            productsCatelog[_id].entities.push(tokenId);
            m = i;
        }
        productsCatelog[_id].last = m;
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

    function getTokens(string _id) public view returns(bytes32[] tokenIds) {
        return productsCatelog[_id].entities;
    }

    function getUserTokens(address user) public view returns(bytes32[] tokenIds) {
        return tokensOwner[user];
    }

    function transferProduct(address to, string _id, uint _quantity) public {
        // require(ownership[msg.sender][_id] >= _quantity, "Does not have the product in sufficient quantity or product out of stock");
        require(msg.sender == seller, "Only seller can transfer product from warehouse");
        ownership[msg.sender][_id] -= _quantity;
        ownership[to][_id] += _quantity;
        uint _last = productsCatelog[_id].last;
        uint256 m;
        for(uint256 i = _last; i > (_last - _quantity); i--) {
            tokensOwner[to].push(productsCatelog[_id].entities[i]);
            delete productsCatelog[_id].entities[i];
            m = i;
        }
        productsCatelog[_id].last = m;
        emit ProductTransferred(_id, msg.sender, to, _quantity);
    }

    function addToCart(uint _orderId, string _id, uint _quantity) public {
        require(ownership[seller][_id] > _quantity, "Sufficient quantity of products not available");
        Order order = ordersList[_orderId];

        if(order.state == false) {
            order.owner = msg.sender;
            order.state = true;
        }

        require(order.owner == msg.sender, "Only the order creator can add to this order");
        //Check if this is a new order. If yes, then set the owner

        order.cart[_id] = _quantity;
        order.ordersList.push(_id);
        emit AddToCart(_orderId, _id, _quantity);
    }

    function getCart(uint _orderId) public view returns(string[] _ordersList) {
        //TODO add user verification
        Order memory order = ordersList[_orderId];
        return order.ordersList;
    }

    function placeOrder(uint _orderId) public{
        require(ordersList[_orderId].owner == msg.sender, "Only order creator can place order");
        ordersList[_orderId].owner = seller;
        emit OrderPlaced(_orderId, msg.sender);
    }

    function buyOrder(uint _orderId, address to) public {
        Order order = ordersList[_orderId];
        require(msg.sender == order.owner);
        for(uint256 i = 0 ; i < order.ordersList.length; i++) {
            transferProduct(to, order.ordersList[i], order.cart[order.ordersList[i]]);
        }
    }

    function createOrderId() public {
        ++orderNonce;
    }

    function getOrderId() public view returns(uint orderNonce) {
        return uint8(uint256(keccak256(block.timestamp, block.difficulty, block.number)));

    }

    function transferOrder(string _orderId, address to) public {
        Order order = ordersLog[msg.sender][_orderId];
        //Redundant
        require(order.owner == msg.sender, "Only the owner can transfer order");
        order.owner = to;
        ordersLog[to][_orderId] = order;
    }

}