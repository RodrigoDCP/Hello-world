import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32"; // Importación añadida
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Iter "mo:base/Iter";

actor {

  type TokenId = Nat;

  type NFT = {
    owner : Principal;
    metadata : Text
  };

  // Usamos HashMap para manejar tokens de forma eficiente
  var tokens = HashMap.HashMap<TokenId, NFT>(0, Nat.equal, func(k : TokenId) : Nat32 {Nat32.fromNat(k)});
  var nextTokenId : TokenId = 0;

  // Función para acuñar NFT
  public shared (msg) func mint(metadata : Text) : async TokenId {
    let newNFT : NFT = {
      owner = msg.caller; // Acceso correcto al caller
      metadata = metadata
    };
    let tokenId = nextTokenId;
    tokens.put(tokenId, newNFT);
    nextTokenId += 1;
    tokenId
  };

  // Función para transferir NFT
  public shared (msg) func transfer(tokenId : TokenId, to : Principal) : async Bool {
    switch (tokens.get(tokenId)) {
      case (null) {return false};
      case (?nft) {
        if (nft.owner != msg.caller) return false; // Verificación de ownership
        let updatedNFT = {owner = to; metadata = nft.metadata};
        tokens.put(tokenId, updatedNFT); // Actualización correcta
        return true
      }
    }
  };

  // Función para obtener NFT
  public query func getNFT(tokenId : TokenId) : async ?NFT {
    tokens.get(tokenId)
  };

  // Función para listar NFTs por dueño
  public query func getNFTsByOwner(owner : Principal) : async [TokenId] {
    let entries = tokens.entries();
    let filtered = Iter.filter(
      entries,
      func((id, nft) : (TokenId, NFT)) : Bool {
        nft.owner == owner
      }
    );
    let mapped = Iter.map(
      filtered,
      func((id, nft) : (TokenId, NFT)) : TokenId {
        id
      }
    );
    Iter.toArray(mapped)
  }
}

