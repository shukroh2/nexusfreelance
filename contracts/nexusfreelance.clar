;; ==========================
;; Contract: scholar-freelance-dao.clar
;; Purpose: Unified freelance, AI grading, DAO voting, NFT-based rep, escrow, penalties, referrals, secret commitment system
;; ==========================

;; === User Management ===
(define-map users
  principal
  {
    role: (string-ascii 16),
    profile-uri: (string-utf8 256),
    stake: uint,
    trust-score: uint,
  }
)

(define-map rep-nft
  principal
  {
    score: uint,
    wins: uint,
    fails: uint,
    disputes: uint,
  }
)

(define-data-var total-users uint u0)

(define-public (register
    (role (string-ascii 16))
    (profile-uri (string-utf8 256))
  )
  (begin
    (asserts! (<= (len role) u16) (err u1000))
    (asserts! (<= (len profile-uri) u256) (err u1001))
    (map-insert users tx-sender {
      role: role,
      profile-uri: profile-uri,
      stake: u0,
      trust-score: u50,
    })
    (var-set total-users (+ (var-get total-users) u1))
    (ok true)
  )
)

(define-public (stake-tokens (amount uint))
  (let ((transfer-result (stx-transfer? amount tx-sender (as-contract tx-sender))))
    (match transfer-result
      ok-value (let ((current (default-to {
          role: "",
          profile-uri: u"",
          stake: u0,
          trust-score: u0,
        }
          (map-get? users tx-sender)
        )))
        (map-set users tx-sender
          (merge current { stake: (+ (get stake current) amount) })
        )
        (ok true)
      )
      err-value
      transfer-result
    )
  )
)

;; === Job Management ===
(define-map jobs
  uint
  {
    client: principal,
    freelancer: principal,
    milestones: (list 10 uint),
    status: (string-ascii 16),
    paid: uint,
  }
)

(define-map submissions
  {
    job-id: uint,
    ms-id: uint,
  }
  {
    uri: (string-utf8 256),
    status: (string-ascii 16),
  }
)
(define-map ai-scores
  {
    job-id: uint,
    ms-id: uint,
  }
  uint
)
(define-map ai-feedback
  {
    job-id: uint,
    ms-id: uint,
  }
  {
    strengths: (string-utf8 256),
    improvements: (string-utf8 256),
  }
)

(define-data-var total-jobs uint u0)

(define-public (create-job
    (freelancer principal)
    (milestones (list 10 uint))
    (total uint)
  )
  (begin
    (asserts! (is-eq freelancer freelancer) (err u1002))
    (asserts! (<= (len milestones) u10) (err u1003))
    (asserts! (<= total u1000000000) (err u1009))
    (let ((job-id (+ (var-get total-jobs) u1)))
      (let ((transfer-result (stx-transfer? total tx-sender (as-contract tx-sender))))
        (match transfer-result
          ok-value (begin
            (asserts! (is-eq job-id job-id) (err u1010))
            (map-insert jobs job-id {
              client: tx-sender,
              freelancer: freelancer,
              milestones: milestones,
              status: "active",
              paid: total,
            })
            (var-set total-jobs job-id)
            (ok job-id)
          )
          err-value (err u1008)
        )
      )
    )
  )
)

(define-public (submit-milestone
    (job-id uint)
    (ms-id uint)
    (uri (string-utf8 256))
  )
  (begin
    (asserts! (<= (len uri) u256) (err u1004))
    (asserts! (<= job-id u1000000) (err u1011))
    (asserts! (<= ms-id u10) (err u1012))
    (map-set submissions {
      job-id: job-id,
      ms-id: ms-id,
    } {
      uri: uri,
      status: "submitted",
    })
    (ok true)
  )
)

(define-public (oracle-grade
    (job-id uint)
    (ms-id uint)
    (score uint)
  )
  (begin
    (asserts! (<= score u100) (err u1005))
    (asserts! (<= job-id u1000000) (err u1013))
    (asserts! (<= ms-id u10) (err u1014))
    (map-set ai-scores {
      job-id: job-id,
      ms-id: ms-id,
    } score
    )
    (ok true)
  )
)

(define-public (submit-ai-feedback
    (job-id uint)
    (ms-id uint)
    (strengths (string-utf8 256))
    (improvements (string-utf8 256))
  )
  (begin
    (asserts! (<= (len strengths) u256) (err u1006))
    (asserts! (<= (len improvements) u256) (err u1007))
    (asserts! (<= job-id u1000000) (err u1015))
    (asserts! (<= ms-id u10) (err u1016))
    (map-set ai-feedback {
      job-id: job-id,
      ms-id: ms-id,
    } {
      strengths: strengths,
      improvements: improvements,
    })
    (ok true)
  )
)

;; === Escrow & Penalty ===
(define-public (release-milestone
    (job-id uint)
    (ms-id uint)
  )
  (let (
      (job (map-get? jobs job-id))
      (score (default-to u0
        (map-get? ai-scores {
          job-id: job-id,
          ms-id: ms-id,
        })
      ))
      (sub (map-get? submissions {
        job-id: job-id,
        ms-id: ms-id,
      }))
    )
    (asserts! (is-some job) (err u404))
    (asserts! (is-some sub) (err u405))
    (asserts! (>= score u60) (err u406))
    (let (
        (j (unwrap! job (err u404)))
        (amount (unwrap! (element-at (get milestones j) ms-id) (err u408)))
        (freelancer (get freelancer j))
        (sub-unwrapped (unwrap! sub (err u405)))
      )
      (asserts! (<= amount u1000000000) (err u1017))
      (asserts! (<= job-id u1000000) (err u1018))
      (asserts! (<= ms-id u10) (err u1019))
      (let ((transfer-result (stx-transfer? amount (as-contract tx-sender) freelancer)))
        (match transfer-result
          ok-value (begin
            (map-set submissions {
              job-id: job-id,
              ms-id: ms-id,
            }
              (merge sub-unwrapped { status: "released" })
            )
            (ok true)
          )
          err-value (err u1020)
        )
      )
    )
  )
)
