// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Project {
    // Struct to represent a product in the supply chain
    struct Product {
        uint256 id;
        string name;
        address manufacturer;
        uint256 timestamp;
        string currentLocation;
        string status; // "Manufactured", "In Transit", "Delivered", "Completed"
        address currentHandler;
        string[] locationHistory;
        address[] handlerHistory;
    }
    
    // Mapping to store products by their ID
    mapping(uint256 => Product) public products;
    
    // Mapping to track authorized handlers in the supply chain
    mapping(address => bool) public authorizedHandlers;
    
    // Counter for product IDs
    uint256 private productCounter;
    
    // Contract owner
    address public owner;
    
    // Events
    event ProductCreated(uint256 indexed productId, string name, address indexed manufacturer);
    event ProductUpdated(uint256 indexed productId, string location, string status, address indexed handler);
    event HandlerAuthorized(address indexed handler);
    event HandlerRevoked(address indexed handler);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyAuthorizedHandler() {
        require(authorizedHandlers[msg.sender] || msg.sender == owner, "Not authorized to handle products");
        _;
    }
    
    modifier productExists(uint256 _productId) {
        require(_productId > 0 && _productId <= productCounter, "Product does not exist");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        authorizedHandlers[msg.sender] = true; // Owner is automatically authorized
    }
    
    // Core Function 1: Create a new product in the supply chain
    function createProduct(string memory _name, string memory _initialLocation) 
        public 
        onlyAuthorizedHandler 
        returns (uint256) 
    {
        require(bytes(_name).length > 0, "Product name cannot be empty");
        require(bytes(_initialLocation).length > 0, "Initial location cannot be empty");
        
        productCounter++;
        
        Product storage newProduct = products[productCounter];
        newProduct.id = productCounter;
        newProduct.name = _name;
        newProduct.manufacturer = msg.sender;
        newProduct.timestamp = block.timestamp;
        newProduct.currentLocation = _initialLocation;
        newProduct.status = "Manufactured";
        newProduct.currentHandler = msg.sender;
        
        // Initialize history arrays
        newProduct.locationHistory.push(_initialLocation);
        newProduct.handlerHistory.push(msg.sender);
        
        emit ProductCreated(productCounter, _name, msg.sender);
        
        return productCounter;
    }
    
    // Core Function 2: Update product location and status in the supply chain
    function updateProduct(
        uint256 _productId, 
        string memory _newLocation, 
        string memory _newStatus
    ) 
        public 
        onlyAuthorizedHandler 
        productExists(_productId) 
    {
        require(bytes(_newLocation).length > 0, "Location cannot be empty");
        require(bytes(_newStatus).length > 0, "Status cannot be empty");
        
        Product storage product = products[_productId];
        
        // Update product information
        product.currentLocation = _newLocation;
        product.status = _newStatus;
        product.currentHandler = msg.sender;
        product.timestamp = block.timestamp;
        
        // Add to history
        product.locationHistory.push(_newLocation);
        product.handlerHistory.push(msg.sender);
        
        emit ProductUpdated(_productId, _newLocation, _newStatus, msg.sender);
    }
    
    // Core Function 3: Get complete product information and history
    function getProductDetails(uint256 _productId) 
        public 
        view 
        productExists(_productId) 
        returns (
            uint256 id,
            string memory name,
            address manufacturer,
            uint256 timestamp,
            string memory currentLocation,
            string memory status,
            address currentHandler,
            string[] memory locationHistory,
            address[] memory handlerHistory
        ) 
    {
        Product storage product = products[_productId];
        
        return (
            product.id,
            product.name,
            product.manufacturer,
            product.timestamp,
            product.currentLocation,
            product.status,
            product.currentHandler,
            product.locationHistory,
            product.handlerHistory
        );
    }
    
    // Administrative function: Authorize new handlers
    function authorizeHandler(address _handler) public onlyOwner {
        require(_handler != address(0), "Invalid handler address");
        authorizedHandlers[_handler] = true;
        emit HandlerAuthorized(_handler);
    }
    
    // Administrative function: Revoke handler authorization
    function revokeHandler(address _handler) public onlyOwner {
        require(_handler != owner, "Cannot revoke owner authorization");
        authorizedHandlers[_handler] = false;
        emit HandlerRevoked(_handler);
    }
    
    // Get total number of products created
    function getTotalProducts() public view returns (uint256) {
        return productCounter;
    }
    
    // Check if an address is an authorized handler
    function isAuthorizedHandler(address _handler) public view returns (bool) {
        return authorizedHandlers[_handler];
    }
}

project:0xB6922Dda6a608Ae589a0DA86FEfC996Ab99EB573
