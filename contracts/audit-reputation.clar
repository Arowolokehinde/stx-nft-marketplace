;; audit-reputation.clar

;; Import and implement SIP010 trait
(use-trait sip-010-trait .sip-010-trait.sip-010-trait)
(impl-trait .sip-010-trait.sip-010-trait)

;; Constants
(define-constant contract-owner tx-sender)
;; (define-data-var contract-owner (optional principal) none)
(define-constant max-auditors u100)
(define-constant max-mint-amount u1000)
(define-constant err-not-authorized (err u101))
(define-constant err-already-auditor (err u102))
(define-constant err-max-auditors-reached (err u103))
(define-constant err-mint-limit-exceeded (err u104))
(define-constant err-zero-amount (err u105))
(define-constant err-insufficient-balance (err u106))
(define-constant max-token-supply u1000000000)


;; Token definition
(define-fungible-token reputation-token u1000000000)

;; Data variables
(define-data-var token-name (string-ascii 32) "Reputation Token")
(define-data-var token-symbol (string-ascii 10) "REPT")
(define-data-var token-decimals uint u6)
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var auditor-count uint u0)
(define-constant err-self-transfer (err u108))


;; Maps
(define-map auditors principal bool)
(define-map whitelist principal bool)
(define-map roles principal (string-ascii 10))



(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (asserts! (> amount u0) err-zero-amount)
    (asserts! (<= amount (ft-get-balance reputation-token sender)) err-insufficient-balance)
    (asserts! (not (is-eq sender recipient)) err-self-transfer)
    
    (match (ft-transfer? reputation-token amount sender recipient)
      success (begin
        (print memo)
        (ok true))
      error (err u3))))


(define-read-only (is-whitelisted (user principal))
  (default-to false (map-get? whitelist user)))


(define-read-only (get-name)
  (ok (var-get token-name)))

(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance reputation-token who)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply reputation-token)))

(define-read-only (get-token-uri)
  (ok (var-get token-uri)))

;;  Role-Based Access Control
(define-read-only (get-role (user principal))
  (default-to "user" (map-get? roles user)))


;; Audit-specific functions

(define-read-only (is-auditor (address principal))
  (default-to false (map-get? auditors address)))

(define-public (verify-auditor (new-auditor principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (asserts! (is-none (map-get? auditors new-auditor)) err-already-auditor)
    (asserts! (< (var-get auditor-count) max-auditors) err-max-auditors-reached)
    (map-set auditors new-auditor true)
    (var-set auditor-count (+ (var-get auditor-count) u1))
    (print {event: "auditor_verified", auditor: new-auditor})
    (ok true)))


(define-public (burn (amount uint) (owner principal))
  (begin
    (asserts! (is-eq tx-sender owner) err-not-authorized)
    (asserts! (> amount u0) err-zero-amount)
    (asserts! (<= amount (ft-get-balance reputation-token owner)) err-insufficient-balance)
    (ft-burn? reputation-token amount owner)))



(define-public (remove-auditor (auditor principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (asserts! (is-some (map-get? auditors auditor)) err-already-auditor)
    (map-delete auditors auditor)
    (var-set auditor-count (- (var-get auditor-count) u1))
    (ok true)))

(define-public (audit-auditor (auditor principal))
  (begin
    (asserts! (is-auditor auditor) err-not-authorized)
    (print {event: "auditor-audited", auditor: auditor})
    (ok true)))


(define-read-only (check-max-supply)
  (let ((current-supply (ft-get-supply reputation-token)))
    (if (> current-supply max-token-supply)
      (err u107) ;; Error: Maximum token supply exceeded
      (ok true))))

;; Function to get the current count of auditors
(define-read-only (get-auditor-count)
  (ok (var-get auditor-count)))


(define-public (get-contract-owner)
  (ok contract-owner))


;; Safely add/remove from auditor count
(define-read-only (safe-add (a uint) (b uint))
  (if (<= (+ a b) u18446744073709551615)
    (ok (+ a b))
    (err u100)))

(define-read-only (safe-subtract (a uint) (b uint))
  (if (>= a b)
    (ok (- a b))
    (err u101)))
