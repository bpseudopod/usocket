;;;; $Id$
;;;; $URL$

;;;; See LICENSE for licensing information.

(in-package :usocket)

(defclass usocket ()
  ((socket
    :initarg :socket
    :accessor socket)
   (stream
    :initarg :stream
    :accessor socket-stream)
   (local-address
    :initarg :local-address
    :accessor local-address)
   (local-port
    :initarg :local-port
    :accessor local-port)))

(defun make-socket (&key socket local-address local-port stream)
  (make-instance 'usocket
                 :socket socket
                 :local-address local-address
                 :local-port local-port
                 :stream stream))

(defgeneric socket-close (usocket))

;;
;; IPv4 utility functions
;;

(defun list-of-strings-to-integers (list)
  "Take a list of strings and return a new list of integers (from
parse-integer) on each of the string elements."
  (let ((new-list nil))
    (dolist (element (reverse list))
      (push (parse-integer element) new-list))
    new-list))

(defun hbo-to-dotted-quad (integer)
  "Host-byte-order integer to dotted-quad string conversion utility."
  (let ((first (ldb (byte 8 24) integer))
        (second (ldb (byte 8 16) integer))
        (third (ldb (byte 8 8) integer))
        (fourth (ldb (byte 8 0) integer)))
    (format nil "~A.~A.~A.~A" first second third fourth)))

(defun hbo-to-vector-quad (integer)
  "Host-byte-order integer to dotted-quad string conversion utility."
  (let ((first (ldb (byte 8 24) integer))
        (second (ldb (byte 8 16) integer))
        (third (ldb (byte 8 8) integer))
        (fourth (ldb (byte 8 0) integer)))
    (vector first second third fourth)))

(defun vector-quad-to-dotted-quad (vector)
  (format nil "~A.~A.~A.~A"
          (aref vector 0)
          (aref vector 1)
          (aref vector 2)
          (aref vector 3)))

(defun dotted-quad-to-vector-quad (string)
  (let ((list (list-of-strings-to-integers (split-sequence:split-sequence #\. string))))
    (vector (first list) (second list) (third list) (fourth list))))

(defmethod host-byte-order ((string string))
  "Convert a string, such as 192.168.1.1, to host-byte-order, such as
3232235777."
  (let ((list (list-of-strings-to-integers (split-sequence:split-sequence #\. string))))
    (+ (* (first list) 256 256 256) (* (second list) 256 256)
       (* (third list) 256) (fourth list))))

(defmethod host-byte-order ((vector vector))
  "Convert a vector, such as #(192 168 1 1), to host-byte-order, such as
3232235777."
  (+ (* (aref vector 0) 256 256 256) (* (aref vector 1) 256 256)
     (* (aref vector 2) 256) (aref vector 3)))

;;
;; DNS helper functions
;;

(defun get-host-by-name (name)
  (let ((hosts (get-hosts-by-name name)))
    (car hosts)))

(defun get-random-host-by-name (name)
  (let ((hosts (get-hosts-by-name name)))
    (elt hosts (random (length hosts)))))