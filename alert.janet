# Just fire off an Iup alert and nothing else in the loop

(defn alert [msg]
  (IupOpen (int-ptr) (char-ptr))
  (def dialog (IupDialog (int-ptr)))
  (def button (IupButton msg "NULL"))
  (IupAppend dialog button)
  (iup-set-thunk-callback
   button "ACTION"
   (fn [ih c]
     (pp "Close the IUP...")
     (IupClose)
     (const-IUP-CLOSE)))
  (IupShowXY dialog (const-IUP-CENTER) (const-IUP-CENTER))
  (IupMainLoop))
