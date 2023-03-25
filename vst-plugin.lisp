(ql:quickload '(:cl-collider :sc-extensions :sc-vst :cm))

(in-package :sc-user)
(named-readtables:in-readtable :sc)
(use-package :sc-extensions)

(setf *s* (make-external-server "localhost" :port 57110))
(server-boot *s*)


#|
;; search vst plugin
(sc-vst:vst-search)

|#


(defvar *vu* (sc-vst:vst-controller
	      (play (progn
		      (sc-vst:vst-plugin.ar (in.ar 0 2) 2 :efx)
		      0.0)
		    :to 0 :pos :tail)
	      :efx "mvMeter2.vst3"))

(defvar *efx-group* (make-group))


(defvar *shimmer* (sc-vst:vst-controller
		   (play (sc-vst:vst-plugin.ar (in.ar 100 2) 2 :efx)
			 :to *efx-group*)
		   :efx "ValhallaShimmer.vst3"))

(defvar *delay* (sc-vst:vst-controller
		 (play (sc-vst:vst-plugin.ar (in.ar 102 2) 2 :efx)
		       :to *efx-group*)
		 :efx "ValhallaDelay.vst3"))




(sc-vst:editor *shimmer*)
(sc-vst:editor *delay*)
(sc-vst:editor *vu*)

(setf (sc-vst:parameter *shimmer* 0) 1.0)
(setf (sc-vst:parameter *shimmer* 2) .3)
(setf (sc-vst:parameter *delay* 0) 1.0)



(defsynth fm-inst ((freq 100) (ratio 1) (indx 1) (amp 1.0) (attk .3) (rel .3) (dur 4.0) (gain [1. .0 .0]))
  (let* ((freq [freq (+ freq 4)])
	 (sig (* amp .3 (pm-osc.ar freq (* freq ratio) indx .0 (env-gen.kr (env [0 .2 .2 0] (* dur [attk (- 1.0 (+ attk rel)) rel])) :act :free)))))
    (out.ar 0 (* sig (first gain)))
    (out.ar 100 (* sig (second gain)))
    (out.ar 102 (* sig (third gain)))))


(defun fm-sound (beat dur)
  (let* ((n 6))
    (loop repeat n
	  do (at-beat (+ beat 0)
	       (synth 'fm-inst :freq (midicps (+ (rrand [48 60 72]) (rrand (pc:scale 0 :dorian))))
			       :attk .0
			       :amp .6
			       :dur 4
			       :gain [1. .3 .3]))))
  (clock-add (+ beat dur) 'fm-sound (+ beat dur) dur))

(fm-sound (clock-quant 1) 4)



