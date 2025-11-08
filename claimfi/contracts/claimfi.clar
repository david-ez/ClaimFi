;; Decentralized Insurance Contract

;; Constants
(define-constant protocol-admin tx-sender)
(define-constant error-unauthorized (err u100))
(define-constant error-invalid-claim (err u101))
(define-constant error-low-balance (err u102))
(define-constant error-not-insured (err u103))
(define-constant error-invalid-params (err u104))
(define-constant maximum-coverage u1000000000) ;; Maximum coverage amount
(define-constant maximum-duration u52560) ;; Maximum duration (about 1 year in blocks)
(define-constant minimum-premium u1000) ;; Minimum premium amount

;; Data Maps
(define-map policy-registry
    principal
    {
        coverage-amount: uint,
        premium-amount: uint,
        expiry-block: uint
    })

(define-map claim-registry
    principal
    {
        claim-amount: uint, 
        approved: bool
    })

;; Variables
(define-data-var insurance-fund uint u0)

;; Admin Functions
(define-public (create-policy (coverage-amount uint) (premium-amount uint) (duration-blocks uint))
    (let ((expiry-block (+ block-height duration-blocks)))
        (begin
            (asserts! (is-eq tx-sender protocol-admin) error-unauthorized)
            (asserts! (<= coverage-amount maximum-coverage) error-invalid-params)
            (asserts! (>= premium-amount minimum-premium) error-invalid-params)
            (asserts! (<= duration-blocks maximum-duration) error-invalid-params)
            (map-set policy-registry tx-sender
                {
                    coverage-amount: coverage-amount,
                    premium-amount: premium-amount,
                    expiry-block: expiry-block
                })
            (ok true))))

;; User Functions
(define-public (purchase-policy (coverage-amount uint) (duration-blocks uint))
    (let 
        ((premium-cost (* coverage-amount (/ u1 u100) duration-blocks))
         (expiry-block (+ block-height duration-blocks)))
        (begin
            (asserts! (<= coverage-amount maximum-coverage) error-invalid-params)
            (asserts! (<= duration-blocks maximum-duration) error-invalid-params)
            (asserts! (>= premium-cost minimum-premium) error-invalid-params)
            
            ;; Safe arithmetic operations with checks
            (asserts! (>= (+ (var-get insurance-fund) premium-cost) 
                         (var-get insurance-fund)) 
                     error-invalid-params)
            
            (try! (stx-transfer? premium-cost tx-sender (as-contract tx-sender)))
            (var-set insurance-fund (+ (var-get insurance-fund) premium-cost))
            (map-set policy-registry tx-sender
                {
                    coverage-amount: coverage-amount,
                    premium-amount: premium-cost,
                    expiry-block: expiry-block
                })
            (ok true))))

(define-public (file-claim (claim-amount uint))
    (let 
        ((policy (unwrap! (map-get? policy-registry tx-sender) (err error-not-insured))))
        (begin
            (asserts! (<= claim-amount (get coverage-amount policy)) (err error-invalid-claim))
            (asserts! (is-ok (as-contract (stx-transfer? claim-amount tx-sender tx-sender))) (err error-low-balance))
            (var-set insurance-fund (- (var-get insurance-fund) claim-amount))
            (map-set claim-registry tx-sender
                {
                    claim-amount: claim-amount,
                    approved: true
                })
            (ok true))))

;; Read-Only Functions
(define-read-only (get-policy-details (policyholder principal))
    (map-get? policy-registry policyholder))

(define-read-only (get-claim-details (claimant principal))
    (map-get? claim-registry claimant))

(define-read-only (get-fund-balance)
    (var-get insurance-fund))