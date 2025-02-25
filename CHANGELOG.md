# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [0.30.0] - 2023-04-20

### Added
- Market orders in the  `orderbook`
- Tags is not longer a domain but a helper module for building Displays
- Global `MintSupply` domain for collections
- Added burn functions for domains
- Generalised pipelining of Requests and Policies
- `Withdraw` and `Borrow` Policy/Requests to be used with OB `Kiosk`
- Live status in Launchpad V2
- Dutch Auctions in Launchpad V2
- Session Tokens and Access Policy Actions for dNFTs

### Changed
- Allowlists can now be used across different Policy/Request types
- Launchpad V1 is now a separate contract
- Removed `collection_type` from `MintCap`


## [0.29.0] - 2023-04-14

### Added
- Added English Auctions to Launchpad

### Changed
- Bugfix Kiosk: Signer must be owner in order to call `transfer_signed`

## [0.28.0] - 2023-04-04

### Added
- Added `Quorum` as an abstraction for managin Administrative object
- Added `AccessPolicy` to manage granular mutable access to NFTs in the `Kiosk`
- Added `Launchpad` V2 with the plans of deprecating Launchpad V1 running up to mainnet
- Added `MutLock`, `ReturnPromise` and `ReturnFieldPromise` for controlling the flow
  of borrowing an NFT from the Kiosk for mutation
- Added `CapAggregator` for grouping Capability objects of the same concern.

### Changed
- Protocol Type Freedom: The wrapper `Nft<T>` is now optional
- Kiosk integration: `Safe` has been deprecated in favor of `Kiosk`

## [0.27.0] - 2023-03-29

### Changed

- Upgraded to Sui 0.29.0

## [0.26.0] - 2023-03-17

### Changed

- `BidCreated` renamed to `BidCreatedEvent`, generic removed and new fields added.
  The generic is problematic for the client as it can then query only for event type knowing the fungible token in advance.
- `BidClosed` event renamed to `BidClosedEvent`, again generic removed and new fields added.
  Additionally, this event is now used only for cancelling a bid.
- Renamed `template::Template` to `metadata::Metadata` and `templates::TemplatesDomain` to `metadata_bag::MetadataBagDomain`
- `OrderbookCreatedEvent` property `fungible_token_type` renamed to `ft_type` to be consistent with other events.
- `BidCreatedEvent`, `BidClosedEvent` and `BidMatchedEvent` property `ft` renamed to `ft_type` to be consistent with other events.
- `BidMatchedEvent` now contains property `nft_type`.
- `MintNftEvent` property `object_type` of type `TypeName` changed to `nft_type` of type `String`.

### Added

- `BidMatchedEvent` emitted when an NFT is sold.
- `NftSoldEvent` emitted from `limited_fixed_price` launchpad market module.
  It contains among others properties `nft_type` and `ft_type`.
- `NftSoldEvent` emitted from `fixed_price` launchpad market module.
  It contains among others properties `nft_type` and `ft_type`.
- `ChangeLogicalOwnerEvent` emitted when logical owner of an NFT is changed.
  It contains old and new logical owner, NFT ID and NFT collection type.
- `MintNftEvent` now contains `logical_owner` field.
- Composable standard with domains `nft_bag::NftBagDomain` and `svg::ComposableSvgDomain`
- All orderbook events now export `ft_type` and `nft_type` fields.
- Added `total_deposited` field to `Warehouse`
- Exposed mutable endpoint for `AttributesDomain`
- Randomized NFT withdrawal with added functions `listing::buy_pseudorandom_nft`, `listing::buy_random_nft`, `inventory::redeem_random_nft`, `inventory::redeem_pseudorandom_nft`

### Fixed

- `OrderbookCreatedEvent` exported collection type instead of FT type.

## [0.25.0] - 2023-02-24

### Added

- Helper endpoints in orderbook which allow marketplaces to perform actions in a single tx.
  The marketplaces can now
  - `edit_bid`
  - `create_safe_and_bid`
  - `create_safe_and_bid_with_commission`
  - `list_multiple_nfts`
  - `list_multiple_nfts_with_commission`
- Helper endpoints in launchpad which allow marketplaces to perform actions in a single tx.
  The marketplaces can now
  - `create_safe_and_buy_whitelisted_nft`
  - `create_safe_and_buy_nft`
  - `buy_nft_into_safe`
  - `buy_whitelisted_nft_into_safe`

### Fixed

- Wrong `seller` field in `TradeFilledEvent` when calling the `buy_nft` endpoint

### Changed

- Moved errors from `err` module into `orderbook` module where they are expressed as constants.

## [0.24.0] - 2023-02-22

