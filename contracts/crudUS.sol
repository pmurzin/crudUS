pragma solidity ^0.4.25;
 
contract crudUS {
    
    address public manager;
    
    struct city {
        string diet;
        uint cpopulation;
        uint cindex;
    }
    
    struct state {
        string[] cityList; // list of cities keys to look them up
        mapping (string => city) cityStructs;
        string diet;
        uint spopulation;
        uint sindex;
    }
    
    mapping(string => state) stateStructs; // random access by state key
    string[] stateList; // list of states keys to enumerate 
    
    constructor() public {
        manager = msg.sender;
    }
    
    function isState(string stateKey) public view returns(bool isPresent) 
    {
        if (stateList.length == 0) return false;
        // for simplicity; not very effective though, TODO: use stringUtils
        // https://github.com/ethereum/dapp-bin/blob/master/library/stringUtils.sol
        return (compareStrings(stateList[stateStructs[stateKey].sindex], stateKey));
    }
    
    function isCity(string stateKey, string cityKey) public view returns(bool isPresent) 
    {
        if (!isState(stateKey)) revert();
        if (stateStructs[stateKey].cityList.length == 0) return false;
        return (compareStrings (
               stateStructs[stateKey].cityList[ stateStructs[stateKey].cityStructs[cityKey].cindex ],
               cityKey)
               );
    }
    
    function createState(string stateKey, string diet/*, uint population*/) public onlyManager
    {
        // checking for duplicates
        require(!isState(stateKey));
        stateStructs[stateKey].diet = diet;
        // stateStructs[stateKey].spopulation = population;
        stateStructs[stateKey].sindex = stateList.length;
 
        stateList.push(stateKey);
    }
    
    function createCity(string stateKey, string cityKey, string diet, uint cpopulation) public onlyManager {
        require(!isCity(stateKey,cityKey));
        stateStructs[stateKey].cityList.push(cityKey);
        stateStructs[stateKey].cityStructs[cityKey].diet = diet;
        stateStructs[stateKey].cityStructs[cityKey].cpopulation = cpopulation;
        stateStructs[stateKey].cityStructs[cityKey].cindex = stateStructs[stateKey].cityList.length;
        
        stateStructs[stateKey].spopulation += cpopulation;
    }
    
    function getState(string stateKey) public view returns(string diet, uint population)
    {
        require(isState(stateKey));
        return(stateStructs[stateKey].diet, stateStructs[stateKey].spopulation);
    }
        
    function getCity(string stateKey, string cityKey) public view returns(string diet, uint cpopulation)
    {
        //require(isCity(stateKey,cityKey));
        return(stateStructs[stateKey].cityStructs[cityKey].diet,
               stateStructs[stateKey].cityStructs[cityKey].cpopulation);
    }
    
    function updateStateDiet(string stateKey, string newDiet) public onlyManager {
        require(isState(stateKey));
        stateStructs[stateKey].diet = newDiet;
    }
    
    function updateStatePopulation(string stateKey, uint population) private onlyManager {
        require(isState(stateKey));
        stateStructs[stateKey].spopulation = population;
    }

    function updateCityDiet(string stateKey, string cityKey, string newDiet) public onlyManager{
    //    require(isCity(stateKey,cityKey));
        stateStructs[stateKey].cityStructs[cityKey].diet = newDiet;
    }
    
    function updateCityPopulation(string stateKey, string cityKey, uint population) public onlyManager {
    //    require(isCity(stateKey,cityKey));
        population = stateStructs[stateKey].spopulation 
        - stateStructs[stateKey].cityStructs[cityKey].cpopulation
        + population;
        
        updateStatePopulation(stateKey, population);
        
        stateStructs[stateKey].cityStructs[cityKey].cpopulation = population;
    }
    
    function deleteState(string stateKey) public onlyManager
    {
        require(isState(stateKey));
       
        uint rowToDelete = stateStructs[stateKey].sindex;
        string storage keyToMove = stateList[stateList.length-1];
        stateList[rowToDelete] = keyToMove;
        stateStructs[keyToMove].sindex = rowToDelete;
        stateList.length--;
    }
    
    function deleteCity(string stateKey, string cityKey) public onlyManager
    {
      //  require(isCity(stateKey,cityKey));
       
        uint population = stateStructs[stateKey].spopulation 
        - stateStructs[stateKey].cityStructs[cityKey].cpopulation;
        
        updateStatePopulation(stateKey, population);
 
        uint rowToDelete = stateStructs[stateKey].cityStructs[cityKey].cindex;
        string storage keyToMove = stateStructs[stateKey].cityList[stateStructs[stateKey].cityList.length-1];
        stateStructs[stateKey].cityList[rowToDelete] = keyToMove;
        stateStructs[stateKey].cityStructs[cityKey].cindex = rowToDelete;
        stateStructs[stateKey].cityList.length--;
    }
    
    function compareStrings(string a, string b)  internal pure returns (bool){
       return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
   }
    
    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }
}
