// SPDX-License-Identifier: MIT

/**

@title MovieStore
@dev This contract is a movie store that allows authorized users to add new movies to the store and sell copies of the movies for Ether.
@author [Insert Author Name Here]
@notice This contract is licensed under the MIT license.
*/

pragma solidity >=0.7.0 <0.9.0;


interface IERC20Token {
/**
* @dev Transfers tokens from sender's account to the specified recipient.
* @param recipient The address of the recipient.
* @param amount The amount of tokens to be transferred.
* @return A boolean value indicating whether the transfer was successful or not.
*/
    
    function transfer(address recipient, uint256 amount) external returns (bool);
/**
 * @dev Approves the specified spender to spend a certain amount of tokens on behalf of the owner.
 * @param spender The address of the spender.
 * @param amount The amount of tokens to be approved for spending.
 * @return A boolean value indicating whether the approval was successful or not.
 */
    function approve(address spender, uint256 amount) external returns (bool);
/**
 * @dev Transfers tokens from one address to another.
 * @param sender The address from which tokens are to be transferred.
 * @param recipient The address of the recipient.
 * @param amount The amount of tokens to be transferred.
 * @return A boolean value indicating whether the transfer was successful or not.
 */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
/**
 * @dev Returns the total supply of the token.
 * @return The total supply of the token.
 */
    function totalSupply() external view returns (uint256);
/**
 * @dev Returns the balance of the specified account.
 * @param account The address of the account to check the balance of.
 * @return The balance of the specified account.
 */
    function balanceOf(address account) external view returns (uint256);
/**
 * @dev Returns the amount of tokens that the spender is allowed to spend on behalf of the owner.
 * @param owner The address of the owner.
 * @param spender The address of the spender.
 * @return The amount of tokens that the spender is allowed to spend on behalf of the owner.
 */
    function allowance(address owner, address spender) external view returns (uint256);
/**
 * @dev Emitted when tokens are transferred from one address to another.
 * @param from The address from which tokens are transferred.
 * @param to The address to which tokens are transferred.
 * @param value The amount of tokens that are transferred.
 */
    event Transfer(address indexed from, address indexed to, uint256 value);
/**
 * @dev Emitted when a spender is approved to spend a certain amount of tokens on behalf of an owner.
 * @param owner The address of the owner.
 * @param spender The address of the spender.
 * @param value The amount of tokens that are approved for spending.
 */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

}
/**
@title MovieStore
@dev This contract is a movie store that allows authorized users to add new movies to the store and sell copies of the movies for Ether.
*/

contract MovieStore {
 /**
@dev Struct representing a movie. Contains various details about the movie such as the production company, title, director, etc.
*/   
    struct Movie {
        address productionCo;
        bytes32 title;
        bytes32 director;
        bytes32 image;
        bytes32 description;
        uint256 price;
        uint256 copiesAvailable;
    }
/**
@dev A mapping to store movies by their IDs and a counter for the total number of movies stored.
*/
    mapping (uint256 => Movie) public movies;
    uint256 public movieCount;

/**
@dev owner is the address that deployed the MovieStore contract and has full control over it.
@dev authorized is a mapping that stores addresses of users who are authorized to call certain functions in the contract.
*/
    address public owner;
    mapping (address => bool) public authorized;
/**
@dev Emitted when a new movie is added to the MovieStore.
@param movieId The unique ID of the added movie.
@param title The title of the added movie.
@param director The director of the added movie.
*/  
    event MovieAdded(uint256 movieId, bytes32 title, bytes32 director);

/**

@dev Emitted when a movie is successfully purchased.
@param movieId The ID of the purchased movie.
@param title The title of the purchased movie.
@param director The director of the purchased movie.
*/
    event MoviePurchased(uint256 movieId, bytes32 title, bytes32 director);
/**
@dev Throws if the caller is not the owner of the contract.
*/
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }
/**
@dev Throws if the caller is not authorized to add or purchase movies.
*/
    modifier onlyAuthorized(){
        require(authorized[msg.sender], "Only authorized users can call this function.");
        _;
    }
/**
@dev Initializes the owner of the contract and authorizes them to add and purchase movies.
*/  
    constructor() {
        owner = msg.sender;
        authorized[owner] = true;
    }
/**
@dev Adds a new movie to the store. Only authorized users can call this function.
@param _title Title of the movie.
@param _image IPFS hash of the movie's image.
@param _description Description of the movie.
@param _director Name of the movie's director.
@param _price Price of the movie in Ether.
@param _CopiesAvailable Number of copies of the movie available for purchase.
*/   
    function addMovie(bytes32 _title, bytes32 _image, bytes32 _description, bytes32 _director, uint256 _price, uint256 _CopiesAvailable) public onlyAuthorized() {
        movieCount++;
        movies[movieCount] = Movie(msg.sender, _title, _director, _image, _description, _price, _CopiesAvailable);
        emit MovieAdded(movieCount,_title,_director);
    }
/**
@dev Authorizes a new user to add and purchase movies. Only the owner of the contract can call this function.
@param _address Address of the user to authorize.
*/   
    function authorize(address _address) public onlyOwner {
        authorized[_address] = true;
    }
/**
@dev Revokes authorization of a user to add and purchase movies. Only the owner of the contract can call this function.
@param _address Address of the user to revoke authorization from.
*/   
    function revoke(address _address) public onlyOwner {
        authorized[_address] = false;
    }
/**
@dev Purchases a movie from the store. Only authorized users can purchase movies.
@param _movieId ID of the movie to purchase.
*/   
    function buyMovie(uint256 _movieId) public payable {
        require(movies[_movieId].price > 0, "Invalid movie ID");
        require(authorized[msg.sender], "Only authorized users can purchase movies.");
        require(movies[_movieId].price == msg.value, "Incorrect amount of Ether sent.");
        require(movies[_movieId].copiesAvailable > 0, "Movie has already been purchased.");
        movies[_movieId].copiesAvailable--;
        getMovie(_movieId);
        emit MoviePurchased(_movieId, movies[_movieId].title, movies[_movieId].director);
    }
/**
@dev Retrieves the details of a movie by its ID.
@param _movieId ID of the movie to retrieve.
@return Address of the production company that added the movie, title, director, image IPFS hash, description, price, and number of copies available for purchase.
*/  
    function getMovie(uint256 _movieId) public view returns (address, bytes32, bytes32, bytes32, bytes32, uint256, uint256) {
        return (movies[_movieId].productionCo ,movies[_movieId].title, movies[_movieId].director,movies[_movieId].image, movies[_movieId].description, movies[_movieId].price, movies[_movieId].copiesAvailable);
    }
}