### Changed

- Updated to Devnet 0.27.0

## [0.23.1] - 2023-02-18

### Changed

- Updated to Devnet 0.26.1

## [0.23.0] - 2023-02-16

### Added

- `TransferAllowlistDomain` which keeps track of shared object IDs of type `Allowlist`.
- Helper endpoints in orderbook which allow marketplaces to perform actions in a single tx.
  The marketplaces can now
  - `deposit_and_list_nft` (and with commission)
  - `create_safe_and_deposit_and_list_nft` (and with commission)
  - `create_safe_and_buy_nft`
  - `create_safe_and_buy_generic_nft`
  - `cancel_ask_and_discard_transfer_cap`
  - `edit_ask`
- Added static `name` and `url` fields to `Nft` for better integration with explorer.
- Added `LimitedFixedPriceMarket`
- `orderbook::list_nft` and `orderbook::list_nft_with_commission` endpoints.
  These allow the client to skip the creation of transfer caps and instead provide `OwnerCap` to `Safe` directly to the orderbook contract.

### Changed

- Updated to Devnet 0.26.0
- `transfer_allowlist::remove_itself` is now an entry function.
- Revamped NFT domain permissions and control over them
- `Collection` and `Nft` were reverted to use dynamic fields instead of dynamic object fields.
- Migrated all domains not requiring `key` property after loosening `key` requirement on `Nft` and `Collection` domains.

### Fixed

- Orderbook recipient was wrong when trading in orderbook.

## [0.22.0] - 2023-02-02

### Added

- Introduced `DelegatedWitness` pattern
- Refactored `CreatorsDomain` to support `DelegatedWitness` and introduced `PluginDomain`

### Changed

- Renamed `CollectionMintEvent` to `MintCollectionEvent` to be consistent with
  `MintNftEvent`.
- `TagsDomain` now uses dynamic fields instead of `Bag`.
- `RoyaltyDomain` now uses dynamic fields instead of `Bag`.
- Renamed `flyweight` standards to `loose` standards. `archetype::Archetype` is
  no `template::Template` and `registry::RegistryDomain` is
  now `templates::TemplatesDomain`
- Renamed orderbook module `nft_protocol::ob` to `nft_protocol::orderbook`

## [0.21.0] - 2023-02-02

### Changed

- Updated Sui dep to `0.24.0`

## [0.20.3] - 2023-01-31

### Added

- Orderbook's `CreateAskEvent` and `CreateBidEvent` now contain safe ID.
- Emitting event `OrderbookCreatedEvent` when an orderbook is created.

## [0.20.2] - 2023-01-31

### Added

- Orderbook's `TradeFilledEvent` now contains orderbook ID.

## [0.20.1] - 2023-01-30

### Fixed

- In orderbook, it was possible to create an ask or a bid which would require
  that the `finish_trade` function be called with buyer and seller safe as the
  same object.
  This is not possible anymore as such tx would result in an error.

## [0.20.0] - 2023-01-26

### Added

- `DelegatedWitness` generated by `PluginDomain` and `CreatorsDomain` to authorize mutable operations on OriginByte domains.
- `PluginDomain` which collects type names of witness structs.
  These then serve to authorize a function in a "base" contract (the one that is deployed with the one-time-witness type.)
  The function returns the original witness type (of the same module as the OTW) in exchange for a witness of another smart contract (a plugin) if that plugin's witness is present in the `PluginDomain`.
- `Multisig` is a utility struct which enables smart contracts to authorize
  actions signed by predefined set of accounts.

### Changed

- `CreatorsDomain` refactored to support `DelegatedWitness`
  The same reference was required in the `add_creator` function.
- Renamed `Inventory` to `Warehouse`
- Orderbook event `AskCreatedEvent`/`BidCreatedEvent` are emitted when
  creating a new position in orderbook.
- Orderbook event `AskClosedEvent`/`BidClosedEvent` are emitted when
  closing a position in orderbook.
- Orderbook event `TradeFilledEvent` is emitted when a trade is filled.
  That is, either on `create_bid`/`create_ask` when the trade is immediately
  filled, or on `buy_nft`/`buy_generic_nft`.
- Royalties event when `TradePayment` is created.

### Changed

- Updated Sui dep to `0.23.0`
- Renamed `Inventory` to `Warehouse`

### Fixed

- When creating a bid higher than the lowest ask, the bid is now filled with
  the lowest ask price. Before, it was filled with the bid price.

## [0.19.1] - 2023-01-23

### Changed

- Updated Sui dep to `0.22.1`

## [0.19.0] - 2023-01-13

### Changed

