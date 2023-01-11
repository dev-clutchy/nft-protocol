/// Module representing the Nft bookeeping Inventories of `Slot`s.
///
/// Listings can have multiple concurrent markets, repsented
/// through `markets: ObjectBag`, allowing NFT creators to perform tiered sales.
/// An example of this would be an Gaming NFT creator separating the sale
/// based on NFT rarity and emit whitelist tokens to different users for
/// different rarities depending on the user's game score.
///
/// The Slot object is agnostic to the Market mechanism and instead decides to
/// outsource this logic to generic `Market` objects. This way developers can
/// come up with their plug-and-play market primitives, of which some examples
/// are Dutch Auctions, Sealed-Bid Auctions, etc.
///
/// Each market has a dedicated candy_machine, which tracks which NFTs are on
/// the shelves still to be sold, and which NFTs have been sold via Certificates
/// but are still waiting to be redeemed.
module nft_protocol::candy_machine {
    use std::vector;
    use std::type_name::{Self, TypeName};

    use sui::transfer;
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::object::{Self, ID , UID};
    use sui::object_bag::{Self, ObjectBag};

    use nft_protocol::nft::Nft;
    use nft_protocol::err;
    use nft_protocol::warehouse::{Self, Warehouse};

    friend nft_protocol::listing;

    // The `CandyMachine` of a sale performs the bookeeping of all the NFTs that
    // are currently on sale as well as the NFTs whose certificates have been
    // sold and currently waiting to be redeemed
    struct CandyMachine has key, store {
        id: UID,
        /// Track which markets are live
        live: VecMap<ID, bool>,
        /// Track which markets are whitelisted
        whitelisted: VecMap<ID, bool>,
        /// Vector of all markets outlets that, each outles holding IDs
        /// owned by the warehouse
        markets: ObjectBag,
        jit: bool,
    }

    public fun new(
        jit: bool,
        ctx: &mut TxContext,
    ): CandyMachine {
        CandyMachine {
            id: object::new(ctx),
            live: vec_map::empty(),
            whitelisted: vec_map::empty(),
            markets: object_bag::new(ctx),
            jit,
        }
    }

    /// Creates a `CandyMachine` and transfers to transaction sender
    public entry fun init_candy_machine(jit: bool, ctx: &mut TxContext) {
        let candy_machine = new(jit, ctx);

        if (jit == false) {
            dof::add<TypeName, Warehouse>(
                &mut candy_machine.id,
                type_name::get<Warehouse>(),
                warehouse::new(ctx),
            );
        };

        transfer::transfer(candy_machine, tx_context::sender(ctx));
    }

    /// Adds a new market to `CandyMachine` allowing NFTs deposited to the
    /// candy_machine to be sold.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `CandyMachine`.
    public entry fun add_market<Market: key + store>(
        candy_machine: &mut CandyMachine,
        is_whitelisted: bool,
        market: Market,
    ) {
        let market_id = object::id(&market);

        vec_map::insert(&mut candy_machine.live, market_id, false);
        vec_map::insert(&mut candy_machine.whitelisted, market_id, is_whitelisted);

        object_bag::add<ID, Market>(
            &mut candy_machine.markets,
            market_id,
            market,
        );
    }

    /// Adds NFT as a dynamic child object with its ID as key and
    /// adds an NFT's ID to the `nfts` field in `CandyMachine` object.
    ///
    /// This should only be callable when CandyMachine is private and not
    /// owned by the Slot. The function call will fail otherwise, because
    /// one would have to refer to the Slot, the parent shared object, in order
    /// for the bytecode verifier not to fail.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `CandyMachine`.
    public entry fun deposit_nft<C>(
        candy_machine: &mut CandyMachine,
        nft: Nft<C>,
    ) {
        assert!(candy_machine.jit == false, 0);

        let warehouse = dof::borrow_mut<TypeName, Warehouse>(
            &mut candy_machine.id, type_name::get<Warehouse>()
        );

        warehouse::deposit_nft<C>(candy_machine)
    }

    public entry fun deposit_recipe<C>(
        candy_machine: &mut CandyMachine,
        nft: Nft<C>,
    ) {

        assert!(candy_machine.jit == true, 0);

        let nft_id = object::id(&nft);
        vector::push_back(&mut candy_machine.nfts_on_sale, nft_id);

        dof::add(&mut candy_machine.id, nft_id, nft);
    }

