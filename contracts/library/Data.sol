// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

library Data {

    enum Modules {
        ADMIN,
        APP,
        IDENTITY,
        PROFILE,
        CREATOR,
        COPY,
        CERT,
        DAO,
        RELATION,
        ACCESS,
        FEE,
        HANDLE
    }

    struct ContentCreationData {
        string contentUri;
        bytes referenceRuleData;
        address referenceRule;
        bytes referenceRuleInitData;
        address copyRule;
        bytes copyRuleInitData;
        uint256 refId;
        bool isShare;
    }

    struct RelationCreationData {
        uint256 fromProfileId;
        uint256 toProfileId; // to profile Id
        string contentUri;
        bool isLocked;
    }

    
}