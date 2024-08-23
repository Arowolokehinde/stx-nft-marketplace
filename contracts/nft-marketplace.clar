;; NFT Marketplace Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-listing-not-found (err u102))
(define-constant err-price-zero (err u103))

;; Data Variables
(define-data-var next-listing-id uint u0)
(define-data-var event-counter uint u0)

;; NFT Definition
(define-non-fungible-token nft-token uint)

;; Maps
(define-map listings
  uint
  {
    token-id: uint,
    price: uint,
    seller: principal
  }
)

;; Private Functions
(define-private (is-listing-match (listing {token-id: uint, price: uint, seller: principal}))
  (is-eq (get token-id listing) token-id)
)

(define-private (emit-event (event-type (string-ascii 50)) (data (string-ascii 100)))
  (let
    ((event-id (var-get event-counter)))
    (print {event-id: event-id, event-type: event-type, data: data})
    (var-set event-counter (+ event-id u1))
    event-id
  )
)

;; Public Functions
(define-public (create-listing (token-id uint) (price uint))
  (let
    (
      (owner (unwrap! (nft-get-owner? nft-token token-id) (err u104)))
      (listing-id (var-get next-listing-id))
    )
    (asserts! (is-eq tx-sender owner) err-not-token-owner)
    (asserts! (> price u0) err-price-zero)
    (map-set listings listing-id {token-id: token-id, price: price, seller: tx-sender})
    (var-set next-listing-id (+ listing-id u1))
    (emit-event "listing-created" (concat (concat (uint-to-ascii listing-id) "-") (uint-to-ascii token-id)))
    (ok listing-id)
  )
)

(define-public (cancel-listing (listing-id uint))
  (let
    (
      (listing (unwrap! (map-get? listings listing-id) err-listing-not-found))
      (owner (unwrap! (nft-get-owner? nft-token (get token-id listing)) (err u104)))
    )
    (asserts! (is-eq tx-sender owner) err-not-token-owner)
    (map-delete listings listing-id)
    (ok true)
  )
)

(define-public (update-listing-price (listing-id uint) (new-price uint))
  (let
    (
      (listing (unwrap! (map-get? listings listing-id) err-listing-not-found))
      (owner (unwrap! (nft-get-owner? nft-token (get token-id listing)) (err u104)))
    )
    (asserts! (is-eq tx-sender owner) err-not-token-owner)
    (asserts! (> new-price u0) err-price-zero)
    (map-set listings listing-id (merge listing {price: new-price}))
    (ok true)
  )
)

(define-public (buy-nft (listing-id uint))
  (let
    (
      (listing (unwrap! (map-get? listings listing-id) err-listing-not-found))
      (buyer tx-sender)
      (seller (get seller listing))
      (price (get price listing))
      (token-id (get token-id listing))
    )
    (asserts! (is-eq (nft-get-owner? nft-token token-id) (ok seller)) err-not-token-owner)
    (try! (stx-transfer? price buyer seller))
    (try! (nft-transfer? nft-token token-id seller buyer))
    (map-delete listings listing-id)
    (emit-event "nft-sold" (concat (concat (uint-to-ascii listing-id) "-") (uint-to-ascii token-id)))
    (ok true)
  )
)

(define-public (mint-nft (recipient principal))
  (let
    (
      (token-id (var-get next-listing-id))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (nft-mint? nft-token token-id recipient))
    (var-set next-listing-id (+ token-id u1))
    (ok token-id)
  )
)

;; Read-Only Functions
(define-read-only (get-listing (listing-id uint))
  (map-get? listings listing-id)
)

(define-read-only (get-next-listing-id)
  (var-get next-listing-id)
)

(define-read-only (get-total-listings)
  (var-get next-listing-id)
)

(define-read-only (is-token-listed (token-id uint))
  (let
    (
      (listings-count (var-get next-listing-id))
    )
    (some
      (filter
        is-listing-match
        (map unwrap-panic (map get-listing (list-range-uint u0 listings-count)))
      )
    )
  )
)

(define-read-only (get-event-counter)
  (var-get event-counter)
)

(define-read-only (get-nft-owner (token-id uint))
  (nft-get-owner? nft-token token-id)
)

(define-read-only (get-all-listings)
  (let
    ((listings-count (var-get next-listing-id)))
    (map unwrap-panic (map get-listing (list-range-uint u0 listings-count)))
  )
)

;; Contract Initialization
(begin
  (try! (nft-mint? nft-token u0 contract-owner))
)