- Updated Sui dep to `0.22.0`

### Removed

- `CreatorsDomain` no longer has `is_frozen` flag as it needs to be
  reconstructed when edited, and it can be dropped when no longer needed.

## [0.18.0] - 2023-01-13

### Changed

- Orderbook and bidding liquidity layer contracts now support 3rd party
  collections, ie. those which are not build with `nft-protocol` primitives.
  These collections must implement their own royalty enforcement policies if
  they wish so.
- `TransferCap` exposes information about whether an NFT is a generic or native
  to our protocol.
- `safe::deposit_generic_nft_privileged`
- Refactored RoyaltyDomain and CreatorsDomain to split royalty share and authorization logic.
- Added entry function redeem_nft_transfer thus allowing creators to retrieve NFTs from private `Inventory`.
- Updated Sui dep to `0.21.0`

## [0.17.0] - 2022-12-19

### Changed

- Updated Sui dep to `0.20.0`

## [0.16.0] - 2023-01-03

### Changed

- Renaming `whitelist` to `allowlist` in relation to transferring NFTs.
- We maintain our own version of `movemate` dependency called `originmate`.
- Markets (`FixedPriceMarket`, `DutchAuctionMarket`) are now registered on `Inventory` rather than the `Slot`.
- Live and whitelisted status of markets is now tracked on `Inventory`.
- Market access permissions rearranged to use more direct `inventory_internal_mut`.
- Renamed `Launchpad` to `Marketplace` and `Slot` to `Listing`
- `Listing`s can not be create independent of `Marketplace`. They can operate independently or be attached to a `Marketplace` subsequent to its creation
- Renamed `AttributionDomain` to `CreatorsDomain`

## [0.15.0] - 2022-12-22

### Added

- Creating an ask with commission in the orderbook returns an error if the
  commission is greater equal to the ask price.
- `Safe` can now be used to transfer NFTs to a `Safe` which are not wrapped in
  the `nft_protocol::nft::Nft` type.
  These NFTs have lower guarantees when it comes to transfers.
  Enables us to integrate other standards.
- NFT minting can now be done privately to an `Inventory` object and only
  after transfered to a launchpad `Slot`

### Changed

- Renamed some arguments in the orderbook to be more descriptive.

### Removed

- Some protected actions were entry methods. This did not make sense because
  witness shouldn't have the `key` ability and therefore cannot be an entry
  function argument.

## [0.14.0] - 2022-12-20

### Changed

- New version of the protocol
- The core `Nft` type now has the fields `bag` and `logical_owner` where bag is used to add any domain to the NFT
- Changed Launchpad design to fit the business model of Marketplaces, where marketplaces and dApps can now deploy a Launchpad and NFT creators can launch their collections on such Launchpads by creating a Launchpad Slot.
- Launchpad Admin can define the `default_fee` on a launchpad sale
- If `launchpad.is_permissioned == true`, then only `launchpad.admin` can add `slots`, otherwise anyone can add `slots`
- Launchpad admins can attach custom fee policies to each Slot
- Proceeds coming from launchpad sales are collected in the struct `Proceeds`, and to unwrap the funds off this struct we guarantee fee collection enforcement.
- Name of the `deposit_nft_priviledged` was changed to `deposit_nft_privileged`.

### Added

- Domain standards for NFT Collections to use, such as `display`, `attribution`, `tags`, `royalties` and `flyweight`
- `Safe` module that holds NFTs on behalf of the owner and can delegate transferability via `TransferCap` and `ExclusiveTransferCap`
- Trading primitives modules such as `bidding` contract and `orderbook` contract

### Removed

- Removed `unique_nft`, `collectible` and `c_nft` modules as configurability now occurs on the type-exporting NFT collection module

## [0.13.0] - 2022-12-19

### Changed

- Updated Sui dep to `0.19.0`

## [0.12.0] - 2022-12-09

### Changed

- Updated Sui dep to `0.18.0`

## [0.11.0] - 2022-12-02

### Changed

- Updated Sui dep to `0.17.0`

## [0.10.0] - 2022-11-18

### Changed

- Updated Sui dep to `0.16.0`

## [0.9.0] - 2022-11-17

### Changed

- Updated Sui dep to `0.15.2`

### Added

- Added `dutch_auction` market primitive to the launchpad

## [0.8.0] - 2022-11-09

### Changed

- Updated Sui dep to `0.15.0`

## [0.7.0] - 2022-11-03

### Changed

- Updated Sui dep to `0.14.0`
- Since `transfer_to_object` was deprecated, we now use `dynamic_object_field`
  with slingshot to associate embedded NFTs.

## [0.6.0] - 2022-10-26

