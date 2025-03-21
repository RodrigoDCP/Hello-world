# Descripción

Sistema básico de NFTs (Tokens No Fungibles) implementado en la Internet Computer. Permite a los usuarios crear, transferir y consultar NFTs de descentralizada. Cada NFT tiene un identificador metadata y un propietario asociado. Ideal para colecciones digitales, propiedad de activos y mercados de NFTs.

---

### **1. Función `mint`**

**Propósito:** Crear un nuevo NFT.

~~~java
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
~~~

**Caja de Entrada:**

- Un valor de tipo `Text`, que corresponde al `metadata` del NFT (por ejemplo, una URL o descripción).

**Qué ingresar:**

- Ingresa un texto que represente la metadata del NFT. Por ejemplo:

~~~bash 
"https://ejemplo.com/SilverPinkChess"
~~~

~~~bash
"Silver Pink Chess"
~~~

**Qué sucede:**

1. El contrato crea un nuevo NFT con el `metadata` proporcionado.
    
2. El NFT es asignado al `Principal` que llamó a la función (tu identidad).
    
3. Retorna el `TokenId` del NFT creado.
    

**Ejemplo:**

- Si ingresas `"https://ejemplo.com/ChessPinkSilver"`, el contrato retornará algo como:

~~~json
"0"
~~~

---

### **2. Función `transfer`**

**Propósito:** Transferir un NFT a otro propietario.

~~~java
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
~~~

**Caja de Entrada:**

- Te pedirá dos valores:  

   1. `tokenId`: El identificador del NFT que deseas transferir (un número natural, `Nat`).
   2. `Principal`: propietario (una identidad en la IC).

**Qué ingresar:**

~~~bash
"0"
~~~

~~~bash
"y5x7z-2qaaq-aaaaa-aabqq-cai"
~~~

**Qué sucede:**

1. El contrato verifica que el NFT exista y que el llamador sea el propietario actual.
    
2. Si es válido, transfiere el NFT al nuevo propietario.
    
3. Retorna `true` si la transferencia fue exitosa, o `false` si falló.
    

**Ejemplo:**

- Si ingresas `0` y `xxxxx-xxxxx-xxxxx-xxxxx-xxx`, el contrato retornará:

~~~json
"true"
~~~

---

### **3. Función `getNFT`**

**Propósito:** Obtener la información de un NFT específico.

~~~java
public query func getNFT(tokenId : TokenId) : async ?NFT {
    tokens.get(tokenId)
};
~~~

**Caja de Entrada:**

- Te pedirá un valor de tipo `Nat`, que corresponde al `TokenId` del NFT que deseas consultar.

**Qué ingresar:**

- Ingresa el `TokenId` del NFT que deseas consultar. Por ejemplo:

~~~json
"0"
~~~

**Qué sucede:**

1. El contrato busca el NFT en el `HashMap` usando el `TokenId`.
    
2. Retorna la información del NFT si existe, o `null` si no.
    

**Ejemplo:**

- Si ingresas `0`, el contrato retornará algo como:

~~~json
opt {
  owner = "tu-principal";
  metadata = "https://ejemplo.com/ChessPinkSilver";
}
~~~

---

### **4. Función `getNFTsByOwner`**

**Propósito:** Obtener todos los `TokenId` de los NFTs que pertenecen a un propietario específico.

~~~java
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
};
~~~

**Caja de Entrada:**

- Te pedirá un valor de tipo `Principal`, que corresponde al dueño de los NFTs que deseas consultar.
    

**Qué ingresar:**

- Ingresa el `Principal` del propietario. Por ejemplo:

~~~bash
"xxxxx-xxxxx-xxxxx-xxxxx-xxx"
~~~

**Qué sucede:**

1. El contrato filtra todos los NFTs que pertenecen al `Principal` proporcionado.
    
2. Retorna una lista de `TokenId` de los NFTs encontrados.
    

**Ejemplo:**

- Si ingresas `xxxxx-xxxxx-xxxxx-xxxxx-xxx`, el contrato retornará algo como:

~~~json
[0, 1, 2]
~~~