    /// Redeems NFT from `CandyMachine`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `CandyMachine`.
    public fun redeem_nft<C>(
        candy_machine: &mut CandyMachine,
    ): Nft<C> {
        let nfts = &mut candy_machine.nfts_on_sale;
        assert!(!vector::is_empty(nfts), err::no_nfts_left());

        dof::remove(&mut candy_machine.id, vector::pop_back(nfts))
    }

    /// Redeems NFT from `CandyMachine` and transfers to sender
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `CandyMachine`.
    ///
    /// ##### Usage
    ///
    /// Entry mint functions like `suimarines::mint_nft` take an `CandyMachine`
    /// object to deposit into. Calling `redeem_nft_transfer` allows one to
    /// withdraw an NFT and own it directly.
    public entry fun redeem_nft_transfer<C>(
        candy_machine: &mut CandyMachine,
        ctx: &mut TxContext,
    ) {
        let nft = redeem_nft<C>(candy_machine);
        transfer::transfer(nft, tx_context::sender(ctx));
    }

    /// Set market's live status
    public entry fun set_live(
        candy_machine: &mut CandyMachine,
        market_id: ID,
        is_live: bool,
    ) {
        *vec_map::get_mut(&mut candy_machine.live, &market_id) = is_live;
    }

    /// Set market's whitelist status
    public entry fun set_whitelisted(
        candy_machine: &mut CandyMachine,
        market_id: ID,
        is_whitelisted: bool,
    ) {
        *vec_map::get_mut(&mut candy_machine.whitelisted, &market_id) =
            is_whitelisted;
    }

    // === Getter Functions ===

    /// Check how many `nfts` there are to sell
    public fun length(candy_machine: &CandyMachine): u64 {
        vector::length(&candy_machine.nfts_on_sale)
    }

    /// Get the market's `live` status
    public fun is_live(candy_machine: &CandyMachine, market_id: &ID): bool {
        *vec_map::get(&candy_machine.live, market_id)
    }

    public fun is_empty(candy_machine: &CandyMachine): bool {
        vector::is_empty(&candy_machine.nfts_on_sale)
    }

    public fun is_whitelisted(candy_machine: &CandyMachine, market_id: &ID): bool {
        *vec_map::get(&candy_machine.whitelisted, market_id)
    }

    /// Get the `CandyMachine` markets
    public fun markets(candy_machine: &CandyMachine): &ObjectBag {
        &candy_machine.markets
    }

    /// Get specific `CandyMachine` market
    public fun market<Market: key + store>(
        candy_machine: &CandyMachine,
        market_id: ID,
    ): &Market {
        assert_market<Market>(candy_machine, market_id);
        object_bag::borrow<ID, Market>(&candy_machine.markets, market_id)
    }

    /// Get specific `CandyMachine` market mutably
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `CandyMachine`.
    public fun market_mut<Market: key + store>(
        candy_machine: &mut CandyMachine,
        market_id: ID,
    ): &mut Market {
        assert_market<Market>(candy_machine, market_id);
        object_bag::borrow_mut<ID, Market>(&mut candy_machine.markets, market_id)
    }

    // === Assertions ===

    public fun assert_is_live(candy_machine: &CandyMachine, market_id: &ID) {
        assert!(is_live(candy_machine, market_id), err::listing_not_live());
    }

    public fun assert_is_whitelisted(candy_machine: &CandyMachine, market_id: &ID) {
        assert!(
            is_whitelisted(candy_machine, market_id),
            err::sale_is_not_whitelisted()
        );
    }

    public fun assert_is_not_whitelisted(candy_machine: &CandyMachine, market_id: &ID) {
        assert!(
            !is_whitelisted(candy_machine, market_id),
            err::sale_is_whitelisted()
        );
    }

    public fun assert_market<Market: key + store>(
        candy_machine: &CandyMachine,
        market_id: ID,
    ) {
        assert!(
            object_bag::contains_with_type<ID, Market>(
                &candy_machine.markets, market_id
            ),
            err::undefined_market(),
        );
    }
}