### Added

- Gutenberg: A rust templating engine to write Move NFT collection specific
  modules that top into our protocol.

### Changed

- Togling sale status permission via `fixed_price::sale_on` and`fized_price::sale_off` is now a permissioned action, that can only be done by the admin
- Simplified `supply` module by removing changing field `max` from `Option<u64>` to `u64`
- Renamed `collectibles` module to `collectible`
- Functions `compose_data_objects` in module `collectible` and `c_nft` are now entry functions
- Fixed `slingshot::claim_nft_loose` and it now accepts nft_data as generic `&D` instead of `D`

## [0.5.0] - 2022-10-21

### Changed

- Updated `Sui` to version `0.12.1`
- Moved the supply mint policy responsibility off the `Collection` object to a separate
  object `MintAuthority`
- `Slingshot` has now witness pattern `Slingshot<phantom T, M>` where
  `T` represents the exported NFT type and `M` the market type
- `Slingshot` module has entrypoints `claim_nft_embedded` and `claim_nt_loose`
- `std_collection::mint_and_transfer` function now expected `u64` for field `max_supply` instead of `Option<u64>` to facilitate function call on the client side

### Added

- `supply_policy` module with object `SupplyPolicy` to regulate NFT Collection supply
- Error handling via `err` module

### Removed

- `cap` module with objects `Limited` and `Unlimited` that regulate the supply
  of NFT collections
- Removed field `cap` from `Collection` object, removing the supply mint policy
  responsibility off the `Collection` object
- Removed field `index` from `unique_nft::Unique`, `collectibles::Collectible` and
  `c_nft::Data`

## [0.4.0] - 2022-10-11

### Changed

- Reimplemented `nft` module with `nft::Nft` object and removed `NftOwned`
- Reimplemented `collection` module with `collection::Collection` object
- Collection data fields now belong to `collection::Collection`
- `std_collection::StdMeta` now only has json field
- Reimplemented `slingshot` module with `slingshot::Slingshot` object
- NFT IDs for primary release are now stored in `sale::Sale` objects, accessible
  to the slingshot launchpad via the field `sales`
- Launchpads can now have `create_single_market` and `create_multi_market` sales
  configuration. The modules that implement the market type decide if the slinshot they initiate is single or multi market. In this current version, `fixed_price` is the only market immplementation.
- NFT Collections can now only be created via witness type

### Added

- `unique_nft` module and `unique_nft:Unique` object serving as domain-specific
  embedded NFT implementation
- `collectibles` module and `collectibles:Collectible` object serving as domain-specific
  loose NFT implementation
- `c_nft` module and `c_nft:Composable` object serving as domain-specific
  loose NFT implementation
- `sale` module to be able to perform multiple sales per slingshot launchpad
- `whitelist` module to be able to perform whitelisted sales
- `cap` module with objects `Limited` and `Unlimited` that regulate the supply
  of NFT collections
- `supply` module with object `Supply` that controls and manages the supply of a given
  object

### Removed

- `std_nft` module and `std_nft::StdNft` object

## [0.3.0] - 2022-09-20

### Changed

- Renamed move package from `nftProtocol` to `NftProtocol`.
- Renamed field `uri` to `url` for `std_nft::NftMeta`
- Changed parameter `collection` from `ID` to `&Collection<T, Meta>`
  in `fixed_price::create`

## [0.3.0] - 2022-09-20

### Changed

- Renamed field `uri` to `url` for `std_nft::NftMeta`
- Changed parameter `collection` from `ID` to `&Collection<T, Meta>`
  in `fixed_price::create`

## [0.2.0] - 2022-09-20

### Added

- The following objects with `key`, `store` abilities:
  - `slingshot::Slingshot` as generic launchpad
  - `fixed_price::LaunchpadConfig` as fixed price launchpad configuration
  - `fixed_price::NftCertificate` as certificate to redeem NFT
- The following structs to be used as witnesses:
  - `fixed_price::FixedPriceSale`
- Method `std_nft::mint_to_launchpad` to mint an NFT an transfer it to a
  launchpad

### Changed

- Bumped Sui version to `devnet-0.9.0`

## [0.1.0] - 2022-09-14

### Added

- The following structs with `key`, `store` abilities:
  - `collection::Collection` as generic Collection
  - `std_collection::CollectionMeta` as collection metadata
  - `nft::NftOwned` as generic NFT
  - `std_nft::NftMeta` as NFT metadata
- The following structs to be used as witnesses:
  - `std_nft::StdNft`
  - `std_collection::StdCollection`
- The object type `tags::Tags` with `copy`, `drop`, `store`
