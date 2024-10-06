module MyModule::P2PProduct {
    use aptos_framework::signer;
    use std::vector;
    use aptos_std::table::{Self, Table};
    use std::string::String;

    struct Product has store, drop, copy {
        owner: address,
        name: String,      
        description: String,
        price: u64,
        image_url: String,
    }

    struct ProductStore has key {
        products: Table<u64, Product>,
        product_count: u64,
    }

    // Function to initialize the ProductStore
    public entry fun initialize(owner: &signer) {
        let store = ProductStore {
            products: table::new(),
            product_count: 0,
        };
        move_to(owner, store);
    }

    // Function to create a product
    public entry fun create_product(owner: &signer, name: String, description: String, price: u64, image_url: String) acquires ProductStore {
        let owner_address = signer::address_of(owner);
        
        assert!(exists<ProductStore>(owner_address), 1); // Error if ProductStore doesn't exist
        
        let store = borrow_global_mut<ProductStore>(owner_address);
        
        let product = Product {
            owner: owner_address,
            name,
            description,
            price,
            image_url,
        };

        table::add(&mut store.products, store.product_count, product);
        store.product_count = store.product_count + 1;
    }

    // Function to buy a product
    public entry fun buy_product(buyer: &signer, owner_address: address, product_id: u64) acquires ProductStore {
        let store = borrow_global_mut<ProductStore>(owner_address);
        
        assert!(table::contains(&store.products, product_id), 2); // Error if product doesn't exist
        
        let product = table::borrow_mut(&mut store.products, product_id);
        product.owner = signer::address_of(buyer);
    }

    // Function to get all product IDs for a specific owner
    public fun get_all_product_ids(owner_address: address): vector<u64> acquires ProductStore {
        let store = borrow_global<ProductStore>(owner_address);
        
        let product_ids = vector::empty<u64>();
        let i = 0;
        while (i < store.product_count) {
            if (table::contains(&store.products, i)) {
                vector::push_back(&mut product_ids, i);
            };
            i = i + 1;
        };

        product_ids
    }

    // Function to get a specific product
    public fun get_product(owner_address: address, product_id: u64): Product acquires ProductStore {
        let store = borrow_global<ProductStore>(owner_address);
        assert!(table::contains(&store.products, product_id), 3); // Error if product doesn't exist
        *table::borrow(&store.products, product_id)
    }
}