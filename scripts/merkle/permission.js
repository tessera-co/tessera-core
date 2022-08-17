var fs = require('fs');
const keccak256 = require('keccak256');
const { MerkleTree } = require('merkletreejs');
const { PERMISSIONS } = require('./input/permission');

var tree = {};
var leafNodes = PERMISSIONS.map(
    (hash, i) => ethers.utils.defaultAbiCoder.encode(
        ['bytes32'], [PERMISSIONS[i]]
    )
);
var merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
var rootHash = merkleTree.getHexRoot();
console.log("Merkle Root:", rootHash);
console.log("Merkle Tree: ", merkleTree.toString());

for (var i = 0; i < leafNodes.length; i++) {
    let leaf = leafNodes[i];
    let hexProof = merkleTree.getHexProof(leaf);

    console.log("Leaf Node: ", leaf)
    console.log("Hex Proof: ", hexProof);

    tree[leaf] = {
        'root': rootHash,
        'leaf': leaf,
        'proofs': hexProof
    }

    // console.log(merkleTree.verify(hexProof, leaf, rootHash));
}

// Save tree to JSON file
var json = JSON.stringify(tree, null, 4);
// fs.writeFile("scripts/merkle/output/permission.json", json, function(err) {
//     if (err) throw err;
//     console.log("Complete");
// });
