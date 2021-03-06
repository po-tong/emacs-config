;;; init-000-core-base.el --- Customize emacs basic functionalities

;; Copyright (C) 2018 Po Tong

;; Author: Po Tong
;; Maintaainer: Po Tong
;; Created: 2018-06-24

;; Keywords: emacs, use-package, configuration

;;; Commentary:

;;; Code:
(require 'use-package)

;; Emacs starts out with a black buffer
(setq inhibit-splash-screen t
      initial-scratch-message nil)

;; Turn dinging off
(setq visible-bell nil)
(setq ring-bell-function 'ignore)

;; Turn off menu bar, tool bar, and scroll bar
(if window-system (scroll-bar-mode -1))
(tool-bar-mode -1)
(menu-bar-mode -1)

;; Backup files setup
(setq
 backup-by-copying t      ; don't clobber symlinks
 backup-directory-alist
 `((".*" . ,temporary-file-directory)) ; don't litter my fs tree
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)       ; use versioned backups

;; For :diminish
(use-package diminish
  :ensure t)

;; For :delight
(use-package delight
  :ensure t)

;; Load custom theme - Spacemacs-dark
(use-package spacemacs-common
  :ensure spacemacs-theme
  :config (load-theme 'spacemacs-dark t))

;; Customize the modeline
(use-package spaceline-config
  :ensure spaceline
  :config (spaceline-spacemacs-theme))

;; Ivy mode
(use-package ivy
  :ensure t
  :diminish ivy-mode
  :config
  (ivy-mode 1))

;; Projectile setup
(use-package projectile
  :ensure t
  :delight '(:eval (concat " " (projectile-project-name)))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :config
  (projectile-mode 1)
  (setq projectile-completion-system 'ivy))

;; ivy UI for projectile
(use-package counsel-projectile
  :ensure t
  :config
  (counsel-projectile-mode))

;; silver search
(use-package ag
  :ensure t
  :config
  (setq ag-highlight-search t)
  (setq ag-reuse-buffers t)
  (add-to-list 'ag-arguments "--word-regexp"))

;; Tree directory using neotree
(use-package neotree
  :ensure t
  :bind (("C-c o" . neotree-toggle)
         :map neotree-mode-map
         ("e" . neotree-enter-hide))
  :init
  (setq neo-show-hidden-files t)
  (setq neo-create-file-auto-open t)
  (setq neo-keymap-style 'concise)
  (setq neo-smart-open t)
  (setq neo-vc-integration '(face))
  (defun neo-open-file-hide (full-path &optional arg)
    "Open a file node and hides tree."
    (neo-global--select-mru-window arg)
    (find-file full-path)
    (neotree-hide))
  (defun neotree-enter-hide (&optional arg)
    "Enters file and hides neotree directly"
    (interactive "P")
    (neo-buffer--execute arg 'neo-open-file-hide 'neo-open-dir)))


;; Flycheck
(use-package flycheck
  :ensure t
  :diminish flycheck-mode
  :init
  (global-flycheck-mode t))

;; Magit
(use-package magit
  :ensure t
  :diminish auto-revert-mode
  :bind ("C-x g" . magit-status))

(use-package smartparens-config
  :ensure smartparens
  :diminish smartparens-mode
    :config
    (progn
      (show-smartparens-global-mode t)))

(add-hook 'prog-mode-hook 'turn-on-smartparens-strict-mode)
(add-hook 'markdown-mode-hook 'turn-on-smartparens-strict-mode)

;; JavaScript setup starts here
(use-package js2-mode
  :ensure t
  :diminish (js2-refactor-mode yas-minor-mode)
  :mode "\\.js\\'"
  :init
  (add-hook 'js2-mode-hook (lambda()
							 (setq js-switch-indent-offset 4))))

(use-package js2-refactor-mode
  :after js2-mode
  :ensure js2-refactor
  :hook js2-mode
  ;; :bind (("C-k" . js2r-kill))
  :init (js2r-add-keybindings-with-prefix "C-c C-r"))

(use-package company-tern
  :after js2-mode
  :diminish (tern-mode company-mode)
  :ensure t
  :init
  (add-hook 'js2-mode-hook (lambda ()
			     (tern-mode)
			     (company-mode)))
  :config
  (add-to-list 'company-backends 'company-tern))

;; JSON setup starts here
(use-package json-mode
  :ensure t
  :mode "\\.json\\'")

;; Maerkdown setup starts here
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  ;; :init (setq markdown-command "multimarkdown")
  )

(use-package flymd
  :ensure t
  :after markdown-mode
  :config
  (defun my-flymd-browser-function (url)
    (let ((browse-url-browser-function 'browse-url-firefox))
      (browse-url url)))
  (setq flymd-browser-open-function 'my-flymd-browser-function))

;; golang setup starts here
(use-package go-mode
  :ensure t
  :mode "\\.go\\'"
  :init
  (add-to-list 'exec-path "/home/po/go/bin")
  (add-to-list 'load-path "~/.emacs.d/lisp/")
  (require 'go-guru)
  (defun my-go-mode-hook ()
    ;; use goimports instead of go-fmt
    (setq gofmt-command "goimports")
    ;; Call gofmt before saving
    (add-hook 'before-save-hook 'gofmt-before-save)
    ;; customize compile command to run go build
    (if (not (string-match "go" compile-command))
	(set (make-local-variable 'compile-command)
	     "go build -v && go test -v && go vet"))
    ;; godef jump key binding
    (local-set-key (kbd "M-.") 'godef-jump)
    (local-set-key (kbd "M-*") 'pop-tag-mark))
  (defun auto-complete-for-go ()
    (auto-complete-mode 1))
  (add-hook 'go-mode-hook 'my-go-mode-hook)
  (add-hook 'go-mode-hook 'auto-complete-for-go)
  (with-eval-after-load 'go-mode
    (require 'go-autocomplete))
  (go-guru-hl-identifier-mode))

;; php setup starts here
(use-package php-mode
  :ensure t
  :diminish (abbrev-mode)
  :mode "\\.php\\'"
  :init
  (add-hook 'php-mode-hook (lambda()
							 (setq tab-width 4
								   indent-tabs-mode t))))

(use-package company-php
  :ensure t
  :after php-mode
  :diminish company-mode
  :init
  (add-hook 'php-mode-hook 'company-mode)
  :config
  (add-to-list 'company-backends 'company-ac-php-backend))

;;; init-000-core-base.el ends here
