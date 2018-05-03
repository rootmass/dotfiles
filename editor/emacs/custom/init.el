;;(when (>= emacs-major-version 24)
;;        ;;(require 'package)
;;        (package-initialize)
;;        (setq package-archives '(("gnu"   . "http://elpa.emacs-china.org/gnu/")
;;            ("melpa" . "http://elpa.emacs-china.org/melpa/"))))

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)
(require 'package)

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; (package-initialize)

;;; This file bootstraps the configuration, which is divided into
;;; a number of other files.

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'init-benchmarking) ;; Measure startup time

(defconst *spell-check-support-enabled* nil) ;; Enable with t if you prefer
(defconst *is-a-mac* (eq system-type 'darwin))

(setenv "PATH" (concat "/usr/local/bin" ":" (getenv "PATH")))
(setq exec-path (append exec-path '("/usr/local/bin" "/usr/texbin")))

;;----------------------------------------------------------------------------
;; Variables configured via the interactive 'customize' interface
;;----------------------------------------------------------------------------
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;----------------------------------------------------------------------------
;; Path for eshell
;;----------------------------------------------------------------------------
;; (defun eshell-mode-hook-func ()
;;   (setq eshell-path-env (concat "/usr/local/bin:" eshell-path-env))
;;   (setenv "PATH" (concat "/usr/local/bin:" (getenv "PATH")))
;;   (define-key eshell-mode-map (kbd "M-s") 'other-window-or-split))
;; (add-hook 'eshell-mode-hook 'eshell-mode-hook-func)

;;----------------------------------------------------------------------------
;; Bootstrap config
;;----------------------------------------------------------------------------
(require 'init-utils)       ;; Utils 
;;(require 'init-site-lisp) ;; Must come before elpa, as it may provide package.el
(require 'init-elpa)        ;; Machinery for installing required packages


;;----------------------------------------------------------------------------
;; Function for Specific Character
;;----------------------------------------------------------------------------
(require 'init-encoding)

;;----------------------------------------------------------------------------
;; Features
;;----------------------------------------------------------------------------
;;(require 'init-idle)
(require 'init-style)       ;; k&r C style
(require 'init-evil)        ;; Vim for emacs
(require 'init-evil-leader) ;; Key sets
(require 'init-kill-ring)
(require 'init-dict)
;;(require 'init-tabbar)
(require 'init-multiple-cursors)

;;(require 'init-mode-line)
;;(require 'init-smooth-scrolling)
(require 'init-org)         ;; 全能的笔记工具
(require 'init-latex)
(require 'init-git)
(require 'init-completing-statements)
(require 'init-gradle)
(require 'init-guide-key)
(require 'init-dired)                 ;; Directory display and operation
;;(require 'init-ido)                 ;; InteractivelyDoThings
(require 'init-auto-complete)
;;(require 'init-company)  ;; 自动完成输入,支持各种语言和后端
(require 'init-matlab)
(require 'init-vimrc)
;;(require 'init-ibuffer)
;;(require 'init-iedit)
(require 'init-yasnippet)   ;; 强大的文本模板输入工具
(require 'init-abbrev)
(require 'init-slime)
(require 'init-w3)
;;(require 'init-smartparens) ;; 自动输入需要成对输入的字符如括号
(require 'init-expand-region)         ;; 快捷键选中文本,可将选择区域伸缩
(require 'init-whitespace)

(require 'init-prolog)
;;(require 'init-lua)
;; (require 'init-java)
;;;;(require 'init-js)

;; (require 'init-vc)
(require 'init-isearch)
;; (require 'init-cedet)
;; (require 'init-ecb)
;; (require 'init-ascope)
(require 'init-etags)
(require 'init-ag)

;; (require 'init-insert-continuous-numbers)

;; (require 'init-os161)

;;Config about theme and font and variable
;;Move down to avoid local setting overwrite theme setting
;; (require 'init-display-variable)
;; (require 'init-fill-column)

;;(require 'init-kbd)

;;jedi configure init
(require 'init-jedi)

;;emmet-mode
;;(require 'init-emmet)


;;highlight-parentheses
(require 'highlight-parentheses)
(define-globalized-minor-mode global-highlight-parentheses-mode
  highlight-parentheses-mode
  (lambda ()
    (highlight-parentheses-mode t)))
(global-highlight-parentheses-mode t)
;;markdown configure
;;(require 'init-markdown)

;;----------------------------------------------------------------------------
;; Allow access from emacsclient
;;----------------------------------------------------------------------------
(require 'init-daemon)

;;Powerline
(require 'powerline)

;;Nyan-MODE
(require 'init-nyan)

;;; Show startup time
(message "init completed in %.2fms" (sanityinc/time-subtract-millis (current-time) before-init-time))
