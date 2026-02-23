// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PropertyManagement is AccessControl {


    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // ERC20 token used for payment
    IERC20 public paymentToken;

    constructor(address _tokenAddress) {
        paymentToken = IERC20(_tokenAddress);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    // Property Structure
    struct Property {
        uint256 id;
        string name;
        string location;
        uint256 price;
        address owner;
        bool forSale;
    }

    uint256 public propertyCount;

    mapping(uint256 => Property) public properties;

    uint256[] public propertyIds;

  
    // CREATE PROPERTY FUNCTION
   
    function createProperty(
        string memory _name,
        string memory _location,
        uint256 _price
    ) external onlyRole(ADMIN_ROLE) {

        propertyCount++;

        properties[propertyCount] = Property({
            id: propertyCount,
            name: _name,
            location: _location,
            price: _price,
            owner: msg.sender,
            forSale: true
        });

        propertyIds.push(propertyCount);
    }


    // FUNCTION TO REMOVE PROPERTY
   
    function removeProperty(uint256 _id) external onlyRole(ADMIN_ROLE) {
        delete properties[_id];
    }

    // FUNCTION FOR GETING ALL PROPERTIES

    function getAllProperties() external view returns (Property[] memory) {

        Property[] memory allProperties = new Property[](propertyIds.length);

        for (uint256 i = 0; i < propertyIds.length; i++) {
            allProperties[i] = properties[propertyIds[i]];
        }

        return allProperties;
    }

    // BUY PROPERTY FUNCTION

    function buyProperty(uint256 _id) external {

        Property storage property = properties[_id];

        require(property.forSale, "Not for sale");
        require(msg.sender != property.owner, "Owner cannot buy");

        // Transfer token from buyer to seller
        paymentToken.transferFrom(
            msg.sender,
            property.owner,
            property.price
        );

        // Transfer ownership
        property.owner = msg.sender;
        property.forSale = false;
    }


    // FUNCTION TO SET PROPERTY FOR SALE AGAIN

    function setForSale(uint256 _id, uint256 _newPrice) external {

        Property storage property = properties[_id];

        require(msg.sender == property.owner, "Not property owner");

        property.price = _newPrice;
        property.forSale = true;
    }
}