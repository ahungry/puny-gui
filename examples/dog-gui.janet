(import examples/dog-sdk :as sdk)

(defn get-new-dog
  "Fetch a dog in a new thread."
  [ih c]
  (thread/new (fn [p] (sdk/main nil))))

(defn show []
  (def iup (IupOpen (int-ptr) (char-ptr)))
  (def label (IupLabel "Click the button to see a new dog.\r
Click the dog to close the app"))

  (def button (IupButton "Find a cute dog" "NULL"))
  (def button2 (IupButton "" "NULL"))


  (var dog-image (IupLoadImage "dog.jpg"))
  (IupSetAttribute button2 "SIZE" "300x300")
  (IupSetAttributeHandle button2 "IMAGE" dog-image)

  (def vbox (IupVbox button (int-ptr)))

  (IupAppend vbox label)
  (IupAppend vbox button2)

  (IupSetAttribute vbox "ALIGNMENT" "ACENTER")
  (IupSetAttribute vbox "GAP" "10")
  (IupSetAttribute vbox "MARGIN" "10x10")

  (def dialog (IupDialog vbox))

  (IupSetAttribute dialog "TITLE" "Puppy finder")

  # Handle refreshing the image in a timer so the GUI doesn't lag while image loads
  (def timer (IupTimer))
  (IupSetAttribute timer "TIME" "1000")
  (iup-set-thunk-callback
   timer "ACTION_CB"
   (fn [ih c]
       (def img (IupLoadImage "dog.jpg"))
       (IupSetAttributeHandle button2 "IMAGE" img)
       (IupRedraw button2 0)))
  (IupSetAttribute timer "RUN" "yes")

  (iup-set-thunk-callback button "ACTION" get-new-dog)

  (iup-set-thunk-callback button2 "ACTION" (fn [_ _] (const-IUP-CLOSE)))

  (IupSetAttribute dialog "SIZE" "330x300")
  (IupShowXY dialog (const-IUP-CENTER) (const-IUP-CENTER))

  )

(defn main [_]
  (show)
  (IupMainLoop))
