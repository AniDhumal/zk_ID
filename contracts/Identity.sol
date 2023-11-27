// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DIdentity is Ownable {
    struct Identity {
        bytes32 UID;
        bytes32 nameHash; // keccak256 hash of name
        uint256 dobHash; // Poseidon hash of date of birth
    }

    struct Profile {
        string entity;
        uint256 dataHash;
        uint256 timestamp;
    }

    mapping(address => Identity) private identities;
    mapping(address => mapping(address => Profile)) identityProfiles;
    mapping(address => address[]) private profiles;

    string public name;
    bytes32 private zeroHash = bytes32(0);

    event Mint(address _user);
    event Burn(address _user);
    event Update(address _user);
    event SetProfile(address _profiler, address _user);
    event RemoveProfile(address _profiler, address _user);

    function mint(address _user, Identity memory _identityData)
        external
        onlyOwner
    {
        require(identities[_user].UID == zeroHash, "Soul already exists");
        identities[_user] = _identityData;
        emit Mint(_user);
    }

    function burn(address _user) external onlyOwner {
        delete identities[_user];
        for (uint256 i = 0; i < profiles[_user].length; i++) {
            address profiler = profiles[_user][i];
            delete identityProfiles[profiler][_user];
        }
        emit Burn(_user);
    }

    function update(address _user, Identity memory _identityData) external {
        require(identities[_user].UID != zeroHash, "Soul does not exist");
        identities[_user] = _identityData;
        emit Update(_user);
    }

    function hasSoul(address _user) external view returns (bool) {
        if (identities[_user].UID == zeroHash) {
            return false;
        } else {
            return true;
        }
    }

    function getSoul(address _user) external view returns (Identity memory) {
        return identities[_user];
    }

    function setProfile(address _user, Profile memory _profileData) external {
        require(
            identities[_user].UID != zeroHash,
            "Cannot create a profile for a soul that has not been minted"
        );
        identityProfiles[msg.sender][_user] = _profileData;
        profiles[_user].push(msg.sender);
        emit SetProfile(msg.sender, _user);
    }

    function getProfile(address _profiler, address _user)
        external
        view
        returns (Profile memory)
    {
        return identityProfiles[_profiler][_user];
    }

    function listProfiles(address _user)
        external
        view
        returns (address[] memory)
    {
        return profiles[_user];
    }

    function hasProfile(address _profiler, address _user)
        public
        view
        returns (bool)
    {
        if (
            keccak256(bytes(identityProfiles[_profiler][_user].entity)) ==
            zeroHash
        ) {
            return false;
        } else {
            return true;
        }
    }

    function removeProfile(address _profiler, address _user) external {
        require(
            msg.sender == _user || msg.sender == _profiler,
            "Only users have rights to delete their profile data"
        );
        require(hasProfile(_profiler, _user), "Profile does not exist");
        delete identityProfiles[_profiler][msg.sender];
        emit RemoveProfile(_profiler, _user);
    }

    function getID(address _user) external view returns (Identity memory) {
        return identities[_user];
    }
}
