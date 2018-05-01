(require-package 'nyan-mode)

;;(setq default-mode-line-format  
;;      (list ""  
;;            'mode-line-modified  
;;            "<"  
;;            "kirchhoff"  
;;            "> "  
;;            "%10b"  
;;            '(:eval (when nyan-mode (list (nyan-create))));;注意添加此句到你的format配置列表中  
;;            " "  
;;            'default-directory  
;;            " "  
;;            "%[("  
;;            'mode-name  
;;            'minor-mode-list  
;;            "%n"  
;;            'mode-line-process  
;;            ")%]--"  
;;            "Line %l--"  
;;            '(-3 . "%P")  
;;            "-%-"))  

(nyan-mode t);;启动nyan-mode  
(nyan-start-animation);;开始舞动吧（会耗cpu资源）  
(provide 'init-nyan)
